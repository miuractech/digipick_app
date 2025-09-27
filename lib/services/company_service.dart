import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get company details by ID
  Future<Map<String, dynamic>?> getCompanyDetails(String companyId) async {
    try {
      final response = await _supabase
          .from('company_details')
          .select('*')
          .eq('id', companyId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching company details: $e');
      return null;
    }
  }

  /// Update company details
  Future<Map<String, dynamic>?> updateCompanyDetails({
    required String companyId,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      // Remove null values to avoid updating with nulls unnecessarily
      final cleanData = <String, dynamic>{};
      companyData.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          cleanData[key] = value;
        }
      });

      // Ensure updated_at is set to current time
      cleanData['updated_at'] = DateTime.now().toUtc().toIso8601String();

      final response = await _supabase
          .from('company_details')
          .update(cleanData)
          .eq('id', companyId)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating company details: $e');
      rethrow;
    }
  }

  /// Create new company details
  Future<Map<String, dynamic>?> createCompanyDetails({
    required Map<String, dynamic> companyData,
  }) async {
    try {
      // Remove null values
      final cleanData = <String, dynamic>{};
      companyData.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          cleanData[key] = value;
        }
      });

      final response = await _supabase
          .from('company_details')
          .insert(cleanData)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating company details: $e');
      rethrow;
    }
  }

  /// Check if current user can update company details
  Future<bool> canUpdateCompanyDetails(String userId, String companyId) async {
    try {
      final userRole = await _supabase
          .from('user_role')
          .select('user_type, organization_id')
          .eq('user_id', userId)
          .eq('organization_id', companyId)
          .maybeSingle();

      return userRole != null && 
             (userRole['user_type'] == 'manager' || userRole['user_type'] == 'admin');
    } catch (e) {
      return false;
    }
  }

  /// Validate company data before saving
  Map<String, String> validateCompanyData(Map<String, dynamic> data) {
    Map<String, String> errors = {};

    // Required fields validation
    if (data['name'] == null || data['name'].toString().trim().isEmpty) {
      errors['name'] = 'Company name is required';
    }

    // GST number validation (if provided)
    if (data['gst_number'] != null && data['gst_number'].toString().trim().isNotEmpty) {
      final gstNumber = data['gst_number'].toString().trim();
      if (gstNumber.length != 15) {
        errors['gst_number'] = 'GST number must be 15 characters';
      }
      // Basic GST format validation (15 alphanumeric characters)
      if (!RegExp(r'^[0-9A-Z]{15}$').hasMatch(gstNumber.toUpperCase())) {
        errors['gst_number'] = 'Invalid GST number format';
      }
    }

    // PAN number validation (if provided)
    if (data['pan_number'] != null && data['pan_number'].toString().trim().isNotEmpty) {
      final panNumber = data['pan_number'].toString().trim();
      if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(panNumber.toUpperCase())) {
        errors['pan_number'] = 'Invalid PAN number format';
      }
    }

    // Email validation (if provided)
    if (data['email'] != null && data['email'].toString().trim().isNotEmpty) {
      final email = data['email'].toString().trim();
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
        errors['email'] = 'Invalid email format';
      }
    }

    // Phone number validation (if provided)
    if (data['phone'] != null && data['phone'].toString().trim().isNotEmpty) {
      final phone = data['phone'].toString().trim();
      if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
        errors['phone'] = 'Phone number must be 10 digits';
      }
    }

    // Postal code validation (if provided)
    if (data['postal_code'] != null && data['postal_code'].toString().trim().isNotEmpty) {
      final postalCode = data['postal_code'].toString().trim();
      if (!RegExp(r'^[0-9]{6}$').hasMatch(postalCode)) {
        errors['postal_code'] = 'Postal code must be 6 digits';
      }
    }

    return errors;
  }
}
