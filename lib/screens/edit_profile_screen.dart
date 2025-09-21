import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  TextEditingController? _nameController;
  TextEditingController? _legalNameController;
  TextEditingController? _gstController;
  TextEditingController? _panController;
  TextEditingController? _cinController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;
  TextEditingController? _addressLine1Controller;
  TextEditingController? _addressLine2Controller;
  TextEditingController? _cityController;
  TextEditingController? _stateController;
  TextEditingController? _postalCodeController;
  TextEditingController? _countryController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final org = mounted ? Provider.of<AuthProvider>(context, listen: false).organization : null;
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
        _nameController = TextEditingController(text: details.name);
        _legalNameController = TextEditingController(text: details.legalName);
        _gstController = TextEditingController(text: details.gstNumber);
        _panController = TextEditingController(text: details.panNumber);
        _cinController = TextEditingController(text: details.cinNumber);
        _emailController = TextEditingController(text: details.email);
        _phoneController = TextEditingController(text: details.phone);
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
    _nameController?.dispose();
    _legalNameController?.dispose();
    _gstController?.dispose();
    _panController?.dispose();
    _cinController?.dispose();
    _emailController?.dispose();
    _phoneController?.dispose();
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: AppComponents.iconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
          iconColor: AppColors.primaryText,
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.h2,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSection('Company Information', [
                        _buildTextField('Company Name', _nameController!),
                        _buildTextField('Legal Name', _legalNameController!),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Tax Information', [
                        _buildTextField('GST Number', _gstController!),
                        _buildTextField('PAN Number', _panController!),
                        _buildTextField('CIN Number', _cinController!),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Contact Information', [
                        _buildTextField('Email', _emailController!, 
                          keyboardType: TextInputType.emailAddress),
                        _buildTextField('Phone', _phoneController!, 
                          keyboardType: TextInputType.phone),
                      ]),
                      const SizedBox(height: 24),
                      _buildSection('Address Information', [
                        _buildTextField('Address Line 1', _addressLine1Controller!),
                        _buildTextField('Address Line 2', _addressLine2Controller!),
                        _buildTextField('City', _cityController!),
                        _buildTextField('State', _stateController!),
                        _buildTextField('Postal Code', _postalCodeController!),
                        _buildTextField('Country', _countryController!),
                      ]),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: AppShadows.card,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.button,
                      ),
                    ),
                    child: Text(
                      'Save Profile',
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 20),
          ...fields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: field,
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, 
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: AppColors.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: AppColors.primaryAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.lg),
        filled: true,
        fillColor: AppColors.backgroundColor,
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save to database (company_details table)
      // This would typically involve calling an API or database service
      
      Navigator.pop(context);
      AppComponents.showSuccessSnackbar(
        context, 
        'Profile updated successfully!'
      );
    }
  }
}
