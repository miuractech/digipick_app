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

  Future<bool> checkOrganizationEmail(String email) async {
    try {
      final response = await _supabase
          .from('company_details')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getOrganizationByEmail(String email) async {
    try {
      final response = await _supabase
          .from('company_details')
          .select('*')
          .eq('email', email)
          .maybeSingle();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDevicesForOrganization(String companyId, {String? searchQuery}) async {
    try {
      var query = _supabase
          .from('devices')
          .select('*')
          .eq('company_id', companyId);
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('device_name.ilike.%$searchQuery%,make.ilike.%$searchQuery%,model.ilike.%$searchQuery%,serial_number.ilike.%$searchQuery%,mac_address.ilike.%$searchQuery%');
      }
      
      final response = await query.order('device_name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

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

  Future<List<String>> _getDeviceIdsForCompany(String companyId) async {
    try {
      final devices = await _supabase
          .from('devices')
          .select('id')
          .eq('company_id', companyId);
      
      return devices.map<String>((device) => device['id'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}
