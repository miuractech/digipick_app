import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CarePage extends StatelessWidget {
  const CarePage({super.key});

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
                'Care',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 80,
                        color: AppColors.tertiaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Care Page',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a placeholder for the care page',
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
