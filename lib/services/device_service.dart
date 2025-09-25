import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class DeviceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  /// Get all devices that the current user has access to based on their user role
  Future<List<Map<String, dynamic>>> getUserDevices() async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Use AuthService to get devices based on user permissions
      return await _authService.getDevicesForUser(user.id);
    } catch (e) {
      print('Error fetching user devices: $e');
      return [];
    }
  }

  /// Legacy method for backward compatibility
  /// Get all devices for the current user's organization
  Future<List<Map<String, dynamic>>> getOrganizationDevices() async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      // Get user role to determine organization
      final userRole = await _authService.getPrimaryUserRole(user.id);
      if (userRole == null) return [];

      final companyId = userRole['organization_id'];

      // Get devices for this organization
      final devices = await _supabase
          .from('devices')
          .select('*')
          .eq('company_id', companyId)
          .order('device_name', ascending: true);

      return List<Map<String, dynamic>>.from(devices);
    } catch (e) {
      print('Error fetching organization devices: $e');
      return [];
    }
  }

  /// Calculate AMC status and days remaining for a device
  Map<String, dynamic> calculateAmcStatus(Map<String, dynamic> device) {
    final now = DateTime.now();
    
    // Parse AMC end date
    final amcEndDateStr = device['amc_end_date'];
    if (amcEndDateStr == null) {
      return {
        'status': 'No AMC',
        'daysLeft': 0,
        'isActive': false,
        'isExpiringSoon': false,
        'expiryDate': null,
      };
    }

    final amcEndDate = DateTime.parse(amcEndDateStr);
    final difference = amcEndDate.difference(now).inDays;

    String status;
    bool isActive = false;
    bool isExpiringSoon = false;

    if (difference < 0) {
      status = 'Expired';
    } else if (difference <= 30) {
      status = 'Expiring Soon';
      isExpiringSoon = true;
    } else {
      status = 'Active';
      isActive = true;
    }

    return {
      'status': status,
      'daysLeft': difference > 0 ? difference : 0,
      'isActive': isActive,
      'isExpiringSoon': isExpiringSoon,
      'expiryDate': amcEndDate,
    };
  }

  /// Calculate warranty status for a device
  Map<String, dynamic> calculateWarrantyStatus(Map<String, dynamic> device) {
    final now = DateTime.now();
    
    // Parse warranty end date
    final warrantyEndDateStr = device['warranty_expiry_date'];
    if (warrantyEndDateStr == null) {
      return {
        'status': 'No Warranty',
        'daysLeft': 0,
        'isActive': false,
        'expiryDate': null,
      };
    }

    final warrantyEndDate = DateTime.parse(warrantyEndDateStr);
    final difference = warrantyEndDate.difference(now).inDays;

    String status;
    bool isActive = false;

    if (difference < 0) {
      status = 'Expired';
    } else if (difference <= 30) {
      status = 'Expiring Soon';
      isActive = true;
    } else {
      status = 'Active';
      isActive = true;
    }

    return {
      'status': status,
      'daysLeft': difference > 0 ? difference : 0,
      'isActive': isActive,
      'expiryDate': warrantyEndDate,
    };
  }

  /// Transform database device to DeviceData model
  DeviceData transformToDeviceData(Map<String, dynamic> deviceMap) {
    final amcStatus = calculateAmcStatus(deviceMap);
    final warrantyStatus = calculateWarrantyStatus(deviceMap);

    return DeviceData(
      id: deviceMap['id'] ?? '',
      name: deviceMap['device_name'] ?? 'Unknown Device',
      deviceId: deviceMap['mac_address'] ?? 'N/A',
      deviceStatus: _getDeviceStatus(deviceMap),
      amcStatus: amcStatus['status'],
      isOnline: _getOnlineStatus(deviceMap), // You might want to implement this based on your requirements
      warrantyExpiryDate: warrantyStatus['expiryDate'] ?? DateTime.now(),
      amcExpiryDate: amcStatus['expiryDate'] ?? DateTime.now(),
      warrantyDaysLeft: warrantyStatus['daysLeft'],
      amcDaysLeft: amcStatus['daysLeft'],
      make: deviceMap['make'] ?? 'Unknown',
      model: deviceMap['model'] ?? 'Unknown',
      serialNumber: deviceMap['serial_number'] ?? 'N/A',
      purchaseDate: deviceMap['purchase_date'] != null 
          ? DateTime.parse(deviceMap['purchase_date']) 
          : DateTime.now(),
      amcStartDate: deviceMap['amc_start_date'] != null 
          ? DateTime.parse(deviceMap['amc_start_date']) 
          : DateTime.now(),
      isAmcActive: amcStatus['isActive'],
      isAmcExpiringSoon: amcStatus['isExpiringSoon'],
      isArchived: deviceMap['is_archived'] ?? false,
    );
  }

  /// Determine device status based on archived status, AMC and warranty
  String _getDeviceStatus(Map<String, dynamic> device) {
    // If device is archived, it's always inactive
    final isArchived = device['is_archived'] ?? false;
    if (isArchived) {
      return 'Inactive';
    }

    final amcStatus = calculateAmcStatus(device);
    final warrantyStatus = calculateWarrantyStatus(device);

    // If AMC is active, device is active
    if (amcStatus['isActive']) {
      return 'Active';
    }

    // If warranty is active but no AMC, still active but might need AMC renewal
    if (warrantyStatus['isActive']) {
      return 'Active';
    }

    // If both expired, inactive
    return 'Inactive';
  }

  /// Get online status - considers archived status and actual device monitoring
  /// For now, this is a placeholder that could be connected to real device monitoring
  bool _getOnlineStatus(Map<String, dynamic> device) {
    // If device is archived, it's always offline
    final isArchived = device['is_archived'] ?? false;
    if (isArchived) {
      return false;
    }

    // Placeholder logic - you can implement actual online status checking here
    // This could be based on last seen timestamp, ping status, etc.
    return true; // Default to online for non-archived devices
  }

  /// Get AMC plans (you can customize these based on your business logic)
  List<AmcPlan> getAmcPlans() {
    return [
      AmcPlan(duration: '1 YEAR', price: '₹4,700.0'),
      AmcPlan(duration: '2 YEAR', price: '₹8,500.0'),
      AmcPlan(duration: '3 YEAR', price: '₹11,999.0'),
      AmcPlan(duration: '4 YEAR', price: '₹16,000.0'),
    ];
  }
}

// Updated DeviceData model
class DeviceData {
  final String id;
  final String name;
  final String deviceId;
  final String deviceStatus;
  final String amcStatus;
  final bool isOnline;
  final DateTime warrantyExpiryDate;
  final DateTime amcExpiryDate;
  final int warrantyDaysLeft;
  final int amcDaysLeft;
  final String make;
  final String model;
  final String serialNumber;
  final DateTime purchaseDate;
  final DateTime amcStartDate;
  final bool isAmcActive;
  final bool isAmcExpiringSoon;
  final bool isArchived;

  DeviceData({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.deviceStatus,
    required this.amcStatus,
    required this.isOnline,
    required this.warrantyExpiryDate,
    required this.amcExpiryDate,
    required this.warrantyDaysLeft,
    required this.amcDaysLeft,
    required this.make,
    required this.model,
    required this.serialNumber,
    required this.purchaseDate,
    required this.amcStartDate,
    required this.isAmcActive,
    required this.isAmcExpiringSoon,
    this.isArchived = false,
  });
}

class AmcPlan {
  final String duration;
  final String price;

  AmcPlan({
    required this.duration,
    required this.price,
  });
}
