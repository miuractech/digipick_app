import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/service_request_service.dart';
import '../models/service_request.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  
  // Service request fields
  ServiceType _selectedServiceType = ServiceType.service;
  String _selectedDevice = '';
  Map<String, dynamic>? _selectedDeviceData;
  DateTime? _preferredDate;
  ServiceMode _selectedServiceMode = ServiceMode.onSite;
  File? _selectedFile;
  bool _isSubmitting = false;
  
  // Device and user data
  List<Map<String, dynamic>> _userDevices = [];
  bool _isLoadingDevices = false;

  // Services
  final AuthService _authService = AuthService();
  final ServiceRequestService _serviceRequestService = ServiceRequestService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserDevices();
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDevices() async {
    setState(() {
      _isLoadingDevices = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        final devices = await _authService.getDevicesForUser(
          authProvider.user!.id,
        );
        setState(() {
          _userDevices = devices;
          _isLoadingDevices = false;
        });
      } else {
        setState(() {
          _userDevices = [];
          _isLoadingDevices = false;
        });
      }
    } catch (e) {
      setState(() {
        _userDevices = [];
        _isLoadingDevices = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppComponents.universalHeader(
            showBackButton: true,
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTitle(),
                    const SizedBox(height: 24),
                    _buildDeviceSection(),
                    const SizedBox(height: 20),
                    _buildServiceTypeDropdown(),
                    const SizedBox(height: 20),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildServiceModeDropdown(),
                    const SizedBox(height: 20),
                    _buildDetailsSection(),
                    const SizedBox(height: 20),
                    _buildWarningText(),
                    const SizedBox(height: 16),
                    _buildUploadSection(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigation(),
    );
  }


  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RAISE SERVICE REQUEST',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primaryAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome to support',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSection() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: GestureDetector(
        onTap: () => _showDeviceDropdown(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDevice.isEmpty 
                      ? (_userDevices.isEmpty 
                          ? (_isLoadingDevices ? 'Loading devices...' : 'No devices available')
                          : 'Select a device')
                      : _selectedDevice,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedDevice.isEmpty 
                        ? AppColors.tertiaryText 
                        : AppColors.primaryText,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: GestureDetector(
        onTap: () => _showServiceTypeDropdown(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedServiceType.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: GestureDetector(
        onTap: () => _selectDate(context),
          child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
            color: AppColors.cardBackground,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                  _preferredDate != null 
                      ? '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'
                      : 'Preferred Date',
                    style: AppTextStyles.bodyMedium.copyWith(
                    color: _preferredDate != null 
                          ? AppColors.primaryText 
                          : AppColors.tertiaryText,
                    ),
                  ),
                ),
              const Icon(
                Icons.calendar_today,
                color: AppColors.primaryAccent,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: TextFormField(
        controller: _detailsController,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: 'Details of the request*',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        style: AppTextStyles.bodyMedium,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please provide service details';
          }
          if (value.trim().length < 10) {
            return 'Please provide more details (minimum 10 characters)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildWarningText() {
    return Text(
      'I understand servicing charges apply for out of warranty or preventive maintenance services',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.errorColor,
        fontSize: 11,
      ),
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: () => _showImagePicker(),
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
        child: Row(
          children: [
            Icon(
              _selectedFile != null ? Icons.check_circle : Icons.camera_alt,
              color: _selectedFile != null ? Colors.green : AppColors.primaryAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedFile != null 
                    ? 'File selected: ${_selectedFile!.path.split('/').last}'
                    : 'Upload Screenshot / Video',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
            if (_selectedFile != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFile = null;
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: AppColors.errorColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.phone,
            label: 'Call Us',
            onPressed: () => _launchPhone(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.email,
            label: 'Email Us',
            onPressed: () => _launchEmail(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.search,
            label: 'Search FAQs',
            onPressed: () => _searchFAQs(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dividerColor),
      ),
        child: Column(
      children: [
            Icon(
              icon,
              color: AppColors.primaryAccent,
              size: 24,
            ),
            const SizedBox(height: 4),
        Text(
          label,
              style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryText,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomNavigation() {
  //   return Container(
  //     height: 70,
  //     decoration: BoxDecoration(
  //       color: AppColors.cardBackground,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         _buildBottomNavItem(
  //           icon: Icons.apps,
  //           isSelected: _selectedBottomIndex == 0,
  //           onTap: () => _onBottomNavTap(0),
  //         ),
  //         _buildBottomNavItem(
  //           icon: Icons.favorite,
  //           isSelected: _selectedBottomIndex == 1,
  //           onTap: () => _onBottomNavTap(1),
  //         ),
  //         _buildBottomNavItem(
  //           icon: Icons.shopping_cart,
  //           isSelected: _selectedBottomIndex == 2,
  //           onTap: () => _onBottomNavTap(2),
  //         ),
  //         _buildBottomNavItem(
  //           icon: Icons.menu,
  //           isSelected: _selectedBottomIndex == 3,
  //           onTap: () => _onBottomNavTap(3),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildBottomNavItem({
  //   required IconData icon,
  //   required bool isSelected,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //       child: Icon(
  //         icon,
  //         color: isSelected ? AppColors.errorColor : AppColors.tertiaryText,
  //         size: 24,
  //       ),
  //     ),
  //   );
  // }

  void _showDeviceDropdown() {
    if (_userDevices.isEmpty) {
      AppComponents.showInfoSnackbar(
        context,
        _isLoadingDevices 
            ? 'Loading devices, please wait...' 
            : 'No devices available. Please add a device first.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Device',
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    '${_userDevices.length} device(s)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tertiaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_userDevices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.devices_other,
                          size: 48,
                          color: AppColors.tertiaryText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No devices found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.tertiaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please add a device to your organization first',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._userDevices.map((device) {
                  final deviceName = device['device_name'] ?? 'Unknown Device';
                  final serialNumber = device['serial_number'] ?? '';
                  final make = device['make'] ?? '';
                  final model = device['model'] ?? '';
                  
                  final displayName = serialNumber.isNotEmpty 
                      ? '$deviceName S.No $serialNumber'
                      : deviceName;
                  
                  final subtitle = [make, model].where((s) => s.isNotEmpty).join(' ');
                  
                  return ListTile(
                    title: Text(
                      displayName,
                      style: AppTextStyles.bodyMedium,
                    ),
                    subtitle: subtitle.isNotEmpty 
                        ? Text(
                            subtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.tertiaryText,
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedDevice = displayName;
                        _selectedDeviceData = device;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showServiceTypeDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Service Type',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              ...ServiceType.values.map((type) {
                return ListTile(
                  title: Text(type.displayName),
                  onTap: () {
                    setState(() {
                      _selectedServiceType = type;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  const Text('Select Date'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (date) {
                    setState(() {
                      _preferredDate = date;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      // borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
        if (mounted) {
          AppComponents.showSuccessSnackbar(
            context, 
            'Image selected successfully!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context, 
          'Failed to pick image. Please try again.',
        );
      }
    }
  }

  Widget _buildServiceModeDropdown() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: GestureDetector(
        onTap: () => _showServiceModeDropdown(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedServiceMode.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitServiceRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isSubmitting 
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Submit Service Request',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _showServiceModeDropdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Service Mode',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              ...ServiceMode.values.map((mode) {
                return ListTile(
                  title: Text(mode.displayName),
                  subtitle: Text(
                    mode == ServiceMode.onSite 
                        ? 'Engineer will visit your location'
                        : 'Service will be provided remotely',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tertiaryText,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedServiceMode = mode;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitServiceRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDeviceData == null) {
      AppComponents.showErrorSnackbar(
        context,
        'Please select a device',
      );
      return;
    }

    if (_detailsController.text.trim().isEmpty) {
      AppComponents.showErrorSnackbar(
        context,
        'Please provide service details',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      final organization = authProvider.organization;

      if (user == null || organization == null) {
        throw Exception('User or organization not found');
      }

      // Upload file if selected
      String? uploadedFileUrl;
      String? uploadedReference;
      
      if (_selectedFile != null) {
        final fileBytes = Uint8List.fromList(await _selectedFile!.readAsBytes());
        final fileName = _selectedFile!.path.split('/').last;
        final mimeType = fileName.split('.').last;
        
        uploadedFileUrl = await _serviceRequestService.uploadServiceRequestFile(
          fileName,
          fileBytes,
          mimeType,
        );
        
        uploadedReference = mimeType.toLowerCase().contains('jpg') || 
                          mimeType.toLowerCase().contains('png') || 
                          mimeType.toLowerCase().contains('jpeg')
            ? 'image'
            : 'file';
      }

      // Create service request
      final serviceRequest = ServiceRequest(
        ticketNo: '', // Will be generated by the database
        product: _selectedDeviceData!['device_name'] ?? 'Unknown Device',
        serialNo: _selectedDeviceData!['serial_number'] ?? 'N/A',
        serviceType: _selectedServiceType,
        serviceDetails: _detailsController.text.trim(),
        organizationId: organization['id'],
        deviceId: _selectedDeviceData!['id'],
        userId: user.id,
        dateOfRequest: DateTime.now(),
        dateOfService: _preferredDate,
        uploadedReference: uploadedReference,
        uploadedFileUrl: uploadedFileUrl,
        modeOfService: _selectedServiceMode.value,
        status: ServiceStatus.pending,
      );

      final createdRequest = await _serviceRequestService.createServiceRequest(serviceRequest);

      if (createdRequest != null && mounted) {
        AppComponents.showSuccessSnackbar(
          context,
          'Service request submitted successfully! Ticket: ${createdRequest.ticketNo}',
        );
        
        // Clear form
        _detailsController.clear();
        setState(() {
          _selectedDevice = '';
          _selectedDeviceData = null;
          _preferredDate = null;
          _selectedFile = null;
          _selectedServiceType = ServiceType.service;
          _selectedServiceMode = ServiceMode.onSite;
        });
        
        // Navigate back
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create service request');
      }
    } catch (e) {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context,
          'Failed to submit service request: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _launchPhone() async {
    const phoneNumber = 'tel:+1234567890';
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    }
  }

  void _launchEmail() async {
    const email = 'mailto:support@ocvation.com';
    if (await canLaunchUrl(Uri.parse(email))) {
      await launchUrl(Uri.parse(email));
    }
  }

  void _searchFAQs() {
    // Navigate to FAQ screen or show FAQ dialog
    AppComponents.showInfoSnackbar(
      context,
      'FAQ search functionality will be implemented',
    );
  }

}
