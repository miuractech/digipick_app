import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
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
  final CompanyDetails? companyDetails;

  const EditProfileScreen({super.key, this.companyDetails});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // User Profile Controllers (matching design)
  TextEditingController? _firstNameController;
  TextEditingController? _middleNameController;
  TextEditingController? _lastNameController;
  TextEditingController? _phoneController;
  TextEditingController? _companyNameController;
  TextEditingController? _designationController;
  
  // Company Details Controllers
  TextEditingController? _nameController;
  TextEditingController? _legalNameController;
  TextEditingController? _gstController;
  TextEditingController? _panController;
  TextEditingController? _cinController;
  TextEditingController? _emailController;
  TextEditingController? _addressLine1Controller;
  TextEditingController? _addressLine2Controller;
  TextEditingController? _cityController;
  TextEditingController? _stateController;
  TextEditingController? _postalCodeController;
  TextEditingController? _countryController;
  
  File? _profileImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = mounted ? Provider.of<AuthProvider>(context, listen: false) : null;
      final org = authProvider?.organization;
      
      final details = org != null
          ? CompanyDetails(
              name: org['name'],
              legalName: org['legal_name'],
              gstNumber: org['gst_number'],
              panNumber: org['pan_number'],
              cinNumber: org['cin_number'],
              email: org['email'],
              phone: org['phone'],
              addressLine1: org['address_line1'],
              addressLine2: org['address_line2'],
              city: org['city'],
              state: org['state'],
              postalCode: org['postal_code'],
              country: org['country'],
            )
          : (widget.companyDetails ?? CompanyDetails());
      
      setState(() {
        // Initialize user profile fields
        _firstNameController = TextEditingController(text: org?['contact_person']?.split(' ')[0] ?? 'John');
        _middleNameController = TextEditingController(text: 'Middler');
        _lastNameController = TextEditingController(text: org?['contact_person']?.split(' ').last ?? 'Doe');
        _phoneController = TextEditingController(text: org?['phone'] ?? '9876543210');
        _companyNameController = TextEditingController(text: org?['name'] ?? 'ABC Company');
        _designationController = TextEditingController(text: 'CEO, MANAGER, Etc');
        
        // Initialize company details
        _nameController = TextEditingController(text: details.name);
        _legalNameController = TextEditingController(text: details.legalName);
        _gstController = TextEditingController(text: details.gstNumber);
        _panController = TextEditingController(text: details.panNumber);
        _cinController = TextEditingController(text: details.cinNumber);
        _emailController = TextEditingController(text: details.email);
        _addressLine1Controller = TextEditingController(text: details.addressLine1);
        _addressLine2Controller = TextEditingController(text: details.addressLine2);
        _cityController = TextEditingController(text: details.city);
        _stateController = TextEditingController(text: details.state);
        _postalCodeController = TextEditingController(text: details.postalCode);
        _countryController = TextEditingController(text: details.country);
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    // User profile controllers
    _firstNameController?.dispose();
    _middleNameController?.dispose();
    _lastNameController?.dispose();
    _phoneController?.dispose();
    _companyNameController?.dispose();
    _designationController?.dispose();
    
    // Company details controllers
    _nameController?.dispose();
    _legalNameController?.dispose();
    _gstController?.dispose();
    _panController?.dispose();
    _cinController?.dispose();
    _emailController?.dispose();
    _addressLine1Controller?.dispose();
    _addressLine2Controller?.dispose();
    _cityController?.dispose();
    _stateController?.dispose();
    _postalCodeController?.dispose();
    _countryController?.dispose();
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
                    'EDIT ACCOUNT PROFILE',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Picture Section
                  _buildProfilePictureSection(),
                  const SizedBox(height: 32),
                  
                  // User Profile Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField('First Name', _firstNameController!),
                        const SizedBox(height: 16),
                        _buildTextField('Middle Name', _middleNameController!),
                        const SizedBox(height: 16),
                        _buildTextField('Last Name', _lastNameController!),
                        const SizedBox(height: 16),
                        _buildTextField('Phone number', _phoneController!, 
                          keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildTextField('Company Name', _companyNameController!),
                        const SizedBox(height: 16),
                        _buildTextField('Designation', _designationController!),
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

  Widget _buildProfilePictureSection() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organization = authProvider.organization;
    
    return Column(
      children: [
        // Profile Picture
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: _profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: organization != null && organization['name'] != null
                          ? Center(
                              child: Text(
                                organization['name']!.toString().substring(0, 1).toUpperCase(),
                                style: AppTextStyles.h1.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Upload Photo Button
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(
            Icons.cloud_upload,
            color: AppColors.primaryAccent,
            size: 20,
          ),
          label: Text(
            'Upload Photo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }


  Widget _buildTextField(String label, TextEditingController controller, 
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: controller.text.isEmpty ? label : null,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.tertiaryText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      AppComponents.showErrorSnackbar(
        context, 
        'Failed to pick image: $e'
      );
    }
  }

}
