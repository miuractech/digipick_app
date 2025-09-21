import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

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
              Icon(
                Icons.block,
                size: 120,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 32),
              Text(
                'Access Denied',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your email address is not registered with any organization.',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(AppSizes.xl),
                decoration: BoxDecoration(
                  color: AppColors.pendingBackground,
                  borderRadius: AppBorderRadius.button,
                  border: Border.all(color: AppColors.pendingText),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.pendingText,
                      size: AppSizes.iconXLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Need Access?',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.pendingText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please contact Paramount Instruments to register your organization and get access to this application.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.pendingText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Login'),
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
                        // TODO: Add contact functionality
                        AppComponents.showInfoSnackbar(
                          context,
                          'Contact feature coming soon!'
                        );
                      },
                      icon: const Icon(Icons.contact_support),
                      label: const Text('Contact Us'),
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
