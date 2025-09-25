import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryText,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Welcome text
                    Text(
                      'WELCOME TO',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // QC VATION logo
                    Image.asset(
                      'lib/assets/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // "by" text
                    Text(
                      'by',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Paramount logo
                    Image.asset(
                      'lib/assets/Paramount_logo.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Description text
                    Text(
                      'Welcome to the QC Vation App by Paramount Instruments, a cutting-edge solution developed with precision, innovation, and efficiency to textile materials testing. With over four decades of experience, Paramount Instruments has been a trusted leader in providing high-quality testing instruments and services to the textile industry. Our solutions are designed to meet the evolving demands of textile manufacturing, quality control laboratories, and research institutions worldwide.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'The QC Vation App is a powerful digital tool that enhances your textile testing process. By offering real-time data capture, analysis, and reporting features, we help you streamline your quality control operations and ensure that your materials meet international testing standards. Whether you are testing for durability, strength, colorfastness, or other textile parameters, our app provides comprehensive support, enabling you to make data-driven decisions quickly and confidently.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Our commitment to innovation drives us to continuously improve our testing solutions to meet the changing needs of the textile industry. Paramount Instruments prides itself on providing reliable, accurate, and user-friendly tools that enhance the efficiency and performance of your quality control processes.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
