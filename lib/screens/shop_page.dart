import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppComponents.universalHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.construction,
                            size: 80,
                            color: AppColors.primaryAccent,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Coming Soon',
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Shop Feature',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We\'re working hard to bring you an amazing experience. Stay tuned for updates!',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.tertiaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
}
