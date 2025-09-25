import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'package:flutter_svg/flutter_svg.dart';
class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
        children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    iconSize: 24,
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            // QCVATION Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SvgPicture.asset(
                'lib/assets/logo.svg',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Main content
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'Choose method to add',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      'New Paramount Device',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryText,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Scan to Add button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                        onPressed: () => _handleScanToAdd(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Scan to Add',
                                    style: AppTextStyles.h3.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Quickly add items by scanning QR code behind the device',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Add Manually button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleAddManually(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          foregroundColor: AppColors.primaryText,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                color: AppColors.tertiaryText,
                                size: 24,
                              ),
                        ),
                        const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Manually',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.primaryText,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enter item details manually for complete control',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Paramount logo at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Image.asset(
                        'lib/assets/Paramount_logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanToAdd() {
    // TODO: Implement QR code scanning functionality
    AppComponents.showInfoSnackbar(context, 'QR Code scanning will be implemented');
  }

  void _handleAddManually() {
    // TODO: Implement manual device entry functionality
    AppComponents.showInfoSnackbar(context, 'Contact Paramount devices to add your device');
  }

}

class ManualAddDeviceScreen extends StatefulWidget {
  const ManualAddDeviceScreen({super.key});

  @override
  State<ManualAddDeviceScreen> createState() => _ManualAddDeviceScreenState();
}

class _ManualAddDeviceScreenState extends State<ManualAddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceNameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedDeviceType = 'DigiPICK™ i11';
  DateTime? _purchaseDate;
  DateTime? _amcStartDate;
  DateTime? _amcEndDate;
  bool _isLoading = false;

  final List<String> _deviceTypes = [
    'DigiPICK™ i11',
    'DigiPICK™ i12',
    'DigiPICK™ i13',
    'Other',
  ];

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    _serialNumberController.dispose();
    _modelController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: AppPaddings.screen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Device',
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Register a new device to your organization',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Device Type Dropdown
                    _buildDropdownField(
                      label: 'Device Type',
                      value: _selectedDeviceType,
                      items: _deviceTypes,
                      onChanged: (value) {
                        setState(() {
                          _selectedDeviceType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Device Name
                    AppComponents.inputField(
                      controller: _deviceNameController,
                      labelText: 'Device Name',
                      hintText: 'Enter device name',
                      prefixIcon: Icons.devices,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Device name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Device ID
                    AppComponents.inputField(
                      controller: _deviceIdController,
                      labelText: 'Device ID',
                      hintText: 'Enter unique device ID',
                      prefixIcon: Icons.tag,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Device ID is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Serial Number
                    AppComponents.inputField(
                      controller: _serialNumberController,
                      labelText: 'Serial Number',
                      hintText: 'Enter serial number',
                      prefixIcon: Icons.numbers,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Serial number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Model
                    AppComponents.inputField(
                      controller: _modelController,
                      labelText: 'Model',
                      hintText: 'Enter device model',
                      prefixIcon: Icons.category,
                    ),
                    const SizedBox(height: 20),
                    
                    // Location
                    AppComponents.inputField(
                      controller: _locationController,
                      labelText: 'Location',
                      hintText: 'Enter device location',
                      prefixIcon: Icons.location_on,
                    ),
                    const SizedBox(height: 20),
                    
                    // Purchase Date
                    _buildDateField(
                      label: 'Purchase Date',
                      date: _purchaseDate,
                      onTap: () => _selectDate(context, 'purchase'),
                    ),
                    const SizedBox(height: 20),
                    
                    // AMC Start Date
                    _buildDateField(
                      label: 'AMC Start Date',
                      date: _amcStartDate,
                      onTap: () => _selectDate(context, 'amc_start'),
                    ),
                    const SizedBox(height: 20),
                    
                    // AMC End Date
                    _buildDateField(
                      label: 'AMC End Date',
                      date: _amcEndDate,
                      onTap: () => _selectDate(context, 'amc_end'),
                    ),
                    const SizedBox(height: 20),
                    
                    // Notes
                    AppComponents.inputField(
                      controller: _notesController,
                      labelText: 'Notes',
                      hintText: 'Additional notes (optional)',
                      prefixIcon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    AppComponents.primaryButton(
                      text: 'Add Device',
                      onPressed: _isLoading ? null : _submitForm,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    
                    // Cancel Button
                    AppComponents.secondaryButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.button,
              borderSide: BorderSide(color: AppColors.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.button,
              borderSide: BorderSide(color: AppColors.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppBorderRadius.button,
              borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please select a device type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dividerColor),
              borderRadius: AppBorderRadius.button,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.tertiaryText),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null 
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: date != null 
                          ? AppColors.primaryText 
                          : AppColors.tertiaryText,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.tertiaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'purchase':
            _purchaseDate = picked;
            break;
          case 'amc_start':
            _amcStartDate = picked;
            break;
          case 'amc_end':
            _amcEndDate = picked;
            break;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement device creation logic
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        AppComponents.showSuccessSnackbar(
          context, 
          'Device added successfully!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppComponents.showErrorSnackbar(
          context, 
          'Failed to add device. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
