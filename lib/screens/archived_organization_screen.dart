import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ArchivedOrganizationScreen extends StatelessWidget {
  const ArchivedOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Paramount Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'lib/assets/logo-square.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Icon(
                Icons.lock_outlined,
                size: 80,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 24),
              
              Text(
                'Access Restricted',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.errorColor,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'You cannot access the app at this time. Please contact support for assistance.',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Contact Paramount Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.05),
                  borderRadius: AppBorderRadius.card,
                  border: Border.all(
                    color: AppColors.primaryAccent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.support_agent,
                      color: AppColors.primaryAccent,
                      size: AppSizes.iconXLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Contact Paramount Instruments',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'To restore access to the application or for any inquiries, please contact Paramount Instruments support team.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    // Contact Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppBorderRadius.card,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.email_outlined, 
                                   color: AppColors.primaryAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'support@paramountinstruments.com',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, 
                                   color: AppColors.primaryAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '+91-XXXX-XXXX-XX',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/auth',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryText,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Refresh and recheck authorization
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        authProvider.recheckAuthorization();
                        AppComponents.showInfoSnackbar(
                          context,
                          'Checking access status...'
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
