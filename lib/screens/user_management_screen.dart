import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/user_management_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../widgets/device_selection_widget.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserManagementService _userManagementService = UserManagementService();
  List<Map<String, dynamic>> _organizationUsers = [];
  List<Map<String, dynamic>> _organizationDevices = [];
  bool _isLoading = true;
  bool _canManage = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizationId = authProvider.primaryUserRole?['organization_id'];
    final userId = authProvider.user?.id;

    print('Loading data for organization: $organizationId, user: $userId');
    print('Primary user role: ${authProvider.primaryUserRole}');

    // Test if username column exists
    final usernameColumnExists = await _userManagementService.testUsernameColumnExists();
    print('Username column exists in database: $usernameColumnExists');

    if (organizationId != null && userId != null) {
      final canManage = await _userManagementService.canManageOrganizationUsers(userId, organizationId);
      
      print('Can manage users: $canManage');
      
      if (canManage) {
        final [users, devices] = await Future.wait([
          _userManagementService.getOrganizationUsers(organizationId),
          _userManagementService.getOrganizationDevices(organizationId),
        ]);

        print('Loaded ${users.length} users and ${devices.length} devices');
        
        // Debug username data
        for (var user in users) {
          print('User: ${user['email']}, Username: ${user['username']}, Is Registered: ${user['is_registered']}');
        }

        setState(() {
          _organizationUsers = users;
          _organizationDevices = devices;
          _canManage = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _canManage = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Users',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? AppComponents.loadingIndicator()
          : !_canManage
              ? _buildNoPermissionView()
              : _buildUserManagementView(),
    );
  }

  Widget _buildNoPermissionView() {
    return AppComponents.emptyState(
      icon: Icons.admin_panel_settings_outlined,
      title: 'Access Restricted',
    );
  }

  Widget _buildUserManagementView() {
    return Column(
      children: [
        // Stats Card
        _buildStatsCard(),
        
        // Add User Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddUserDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.button,
                ),
              ),
            ),
          ),
        ),
        
        // Users List
        Expanded(
          child: _organizationUsers.isEmpty
              ? AppComponents.emptyState(
                  icon: Icons.group_outlined,
                  title: 'No Users',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _organizationUsers.length,
                  itemBuilder: (context, index) {
                    final user = _organizationUsers[index];
                    return _buildUserCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final stats = _calculateStats();
    
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total Users', stats['total'].toString(), AppColors.primaryAccent),
          ),
          Expanded(
            child: _buildStatItem('Active', stats['registered'].toString(), AppColors.successColor),
          ),
          Expanded(
            child: _buildStatItem('Pending', stats['pending'].toString(), AppColors.warningColor),
          ),
          Expanded(
            child: _buildStatItem('Managers', stats['managers'].toString(), AppColors.secondaryAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.secondaryText,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isRegistered = user['is_registered'] ?? false;
    final userType = user['user_type'] ?? 'user';
    final devices = user['devices'];
    
    String deviceAccess;
    if (devices == "all") {
      deviceAccess = "All devices";
    } else if (devices is List && devices.isNotEmpty) {
      deviceAccess = "${devices.length} device(s)";
    } else {
      deviceAccess = "No access";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorderRadius.card,
        boxShadow: AppShadows.card,
        border: Border.all(
          color: isRegistered ? Colors.transparent : AppColors.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isRegistered ? AppColors.successColor : AppColors.warningColor,
                child: Icon(
                  isRegistered ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user['username'] != null && user['username'].toString().isNotEmpty) ...[
                      Text(
                        user['username'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user['email'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ] else
                      Text(
                        user['email'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(userType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getRoleDisplayName(userType),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _getRoleColor(userType),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isRegistered ? AppColors.successColor : AppColors.warningColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isRegistered ? 'Active' : 'Pending',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isRegistered ? AppColors.successColor : AppColors.warningColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(value, user),
                itemBuilder: (context) {
                  final isManager = ['admin', 'manager'].contains(userType);
                  return [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 16),
                          const SizedBox(width: 8),
                          Text(isManager ? 'Edit Username' : 'Edit Device Access'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Remove User', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.devices,
                size: 16,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                'Device Access: $deviceAccess',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          if (!isRegistered) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.warningColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'User invitation sent. Waiting for registration.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warningColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor(String userType) {
    switch (userType) {
      case 'admin':
        return AppColors.errorColor;
      case 'manager':
        return AppColors.secondaryAccent;
      default:
        return AppColors.primaryAccent;
    }
  }

  String _getRoleDisplayName(String userType) {
    switch (userType) {
      case 'admin':
        return 'Admin';
      case 'manager':
        return 'Manager';
      default:
        return 'User';
    }
  }

  Map<String, int> _calculateStats() {
    int total = _organizationUsers.length;
    int registered = _organizationUsers.where((user) => user['is_registered'] ?? false).length;
    int pending = total - registered;
    int managers = _organizationUsers.where((user) => 
        ['admin', 'manager'].contains(user['user_type'])).length;

    return {
      'total': total,
      'registered': registered,
      'pending': pending,
      'managers': managers,
    };
  }

  void _showAddUserDialog() {
    print('Opening add user dialog with ${_organizationDevices.length} devices');
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        organizationDevices: _organizationDevices,
        onUserAdded: () {
          _loadData();
        },
      ),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    switch (action) {
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'remove':
        _showRemoveUserDialog(user);
        break;
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        organizationDevices: _organizationDevices,
        onUserUpdated: () {
          _loadData();
        },
      ),
    );
  }

  void _showRemoveUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${user['email']} from the organization?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeUser(user);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeUser(Map<String, dynamic> user) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationId = authProvider.primaryUserRole?['organization_id'];
      
      if (organizationId != null) {
        final success = await _userManagementService.removeUserFromOrganization(
          userId: user['user_id'] ?? user['id'], // Use user_id for registered users, id for tracking
          organizationId: organizationId,
          isRegistered: user['is_registered'] ?? false,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user['email']} has been removed from the organization'),
              backgroundColor: AppColors.successColor,
            ),
          );
          _loadData();
        } else {
          throw Exception('Failed to remove user');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing user: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }
}

// Add User Dialog Widget
class AddUserDialog extends StatefulWidget {
  final List<Map<String, dynamic>> organizationDevices;
  final VoidCallback onUserAdded;

  const AddUserDialog({
    super.key,
    required this.organizationDevices,
    required this.onUserAdded,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  String _deviceAccessType = 'none'; // 'all', 'specific', 'none'
  List<String> _selectedDeviceIds = [];
  bool _isLoading = false;
  bool _isCheckingEmail = false;
  String? _emailError;

  Timer? _emailDebounceTimer;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    // Clear previous email error when user starts typing
    if (_emailError != null) {
      setState(() {
        _emailError = null;
      });
    }

    // Cancel previous timer
    _emailDebounceTimer?.cancel();
    
    // Start new timer to check email after user stops typing
    _emailDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      _checkEmailDuplicate(_emailController.text.trim());
    });
  }

  Future<void> _checkEmailDuplicate(String email) async {
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) return;
    
    setState(() {
      _isCheckingEmail = true;
      _emailError = null;
    });

    try {
      final userManagementService = UserManagementService();
      final errorMessage = await userManagementService.checkEmailDuplicate(email);
      
      setState(() {
        _emailError = errorMessage;
      });
    } catch (e) {
      setState(() {
        _emailError = 'Error checking email availability';
      });
    } finally {
      setState(() {
        _isCheckingEmail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AddUserDialog build - organizationDevices count: ${widget.organizationDevices.length}');
    
    return AlertDialog(
      title: const Text('Add User'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          height: 600, // Fixed height to accommodate device selection
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'user@example.com',
                      suffixIcon: _isCheckingEmail
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _emailError != null
                              ? const Icon(Icons.error, color: Colors.red)
                              : _emailController.text.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _emailError != null ? Colors.red : Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _emailError != null ? Colors.red : Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _emailError != null ? Colors.red : AppColors.primaryAccent,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an email address';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                        return 'Please enter a valid email address';
                      }
                      // Don't return _emailError here as it's shown below
                      return null;
                    },
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 12),
                      child: Text(
                        _emailError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Username Field (Optional)
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Optional)',
                  hintText: 'Enter a display name',
                ),
                validator: (value) {
                  // Username is optional, so only validate if provided
                  if (value != null && value.isNotEmpty && value.trim().length < 2) {
                    return 'Username must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Device Selection Widget
              DeviceSelectionWidget(
                devices: widget.organizationDevices,
                selectedDeviceIds: _selectedDeviceIds,
                accessType: _deviceAccessType,
                onSelectionChanged: (selectedIds) {
                  setState(() {
                    _selectedDeviceIds = selectedIds;
                  });
                },
                onAccessTypeChanged: (accessType) {
                  setState(() {
                    _deviceAccessType = accessType;
                    if (accessType != 'specific') {
                      _selectedDeviceIds.clear();
                    }
                  });
                },
              ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isLoading || _isCheckingEmail || _emailError != null) ? null : _addUser,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add User'),
        ),
      ],
    );
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    // Do a final check for email duplicates
    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationId = authProvider.primaryUserRole?['organization_id'];
      final addedBy = authProvider.user?.id;

      if (organizationId == null || addedBy == null) {
        throw Exception('Invalid organization or user context');
      }

      dynamic devices;
      if (_deviceAccessType == 'all') {
        devices = "all";
      } else if (_deviceAccessType == 'specific') {
        devices = _selectedDeviceIds;
      } else {
        devices = [];
      }

      final userManagementService = UserManagementService();
      final result = await userManagementService.addOrganizationUser(
        organizationId: organizationId,
        email: _emailController.text.trim().toLowerCase(),
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        userType: 'user',
        devices: devices,
        addedBy: addedBy,
      );

      final userExists = result?['user_existed'] ?? false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userExists 
              ? 'User added successfully with immediate access'
              : 'User invitation sent - they\'ll get access when they sign up'),
          backgroundColor: AppColors.successColor,
        ),
      );

      Navigator.pop(context);
      widget.onUserAdded();
    } catch (e) {
      // Only show SnackBar for errors that aren't email duplicates (those are shown inline)
      String errorMessage = e.toString();
      if (!errorMessage.contains('already registered to an organization') &&
          !errorMessage.contains('already tracked for this organization')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding user: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailDebounceTimer?.cancel();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}

// Edit User Dialog Widget
class EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> organizationDevices;
  final VoidCallback onUserUpdated;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.organizationDevices,
    required this.onUserUpdated,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _usernameController = TextEditingController();
  late String _deviceAccessType;
  late List<String> _selectedDeviceIds;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize username controller
    _usernameController.text = widget.user['username'] ?? '';
    
    final devices = widget.user['devices'];
    if (devices == "all") {
      _deviceAccessType = 'all';
      _selectedDeviceIds = [];
    } else if (devices is List && devices.isNotEmpty) {
      _deviceAccessType = 'specific';
      _selectedDeviceIds = List<String>.from(devices);
    } else {
      _deviceAccessType = 'none';
      _selectedDeviceIds = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isManager = ['admin', 'manager'].contains(widget.user['user_type']);
    
    return AlertDialog(
      title: Text('Edit ${widget.user['email']}'),
      content: SizedBox(
        width: double.maxFinite,
        height: isManager ? 200 : 600, // Reduced height for managers since they can't edit device access
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Username Field (Optional)
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username (Optional)',
                hintText: 'Enter a display name',
              ),
              validator: (value) {
                // Username is optional, so only validate if provided
                if (value != null && value.isNotEmpty && value.trim().length < 2) {
                  return 'Username must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Show restriction message for managers
            if (isManager) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warningColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warningColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Device access permissions cannot be edited for managers and admins.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Device Selection Widget - only show for non-managers
              DeviceSelectionWidget(
                devices: widget.organizationDevices,
                selectedDeviceIds: _selectedDeviceIds,
                accessType: _deviceAccessType,
                onSelectionChanged: (selectedIds) {
                  setState(() {
                    _selectedDeviceIds = selectedIds;
                  });
                },
                onAccessTypeChanged: (accessType) {
                  setState(() {
                    _deviceAccessType = accessType;
                    if (accessType != 'specific') {
                      _selectedDeviceIds.clear();
                    }
                  });
                },
              ),
            ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateUser,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationId = authProvider.primaryUserRole?['organization_id'];

      if (organizationId == null) {
        throw Exception('Invalid organization context');
      }

      final isManager = ['admin', 'manager'].contains(widget.user['user_type']);
      
      dynamic devices;
      String userType = widget.user['user_type'] ?? 'user';
      
      if (isManager) {
        // For managers, preserve existing device permissions
        devices = widget.user['devices'];
      } else {
        // For regular users, allow device permission changes
        if (_deviceAccessType == 'all') {
          devices = "all";
        } else if (_deviceAccessType == 'specific') {
          devices = _selectedDeviceIds;
        } else {
          devices = [];
        }
      }

      final userManagementService = UserManagementService();
      await userManagementService.updateUserPermissions(
        userId: widget.user['user_id'] ?? widget.user['id'],
        organizationId: organizationId,
        userType: userType,
        devices: devices,
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        isRegistered: widget.user['is_registered'] ?? false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isManager 
              ? 'Username updated successfully' 
              : 'User permissions updated successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );

      Navigator.pop(context);
      widget.onUserUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: $e'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
