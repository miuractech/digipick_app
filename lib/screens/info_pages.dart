import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPageScaffold(
      title: 'Welcome to Imagepick',
      icon: Icons.waving_hand,
      child:         Text(
        'Welcome to Imagepick - your comprehensive image processing solution.\n\n'
        'We\'re excited to have you on board and look forward to helping you achieve your imaging goals.\n\n'
        'Our platform provides powerful tools for image management, processing, and analysis that will streamline your workflow and enhance your productivity.',
        style: AppTextStyles.bodyLarge.copyWith(
          height: 1.6,
        ),
      ),
    );
  }
}

class AboutParamountScreen extends StatelessWidget {
  const AboutParamountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPageScaffold(
      title: 'About Paramount',
      icon: Icons.info,
      child: Text(
        'Paramount is a leading technology company focused on innovative imaging solutions.\n\n'
        'Founded with the vision to revolutionize image processing and management, we continue to push the boundaries of what\'s possible in digital imaging.\n\n'
        'Our Mission:\n'
        '• Deliver cutting-edge imaging technology\n'
        '• Provide exceptional user experiences\n'
        '• Drive innovation in digital solutions\n\n'
        'With years of expertise and a commitment to excellence, Paramount remains at the forefront of technological advancement.',
        style: AppTextStyles.bodyLarge.copyWith(
          height: 1.6,
        ),
      ),
    );
  }
}

class VisitSiteScreen extends StatelessWidget {
  const VisitSiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPageScaffold(
      title: 'Visit Paramount Site',
      icon: Icons.public,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visit our official website to discover more about our products, services, and latest innovations in imaging technology.',
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.language, color: Colors.grey[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'www.paramount.com',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Explore our:\n'
            '• Product catalog and specifications\n'
            '• Technical documentation\n'
            '• Customer support resources\n'
            '• Latest news and updates\n'
            '• Career opportunities',
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _QCVationPageScaffold(
      title: 'TERMS & CONDITIONS',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the QC Vation App. By using this application, you agree to comply with and be bound by the following terms and conditions of use.',
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.6,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Acceptance of Terms',
              'By downloading, installing, or using the QC Vation App, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. Use of the Application',
              'You agree to use the QC Vation App only for lawful purposes and in accordance with these Terms. You agree not to use the app:',
            ),
            const SizedBox(height: 16),
            _buildSubSection(
              '• For any unlawful purpose or to solicit others to unlawful acts',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              '• To violate any applicable laws, regulations, or third-party rights',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              '• To transmit any harmful or malicious code',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              '• To interfere with or disrupt the app\'s functionality',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Intellectual Property',
              'The QC Vation App and all its content, features, and functionality are owned by Paramount Instruments and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. User Data and Privacy',
              'Your use of the QC Vation App is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices regarding your personal information.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. Disclaimers and Limitations',
              'The QC Vation App is provided "as is" without warranties of any kind, either express or implied. We do not warrant that the app will be uninterrupted or error-free.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. Contact Information',
              'For questions about these Terms and Conditions, please contact us at:',
            ),
            const SizedBox(height: 16),
            _buildSubSection('Email: support@paramount.com'),
            const SizedBox(height: 8),
            _buildSubSection('Phone: +1 (555) 123-4567'),
            const SizedBox(height: 24),
            Text(
          'Last updated: January 2024',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tertiaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.5,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection(String content) {
    return Text(
      content,
      style: AppTextStyles.bodyMedium.copyWith(
        height: 1.5,
        color: AppColors.secondaryText,
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _QCVationPageScaffold(
      title: 'PRIVACY POLICY',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'At Paramount Instruments, we value your privacy and are committed to protecting the personal information you provide through the QC Vation App. This Privacy Policy explains how we collect, use, and protect your data.',
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.6,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Information We Collect',
              'We may collect the following types of information when you use the QC Vation App:',
            ),
            const SizedBox(height: 16),
            _buildSubSection(
              'Personal Information: This includes your name, email address, company details, and any other information you voluntarily provide.',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'Usage Data: We collect technical information related to your usage of the app, such as IP addresses, device identifiers, app version, and log data.',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'Test Data: The app may collect data related to your textile testing results, including test results, configurations, and other relevant metrics.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. How We Use Your Information',
              'We use the collected data to:',
            ),
            const SizedBox(height: 16),
            _buildSubSection(
              'Improve the functionality and user experience of the QC Vation App.',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'Provide you with technical support and customer service.',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'Monitor usage patterns to improve our services.',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'Ensure the accuracy of test results and performance analytics.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Data Sharing',
              'We do not sell, trade, or share your personal information with third parties, except in the following cases:',
            ),
            const SizedBox(height: 16),
            _buildSubSection(
              'To comply with legal obligations.',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'If required for providing our services (e.g., with trusted partners who assist us with app development or support).',
            ),
            const SizedBox(height: 12),
            _buildSubSection(
              'With your explicit consent.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.5,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection(String content) {
    return Text(
      content,
      style: AppTextStyles.bodyMedium.copyWith(
        height: 1.5,
        color: AppColors.secondaryText,
      ),
    );
  }
}

class UpgradeFirmwareScreen extends StatelessWidget {
  const UpgradeFirmwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPageScaffold(
      title: 'Upgrade Firmware',
      icon: Icons.upgrade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.completedText, size: AppSizes.iconLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your firmware is up to date!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Current Version', 'v2.1.3'),
          const SizedBox(height: 16),
          _buildInfoRow('Latest Version', 'v2.1.3'),
          const SizedBox(height: 24),
          Text(
            'Firmware Updates\n\n'
            'Regular firmware updates ensure optimal performance and introduce new features. Benefits include:\n\n'
            '• Enhanced security and stability\n'
            '• Performance improvements\n'
            '• New feature additions\n'
            '• Bug fixes and optimizations\n\n'
            'We recommend checking for updates regularly to ensure you have the latest improvements.',
            style: AppTextStyles.bodyLarge.copyWith(
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _checkForUpdates(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Check for Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  static void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Checking for updates...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _InfoPageScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoPageScaffold({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: AppComponents.iconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
          iconColor: AppColors.primaryText,
        ),
        title: Text(
          title,
          style: AppTextStyles.h2,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppBorderRadius.card,
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: AppBorderRadius.button,
                      ),
                      child: Icon(icon, size: AppSizes.iconLarge, color: AppColors.primaryText),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.h2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QCVationPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _QCVationPageScaffold({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AppComponents.iconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                    iconColor: AppColors.primaryText,
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'lib/assets/logo.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: AppTextStyles.h1.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
