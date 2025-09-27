import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all organization users (both registered and tracked)
  Future<List<Map<String, dynamic>>> getOrganizationUsers(String organizationId) async {
    try {
      // Get user_role entries with user details
      final userRoles = await _supabase
          .from('user_role')
          .select('''
            *,
            user:users!user_role_user_id_fkey(id, email, created_at)
          ''')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false);

      // Get user_tracking entries (pending users)
      final userTracking = await _supabase
          .from('user_tracking')
          .select('*')
          .eq('organization_id', organizationId)
          .eq('is_synced', false)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> allUsers = [];

      // Add registered users
      for (var role in userRoles) {
        if (role['user'] != null) {
          allUsers.add({
            'id': role['id'],
            'user_id': role['user_id'],
            'email': role['user']['email'],
            'user_type': role['user_type'],
            'devices': role['devices'],
            'is_registered': true,
            'is_synced': true,
            'created_at': role['created_at'],
            'updated_at': role['updated_at'],
            'registration_date': role['user']['created_at'],
          });
        }
      }

      // Add pending users from user_tracking
      for (var tracking in userTracking) {
        allUsers.add({
          'id': tracking['id'],
          'user_id': null,
          'email': tracking['email'],
          'user_type': tracking['user_type'],
          'devices': tracking['devices'],
          'is_registered': false,
          'is_synced': false,
          'created_at': tracking['created_at'],
          'updated_at': tracking['updated_at'],
          'added_by': tracking['added_by'],
        });
      }

      // Sort by creation date (newest first)
      allUsers.sort((a, b) => DateTime.parse(b['created_at'])
          .compareTo(DateTime.parse(a['created_at'])));

      return allUsers;
    } catch (e) {
      print('Error fetching organization users: $e');
      return [];
    }
  }

  /// Add a new user to the organization
  Future<Map<String, dynamic>?> addOrganizationUser({
    required String organizationId,
    required String email,
    required String userType,
    required dynamic devices,
    required String addedBy,
  }) async {
    try {
      print('Adding user: $email to organization: $organizationId');
      
      // Check if email is already tracked in user_tracking for this organization
      final existingTracking = await _supabase
          .from('user_tracking')
          .select('id')
          .eq('organization_id', organizationId)
          .eq('email', email.toLowerCase())
          .maybeSingle();

      if (existingTracking != null) {
        throw 'User email is already tracked for this organization';
      }

      // Check if user exists and is already in user_role for this organization
      final userId = await getUserIdByEmail(email);
      if (userId != null) {
        final existingRole = await _supabase
            .from('user_role')
            .select('id')
            .eq('organization_id', organizationId)
            .eq('user_id', userId)
            .maybeSingle();

        if (existingRole != null) {
          throw 'User is already a member of this organization';
        }
      }

      print('User $email ${userId != null ? "exists" : "does not exist yet"} - adding to user_tracking');

      // Add to user_tracking table (this will work for both existing and non-existing users)
      final response = await _supabase
          .from('user_tracking')
          .insert({
            'organization_id': organizationId, 
            'email': email.toLowerCase(),
            'user_type': userType,
            'devices': devices,
            'added_by': addedBy,
          })
          .select()
          .single();

      print('Successfully added user to tracking table: ${response['id']}');
      
      // Add information about whether user existed
      response['user_existed'] = userId != null;
      return response;
    } catch (e) {
      print('Error adding organization user: $e');
      rethrow;
    }
  }

  /// Update user permissions
  Future<Map<String, dynamic>?> updateUserPermissions({
    required String userId,
    required String organizationId,
    required String userType,
    required dynamic devices,
    bool isRegistered = true,
  }) async {
    try {
      if (isRegistered) {
        // Update user_role table
        final response = await _supabase
            .from('user_role')
            .update({
              'user_type': userType,
              'devices': devices,
            })
            .eq('user_id', userId)
            .eq('organization_id', organizationId)
            .select()
            .single();

        return response;
      } else {
        // Update user_tracking table
        final response = await _supabase
            .from('user_tracking')
            .update({
              'user_type': userType,
              'devices': devices,
            })
            .eq('id', userId) // For tracking, userId is actually the tracking record ID
            .select()
            .single();

        return response;
      }
    } catch (e) {
      print('Error updating user permissions: $e');
      rethrow;
    }
  }

  /// Remove user from organization
  Future<bool> removeUserFromOrganization({
    required String userId,
    required String organizationId,
    bool isRegistered = true,
  }) async {
    try {
      if (isRegistered) {
        // Remove from user_role table
        await _supabase
            .from('user_role')
            .delete()
            .eq('user_id', userId)
            .eq('organization_id', organizationId);
      } else {
        // Remove from user_tracking table
        await _supabase
            .from('user_tracking')
            .delete()
            .eq('id', userId); // For tracking, userId is actually the tracking record ID
      }

      return true;
    } catch (e) {
      print('Error removing user from organization: $e');
      return false;
    }
  }

  /// Get available devices for the organization
  Future<List<Map<String, dynamic>>> getOrganizationDevices(String organizationId) async {
    try {
      print('Fetching devices for organization: $organizationId');
      
      final devices = await _supabase
          .from('devices')
          .select('id, device_name, make, model, serial_number')
          .eq('company_id', organizationId)
          .order('device_name', ascending: true);

      print('Found ${devices.length} devices for organization $organizationId');
      if (devices.isNotEmpty) {
        print('Sample device: ${devices.first}');
      }

      return List<Map<String, dynamic>>.from(devices);
    } catch (e) {
      print('Error fetching organization devices: $e');
      return [];
    }
  }

  /// Helper method to get user ID by email
  Future<String?> getUserIdByEmail(String email) async {
    try {
      final user = await _supabase
          .from('users')
          .select('id')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      return user?['id'];
    } catch (e) {
      return null;
    }
  }

  /// Check if current user can manage organization users
  Future<bool> canManageOrganizationUsers(String userId, String organizationId) async {
    try {
      final userRole = await _supabase
          .from('user_role')
          .select('user_type')
          .eq('user_id', userId)
          .eq('organization_id', organizationId)
          .maybeSingle();

      return userRole != null && 
             (userRole['user_type'] == 'manager' || userRole['user_type'] == 'admin');
    } catch (e) {
      return false;
    }
  }

  /// Get user statistics for organization
  Future<Map<String, int>> getOrganizationUserStats(String organizationId) async {
    try {
      // Count registered users
      final registeredUsers = await _supabase
          .from('user_role')
          .select('id')
          .eq('organization_id', organizationId);

      // Count pending users
      final pendingUsers = await _supabase
          .from('user_tracking')
          .select('id')
          .eq('organization_id', organizationId)
          .eq('is_synced', false);

      // Count managers
      final managers = await _supabase
          .from('user_role')
          .select('id')
          .eq('organization_id', organizationId)
          .inFilter('user_type', ['manager', 'admin']);

      return {
        'total': registeredUsers.length + pendingUsers.length,
        'registered': registeredUsers.length,
        'pending': pendingUsers.length,
        'managers': managers.length,
        'users': (registeredUsers.length - managers.length),
      };
    } catch (e) {
      return {
        'total': 0,
        'registered': 0,
        'pending': 0,
        'managers': 0,
        'users': 0,
      };
    }
  }
}

/// Model classes for user management
class OrganizationUser {
  final String id;
  final String? userId;
  final String email;
  final String userType;
  final dynamic devices;
  final bool isRegistered;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? registrationDate;
  final String? addedBy;

  OrganizationUser({
    required this.id,
    this.userId,
    required this.email,
    required this.userType,
    required this.devices,
    required this.isRegistered,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
    this.registrationDate,
    this.addedBy,
  });

  factory OrganizationUser.fromJson(Map<String, dynamic> json) {
    return OrganizationUser(
      id: json['id'],
      userId: json['user_id'],
      email: json['email'],
      userType: json['user_type'],
      devices: json['devices'],
      isRegistered: json['is_registered'] ?? false,
      isSynced: json['is_synced'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      registrationDate: json['registration_date'] != null 
          ? DateTime.parse(json['registration_date']) 
          : null,
      addedBy: json['added_by'],
    );
  }

  /// Get device access description
  String get deviceAccessDescription {
    if (devices == "all") {
      return "All devices";
    } else if (devices is List && devices.isNotEmpty) {
      return "${devices.length} specific device(s)";
    } else {
      return "No device access";
    }
  }

  /// Get user status description
  String get statusDescription {
    if (isRegistered) {
      return "Active";
    } else {
      return "Pending registration";
    }
  }

  /// Get role display name
  String get roleDisplayName {
    switch (userType) {
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      case 'user':
        return 'User';
      default:
        return userType;
    }
  }
}
