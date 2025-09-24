import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Shop',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 80,
                        color: AppColors.tertiaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Shop Page',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a placeholder for the shop page',
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
    );
  }
}
