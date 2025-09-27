import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/company_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';

class CompanyDetails {
  String? name;
  String? legalName;
  String? gstNumber;
  String? panNumber;
  String? cinNumber;
  String? email;
  String? phone;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? state;
  String? postalCode;
  String? country;

  CompanyDetails({
    this.name,
    this.legalName,
    this.gstNumber,
    this.panNumber,
    this.cinNumber,
    this.email,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country = 'India',
  });
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final CompanyService _companyService = CompanyService();
  
  // Company Details Controllers
  late TextEditingController _nameController;
  late TextEditingController _legalNameController;
  late TextEditingController _gstController;
  late TextEditingController _panController;
  late TextEditingController _cinController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  
  bool _loading = true;
  bool _saving = false;
  Map<String, String> _validationErrors = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyDetails();
    });
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _legalNameController = TextEditingController();
    _gstController = TextEditingController();
    _panController = TextEditingController();
    _cinController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController(text: 'India');
  }

  Future<void> _loadCompanyDetails() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organization = authProvider.organization;
    
    if (organization != null) {
      setState(() {
        _nameController.text = organization['name'] ?? '';
        _legalNameController.text = organization['legal_name'] ?? '';
        _gstController.text = organization['gst_number'] ?? '';
        _panController.text = organization['pan_number'] ?? '';
        _cinController.text = organization['cin_number'] ?? '';
        _emailController.text = organization['email'] ?? '';
        _phoneController.text = organization['phone'] ?? '';
        _addressLine1Controller.text = organization['address_line1'] ?? '';
        _addressLine2Controller.text = organization['address_line2'] ?? '';
        _cityController.text = organization['city'] ?? '';
        _stateController.text = organization['state'] ?? '';
        _postalCodeController.text = organization['postal_code'] ?? '';
        _countryController.text = organization['country'] ?? 'India';
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _legalNameController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _cinController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'EDIT COMPANY PROFILE',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Company Details Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          'Company Name *', 
                          _nameController,
                          required: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Legal Name', _legalNameController),
                        const SizedBox(height: 16),
                        _buildTextField('GST Number', _gstController),
                        const SizedBox(height: 16),
                        _buildTextField('PAN Number', _panController),
                        const SizedBox(height: 16),
                        _buildTextField('CIN Number', _cinController),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Email', 
                          _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Phone Number', 
                          _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Address Line 1', _addressLine1Controller),
                        const SizedBox(height: 16),
                        _buildTextField('Address Line 2', _addressLine2Controller),
                        const SizedBox(height: 16),
                        _buildTextField('City', _cityController),
                        const SizedBox(height: 16),
                        _buildTextField('State', _stateController),
                        const SizedBox(height: 16),
                        _buildTextField(
                          'Postal Code', 
                          _postalCodeController,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Country', _countryController),
                        const SizedBox(height: 32),
                        
                        // Save Button
                        _buildSaveButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool required = false,
  }) {
    final fieldKey = label.toLowerCase().replaceAll(' ', '_').replaceAll('*', '');
    final hasError = _validationErrors.containsKey(fieldKey);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: required ? AppColors.primaryAccent : AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: controller.text.isEmpty ? label.replaceAll(' *', '') : null,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.primaryAccent, 
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
            errorText: _validationErrors[fieldKey],
          ),
          style: AppTextStyles.bodyMedium,
          validator: required ? (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _saveCompanyDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _saving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'SAVE CHANGES',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _saveCompanyDetails() async {
    // Clear previous validation errors
    setState(() {
      _validationErrors = {};
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organization = authProvider.organization;
      
      if (organization == null || organization['id'] == null) {
        throw 'Company information not found';
      }

      final companyId = organization['id'];
      final userId = authProvider.user?.id;
      
      if (userId == null) {
        throw 'User not authenticated';
      }

      // Check if user can update company details
      final canUpdate = await _companyService.canUpdateCompanyDetails(userId, companyId);
      if (!canUpdate) {
        throw 'You do not have permission to update company details';
      }

      // Prepare company data
      final companyData = {
        'name': _nameController.text.trim(),
        'legal_name': _legalNameController.text.trim().isEmpty ? null : _legalNameController.text.trim(),
        'gst_number': _gstController.text.trim().isEmpty ? null : _gstController.text.trim().toUpperCase(),
        'pan_number': _panController.text.trim().isEmpty ? null : _panController.text.trim().toUpperCase(),
        'cin_number': _cinController.text.trim().isEmpty ? null : _cinController.text.trim().toUpperCase(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'address_line1': _addressLine1Controller.text.trim().isEmpty ? null : _addressLine1Controller.text.trim(),
        'address_line2': _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
        'city': _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        'state': _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        'postal_code': _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        'country': _countryController.text.trim().isEmpty ? 'India' : _countryController.text.trim(),
      };

      // Validate data
      final validationErrors = _companyService.validateCompanyData(companyData);
      if (validationErrors.isNotEmpty) {
        setState(() {
          _validationErrors = validationErrors;
        });
        return;
      }

      // Update company details
      await _companyService.updateCompanyDetails(
        companyId: companyId,
        companyData: companyData,
      );

      // Refresh auth provider data
      await authProvider.recheckAuthorization();

      if (mounted) {
        AppComponents.showSuccessSnackbar(
          context,
          'Company details updated successfully',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Failed to update company details: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
