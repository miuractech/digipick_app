import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<bool> checkUserAuthorization(String userId) async {
    try {
      final response = await _supabase
          .from('user_role')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserRoles(String userId) async {
    try {
      final response = await _supabase
          .from('user_role')
          .select('''
            *,
            organization:company_details!user_role_organization_id_fkey(*)
          ''')
          .eq('user_id', userId);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPrimaryUserRole(String userId) async {
    try {
      final roles = await getUserRoles(userId);
      
      if (roles.isEmpty) return null;
      
      // Prioritize manager/admin roles first, then return the first available role
      final managerRole = roles.firstWhere(
        (role) => role['user_type'] == 'manager' || role['user_type'] == 'admin',
        orElse: () => roles.first,
      );
      
      return managerRole;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDevicesForUser(String userId, {String? searchQuery}) async {
    try {
      final userRole = await getPrimaryUserRole(userId);
      if (userRole == null) return [];
      
      final companyId = userRole['organization_id'];
      final devices = userRole['devices'];
      
      var query = _supabase
          .from('devices')
          .select('*')
          .eq('company_id', companyId)
          .eq('archived', false);
      
      // Filter devices based on user permissions
      if (devices != "all") {
        if (devices is List && devices.isNotEmpty) {
          // User has access to specific devices only
          query = query.inFilter('id', devices);
        } else {
          // User has no device access
          return [];
        }
      }
      // If devices == "all", show all company devices (no additional filter needed)
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('device_name.ilike.%$searchQuery%,make.ilike.%$searchQuery%,model.ilike.%$searchQuery%,serial_number.ilike.%$searchQuery%,mac_address.ilike.%$searchQuery%');
      }
      
      final response = await query.order('device_name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Legacy method for backward compatibility
  Future<List<Map<String, dynamic>>> getDevicesForOrganization(String companyId, {String? searchQuery}) async {
    try {
      var query = _supabase
          .from('devices')
          .select('*')
          .eq('company_id', companyId)
          .eq('archived', false);
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('device_name.ilike.%$searchQuery%,make.ilike.%$searchQuery%,model.ilike.%$searchQuery%,serial_number.ilike.%$searchQuery%,mac_address.ilike.%$searchQuery%');
      }
      
      final response = await query.order('device_name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, int>> getDeviceStatisticsForUser(String userId) async {
    try {
      final devices = await getDevicesForUser(userId);
      final totalDevices = devices.length;
      
      // Calculate active devices (devices with valid AMC or warranty)
      final now = DateTime.now();
      int activeDevices = 0;
      
      for (var device in devices) {
        final amcEndDate = device['amc_end_date'] != null 
            ? DateTime.parse(device['amc_end_date']) 
            : null;
        final warrantyEndDate = device['warranty_expiry_date'] != null 
            ? DateTime.parse(device['warranty_expiry_date']) 
            : null;
        
        if ((amcEndDate != null && amcEndDate.isAfter(now)) ||
            (warrantyEndDate != null && warrantyEndDate.isAfter(now))) {
          activeDevices++;
        }
      }
      
      return {
        'total': totalDevices,
        'active': activeDevices,
        'inactive': totalDevices - activeDevices,
      };
    } catch (e) {
      return {'total': 0, 'active': 0, 'inactive': 0};
    }
  }

  // Legacy method for backward compatibility
  Future<Map<String, int>> getDeviceStatistics(String companyId) async {
    try {
      final devices = await getDevicesForOrganization(companyId);
      final totalDevices = devices.length;
      
      // Calculate active devices (devices with valid AMC or warranty)
      final now = DateTime.now();
      int activeDevices = 0;
      
      for (var device in devices) {
        final amcEndDate = device['amc_end_date'] != null 
            ? DateTime.parse(device['amc_end_date']) 
            : null;
        final warrantyEndDate = device['warranty_expiry_date'] != null 
            ? DateTime.parse(device['warranty_expiry_date']) 
            : null;
        
        if ((amcEndDate != null && amcEndDate.isAfter(now)) ||
            (warrantyEndDate != null && warrantyEndDate.isAfter(now))) {
          activeDevices++;
        }
      }
      
      return {
        'total': totalDevices,
        'active': activeDevices,
        'inactive': totalDevices - activeDevices,
      };
    } catch (e) {
      return {'total': 0, 'active': 0, 'inactive': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getDeviceTestsForUser({
    required String userId,
    String? deviceId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('device_test').select('*');

      // Get device IDs that user has access to
      final deviceIds = await _getDeviceIdsForUser(userId);
      if (deviceIds.isEmpty) {
        return []; // User has no device access
      }
      
      // If a specific deviceId is provided, check if user has access to it
      if (deviceId != null) {
        if (deviceIds.contains(deviceId)) {
          query = query.eq('device_id', deviceId);
        } else {
          return []; // User doesn't have access to this device
        }
      } else {
        // Filter to only include tests from devices user has access to
        query = query.inFilter('device_id', deviceIds);
      }

      if (status != null) {
        query = query.eq('test_status', status);
      }

      if (startDate != null) {
        query = query.gte('test_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('test_date', endDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Legacy method for backward compatibility
  Future<List<Map<String, dynamic>>> getDeviceTests({
    String? companyId,
    String? deviceId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase.from('device_test').select('*');

      // First filter by company devices if companyId is provided
      if (companyId != null) {
        final deviceIds = await _getDeviceIdsForCompany(companyId);
        if (deviceIds.isEmpty) {
          return []; // No devices for this company
        }
        
        // If a specific deviceId is provided, use it; otherwise use all company devices
        if (deviceId != null) {
          if (deviceIds.contains(deviceId)) {
            query = query.eq('device_id', deviceId);
          } else {
            return []; // Requested device doesn't belong to this company
          }
        } else {
          // Filter to only include tests from company devices
          query = query.inFilter('device_id', deviceIds);
        }
      } else if (deviceId != null) {
        // If no company filter but specific device requested
        query = query.eq('device_id', deviceId);
      }

      if (status != null) {
        query = query.eq('test_status', status);
      }

      if (startDate != null) {
        query = query.gte('test_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('test_date', endDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getDeviceIdsForUser(String userId) async {
    try {
      final userRole = await getPrimaryUserRole(userId);
      if (userRole == null) return [];
      
      final devices = userRole['devices'];
      final companyId = userRole['organization_id'];
      
      if (devices == "all") {
        // User has access to all devices in the organization
        return await _getDeviceIdsForCompany(companyId);
      } else if (devices is List && devices.isNotEmpty) {
        // User has access to specific devices
        return devices.cast<String>();
      } else {
        // User has no device access
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getDeviceIdsForCompany(String companyId) async {
    try {
      final devices = await _supabase
          .from('devices')
          .select('id')
          .eq('company_id', companyId)
          .eq('archived', false);
      
      return devices.map<String>((device) => device['id'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // Simplified method for getting all tests for a single device (used by stats page)
  Future<List<Map<String, dynamic>>> getAllDeviceTests(String deviceId) async {
    try {
      final response = await _supabase
          .from('device_test')
          .select('*')
          .eq('device_id', deviceId)
          .order('test_date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
