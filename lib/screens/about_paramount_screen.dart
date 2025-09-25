import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutParamountScreen extends StatelessWidget {
  const AboutParamountScreen({Key? key}) : super(key: key);

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
                    
                    // About text
                    Text(
                      'ABOUT',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                        letterSpacing: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Paramount logo
                    Image.asset(
                      'lib/assets/Paramount_logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Company tagline
                    Text(
                      'YOUR QUALITY, OUR OBSESSION',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.secondaryText,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // About content
                    Text(
                      'Paramount Instruments is a leading technology company focused on innovative textile testing solutions. Founded with the vision to revolutionize quality control in the textile industry, we have been at the forefront of testing technology for over four decades.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Our commitment to precision, innovation, and efficiency drives us to continuously develop cutting-edge solutions that meet the evolving demands of textile manufacturing, quality control laboratories, and research institutions worldwide.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Our Mission:\n• Deliver cutting-edge textile testing technology\n• Provide exceptional user experiences and reliable solutions\n• Drive innovation in quality control processes\n• Ensure international testing standards compliance\n• Support textile industry growth through advanced instrumentation',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'With years of expertise and a commitment to excellence, Paramount Instruments remains a trusted leader in providing high-quality testing instruments and services. We pride ourselves on delivering reliable, accurate, and user-friendly tools that enhance the efficiency and performance of your quality control processes.',
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
