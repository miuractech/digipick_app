import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import '../services/user_management_service.dart';
import 'edit_profile_screen.dart';
import 'info_pages.dart';
import 'welcome_screen.dart' as welcome;
import 'about_paramount_screen.dart' as about;
import 'user_management_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserManagementService _userManagementService = UserManagementService();
  int? _userCount;

  @override
  void initState() {
    super.initState();
    _loadUserCount();
  }

  Future<void> _loadUserCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizationId = authProvider.organization?['id'];
    
    if (organizationId != null) {
      try {
        final stats = await _userManagementService.getOrganizationUserStats(organizationId);
        if (mounted) {
          setState(() {
            _userCount = stats['total'];
          });
        }
      } catch (e) {
        print('Error loading user count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final organization = authProvider.organization;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FE),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: AppComponents.universalHeader(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Section 1: Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppBorderRadius.card,
                    ),
                    child: Row(
                      children: [
                       
                        const SizedBox(width: 18),
                        // Company Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company Name
                              Text(
                                organization?['name'] ?? 'Company Name',
                                style: AppTextStyles.h2.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Company Email
                              Text(
                                organization?['email'] ?? user?.email ?? 'info@company.com',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.tertiaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit Profile Icon (only for managers)
                        if (authProvider.hasManagerRole)
                          IconButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            ),
                            icon: Icon(
                              Icons.edit,
                              color: AppColors.primaryAccent,
                              size: 20,
                            ),
                           
                            tooltip: 'Edit Profile',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Section 2: Account Profile Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Text(
                      'ACCOUNT PROFILE',
                      textAlign: TextAlign.left,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.8,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  
                  // Account Profile Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppBorderRadius.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // User Details
                        _buildAccountDetail(
                          Icons.person,
                          organization?['contact_person'] ?? user?.email?.split('@')[0] ?? 'User Name',
                          null,
                        ),
                        const SizedBox(height: 18),
                        _buildAccountDetail(
                          Icons.email,
                          user?.email ?? 'user@email.com',
                          Icons.check_circle,
                          iconColor: AppColors.successColor,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Text(
                            'Primary Contact',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.tertiaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        // Add phone number if available
                        if (organization != null && organization['phone'] != null && organization['phone'].toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          _buildAccountDetail(
                            Icons.phone,
                            organization['phone'],
                            null,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Text(
                              'Primary Contact Phone',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.tertiaryText,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Section 3: User Management (for managers only)
                  if (authProvider.hasManagerRole) ...[
                    _buildUserManagementSection(context, authProvider),
                    const SizedBox(height: 20),
                  ],
                  
                  // Section 4: Links (Welcome to QCVATION)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLinkCard(
                        Icons.waving_hand,
                        null, // Custom text will be handled separately
                        () => _navigateToPage(context, const welcome.WelcomeScreen()),
                        isWelcomeCard: true,
                      ),
                      const SizedBox(height: 12),
                      _buildLinkCard(
                        Icons.info,
                        'About Paramount',
                        () => _navigateToPage(context, const about.AboutParamountScreen()),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkCard(
                        Icons.language,
                        'Visit Paramount Site',
                        () => _navigateToPage(context, const VisitSiteScreen()),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkCard(
                        Icons.description,
                        'Terms & Conditions',
                        () => _navigateToPage(context, const TermsConditionsScreen()),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkCard(
                        Icons.privacy_tip,
                        'Privacy Policy',
                        () => _navigateToPage(context, const PrivacyPolicyScreen()),
                      ),
                      const SizedBox(height: 12),
                      _buildLinkCard(
                        Icons.upgrade,
                        'Upgrade Firmware',
                        () => _navigateToPage(context, const UpgradeFirmwareScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign Out Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.errorColor,
                      borderRadius: AppBorderRadius.button,
                    ),
                    child: TextButton.icon(
                      onPressed: () => _showSignOutDialog(context, authProvider),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Sign Out',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                      ),
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

  Widget _buildAccountDetail(IconData icon, String text, IconData? trailingIcon, {Color? iconColor}) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryAccent,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: 15,
              color: AppColors.primaryText,
            ),
          ),
        ),
        if (trailingIcon != null)
          Icon(
            trailingIcon,
            color: iconColor ?? AppColors.primaryAccent,
            size: 18,
          ),
      ],
    );
  }


  Widget _buildUserManagementSection(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                color: AppColors.primaryAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Organization Users',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_userCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$_userCount users',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manage users and their device permissions for your organization.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserManagementScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Manage Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.button,
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }


  Widget _buildLinkCard(IconData icon, String? title, VoidCallback onTap, {bool isWelcomeCard = false}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryAccent,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isWelcomeCard
                    ? RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'welcome to ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w300,
                                fontSize: 15,
                                color: AppColors.primaryText,
                                height: 1.0,
                              ),
                            ),
                            TextSpan(
                              text: 'QCVATION',
                              style: const TextStyle(
                                fontFamily: 'Rajdhani',
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: AppColors.primaryText,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        title ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: AppColors.primaryText,
                        ),
                      ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
