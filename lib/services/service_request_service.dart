import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/service_request.dart';

/// Service Request Service
/// 
/// This service handles all database operations related to service requests.

class ServiceRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create a new service request
  Future<ServiceRequest?> createServiceRequest(ServiceRequest request) async {
    try {
      // Generate ticket number using the database function
      final ticketResponse = await _supabase.rpc('generate_ticket_number', params: {
        'org_id': request.organizationId,
        'dev_id': request.deviceId,
      });

      if (ticketResponse == null) {
        throw Exception('Failed to generate ticket number');
      }

      // Create service request with generated ticket number
      final requestData = request.copyWith(ticketNo: ticketResponse).toJson();
      
      final response = await _supabase
          .from('service_requests')
          .insert(requestData)
          .select()
          .single();

      return ServiceRequest.fromJson(response);
    } catch (e) {
      print('Error creating service request: $e');
      return null;
    }
  }

  /// Get all service requests for a specific organization
  Future<List<ServiceRequest>> getOrganizationServiceRequests(String organizationId) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('''
            *,
            devices!inner(device_name, serial_number, make, model),
            company_details!inner(name)
          ''')
          .eq('organization_id', organizationId)
          .order('date_of_request', ascending: false);

      List<ServiceRequest> serviceRequests = response
          .map<ServiceRequest>((json) => ServiceRequest.fromJson(json))
          .toList();

      // Fetch engineer details for each request
      for (int i = 0; i < serviceRequests.length; i++) {
        if (serviceRequests[i].serviceEngineer != null) {
          final engineerDetails = await _getEngineerDetails(serviceRequests[i].serviceEngineer!);
          if (engineerDetails != null) {
            serviceRequests[i] = serviceRequests[i].copyWith(
              engineerName: engineerDetails['name'],
              engineerEmail: engineerDetails['email'],
              engineerPhone: engineerDetails['contact_number'],
            );
          }
        }
      }

      return serviceRequests;
    } catch (e) {
      print('Error fetching organization service requests: $e');
      return [];
    }
  }

  /// Get service requests for a specific user
  Future<List<ServiceRequest>> getUserServiceRequests(String userId) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('''
            *,
            devices!inner(device_name, serial_number, make, model),
            company_details!inner(name)
          ''')
          .eq('user_id', userId)
          .order('date_of_request', ascending: false);

      List<ServiceRequest> serviceRequests = response
          .map<ServiceRequest>((json) => ServiceRequest.fromJson(json))
          .toList();

      // Fetch engineer details for each request
      for (int i = 0; i < serviceRequests.length; i++) {
        if (serviceRequests[i].serviceEngineer != null) {
          final engineerDetails = await _getEngineerDetails(serviceRequests[i].serviceEngineer!);
          if (engineerDetails != null) {
            serviceRequests[i] = serviceRequests[i].copyWith(
              engineerName: engineerDetails['name'],
              engineerEmail: engineerDetails['email'],
              engineerPhone: engineerDetails['contact_number'],
            );
          }
        }
      }

      return serviceRequests;
    } catch (e) {
      print('Error fetching user service requests: $e');
      return [];
    }
  }

  /// Get a specific service request by ID
  Future<ServiceRequest?> getServiceRequestById(String id) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('''
            *,
            devices!inner(device_name, serial_number, make, model),
            company_details!inner(name)
          ''')
          .eq('id', id)
          .single();

      ServiceRequest serviceRequest = ServiceRequest.fromJson(response);

      // Fetch engineer details if assigned
      if (serviceRequest.serviceEngineer != null) {
        final engineerDetails = await _getEngineerDetails(serviceRequest.serviceEngineer!);
        if (engineerDetails != null) {
          serviceRequest = serviceRequest.copyWith(
            engineerName: engineerDetails['name'],
            engineerEmail: engineerDetails['email'],
            engineerPhone: engineerDetails['contact_number'],
          );
        }
      }

      return serviceRequest;
    } catch (e) {
      print('Error fetching service request: $e');
      return null;
    }
  }

  /// Get a service request by ticket number
  Future<ServiceRequest?> getServiceRequestByTicketNo(String ticketNo) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('''
            *,
            devices!inner(device_name, serial_number, make, model),
            company_details!inner(name)
          ''')
          .eq('ticket_no', ticketNo)
          .single();

      ServiceRequest serviceRequest = ServiceRequest.fromJson(response);

      // Fetch engineer details if assigned
      if (serviceRequest.serviceEngineer != null) {
        final engineerDetails = await _getEngineerDetails(serviceRequest.serviceEngineer!);
        if (engineerDetails != null) {
          serviceRequest = serviceRequest.copyWith(
            engineerName: engineerDetails['name'],
            engineerEmail: engineerDetails['email'],
            engineerPhone: engineerDetails['contact_number'],
          );
        }
      }

      return serviceRequest;
    } catch (e) {
      print('Error fetching service request by ticket number: $e');
      return null;
    }
  }

  /// Update a service request
  Future<ServiceRequest?> updateServiceRequest(String id, ServiceRequest updatedRequest) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .update(updatedRequest.toJson())
          .eq('id', id)
          .select()
          .single();

      return ServiceRequest.fromJson(response);
    } catch (e) {
      print('Error updating service request: $e');
      return null;
    }
  }

  /// Update service request status
  Future<bool> updateServiceRequestStatus(String id, ServiceStatus status) async {
    try {
      await _supabase
          .from('service_requests')
          .update({'status': status.value})
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error updating service request status: $e');
      return false;
    }
  }

  /// Delete a service request
  Future<bool> deleteServiceRequest(String id) async {
    try {
      await _supabase
          .from('service_requests')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting service request: $e');
      return false;
    }
  }

  /// Upload file for service request
  Future<String?> uploadServiceRequestFile(String fileName, Uint8List fileBytes, String mimeType) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'service_requests/${timestamp}_$fileName';

      await _supabase.storage
          .from('service-files')
          .uploadBinary(uniqueFileName, fileBytes);

      final url = _supabase.storage
          .from('service-files')
          .getPublicUrl(uniqueFileName);

      return url;
    } catch (e) {
      print('Error uploading service request file: $e');
      return null;
    }
  }

  /// Get service requests statistics for dashboard
  Future<Map<String, int>> getServiceRequestStats(String organizationId) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('status')
          .eq('organization_id', organizationId);

      final stats = <String, int>{
        'total': response.length,
        'pending': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (final request in response) {
        final status = request['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      print('Error fetching service request statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'completed': 0,
        'cancelled': 0,
      };
    }
  }

  /// Search service requests
  Future<List<ServiceRequest>> searchServiceRequests({
    required String organizationId,
    String? searchQuery,
    ServiceType? serviceType,
    ServiceStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var query = _supabase
          .from('service_requests')
          .select('''
            *,
            devices!inner(device_name, serial_number, make, model),
            company_details!inner(name)
          ''')
          .eq('organization_id', organizationId);

      if (serviceType != null) {
        query = query.eq('service_type', serviceType.value);
      }

      if (status != null) {
        query = query.eq('status', status.value);
      }

      if (fromDate != null) {
        query = query.gte('date_of_request', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('date_of_request', toDate.toIso8601String());
      }

      final response = await query.order('date_of_request', ascending: false);

      var serviceRequests = response
          .map<ServiceRequest>((json) => ServiceRequest.fromJson(json))
          .toList();

      // Apply text search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        serviceRequests = serviceRequests.where((request) {
          return request.ticketNo.toLowerCase().contains(lowercaseQuery) ||
                 request.product.toLowerCase().contains(lowercaseQuery) ||
                 request.serialNo.toLowerCase().contains(lowercaseQuery) ||
                 request.serviceDetails.toLowerCase().contains(lowercaseQuery);
        }).toList();
      }

      return serviceRequests;
    } catch (e) {
      print('Error searching service requests: $e');
      return [];
    }
  }

  /// Get pending service requests count for notifications
  Future<int> getPendingServiceRequestsCount(String organizationId) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select()
          .eq('organization_id', organizationId)
          .eq('status', 'pending');

      return response.length;
    } catch (e) {
      print('Error fetching pending service requests count: $e');
      return 0;
    }
  }

  /// Get service requests for a specific device with pagination
  Future<List<ServiceRequest>> getDeviceServiceRequests(
    String deviceId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('''
            *,
            devices!inner(device_name, serial_number, make, model),
            company_details!inner(name)
          ''')
          .eq('device_id', deviceId)
          .order('date_of_request', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<ServiceRequest>((json) => ServiceRequest.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching device service requests: $e');
      return [];
    }
  }

  /// Get count of service requests for a specific device
  Future<int> getDeviceServiceRequestsCount(String deviceId) async {
    try {
      final response = await _supabase
          .from('service_requests')
          .select('id')
          .eq('device_id', deviceId);

      return response.length;
    } catch (e) {
      print('Error fetching device service requests count: $e');
      return 0;
    }
  }

  /// Get engineer details by engineer ID or email
  Future<Map<String, dynamic>?> _getEngineerDetails(String engineerIdentifier) async {
    try {
      // Try to find engineer by ID first (UUID format)
      if (_isValidUUID(engineerIdentifier)) {
        var response = await _supabase
            .from('service_engineers')
            .select('name, email, contact_number, expertise, comments')
            .eq('id', engineerIdentifier)
            .maybeSingle();

        if (response != null) {
          return response;
        }
      }

      // If not found by ID or not a valid UUID, try by email
      var response = await _supabase
          .from('service_engineers')
          .select('name, email, contact_number, expertise, comments')
          .eq('email', engineerIdentifier)
          .maybeSingle();

      if (response != null) {
        return response;
      }

      // If still not found, try by name (partial match)
      response = await _supabase
          .from('service_engineers')
          .select('name, email, contact_number, expertise, comments')
          .ilike('name', '%$engineerIdentifier%')
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching engineer details: $e');
      return null;
    }
  }

  /// Check if a string is a valid UUID
  bool _isValidUUID(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    return uuidRegex.hasMatch(value);
  }

  /// Get all available service engineers
  Future<List<Map<String, dynamic>>> getAvailableServiceEngineers() async {
    try {
      final response = await _supabase
          .from('service_engineers')
          .select('id, name, email, contact_number, expertise, comments')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching service engineers: $e');
      return [];
    }
  }
}
