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
    return _InfoPageScaffold(
      title: 'Terms & Conditions',
      icon: Icons.description,
      child: SingleChildScrollView(
        child: Text(
          'Terms of Service\n\n'
          '1. Acceptance of Terms\n'
          'By accessing and using Imagepick, you accept and agree to be bound by the terms and provision of this agreement.\n\n'
          '2. Use of Service\n'
          'You may use our service for lawful purposes only. You agree not to use the service:\n'
          '• For any unlawful purpose or to solicit others to unlawful acts\n'
          '• To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances\n'
          '• To infringe upon or violate our intellectual property rights or the intellectual property rights of others\n\n'
          '3. Privacy Policy\n'
          'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service.\n\n'
          '4. Service Modifications\n'
          'We reserve the right to modify or discontinue our service at any time without notice.\n\n'
          '5. Limitations of Liability\n'
          'We provide the service "as is" without warranties of any kind, either express or implied.\n\n'
          '6. Governing Law\n'
          'These terms shall be governed by and construed in accordance with the laws of the jurisdiction in which our company is registered.\n\n'
          '7. Contact Information\n'
          'For questions about these Terms of Service, please contact us at:\n'
          'Email: support@paramount.com\n'
          'Phone: +1 (555) 123-4567\n\n'
          'Last updated: January 2024',
          style: AppTextStyles.bodyLarge.copyWith(
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoPageScaffold(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip,
      child: SingleChildScrollView(
        child: Text(
          'Privacy Policy\n\n'
          '1. Information We Collect\n'
          'We collect information you provide directly to us, such as when you:\n'
          '• Create an account\n'
          '• Use our services\n'
          '• Contact us for support\n'
          '• Subscribe to our newsletter\n\n'
          '2. How We Use Your Information\n'
          'We use the information we collect to:\n'
          '• Provide, maintain, and improve our services\n'
          '• Process transactions and send related information\n'
          '• Send technical notices and support messages\n'
          '• Respond to your comments and questions\n\n'
          '3. Information Sharing and Disclosure\n'
          'We do not sell, trade, or rent your personal information to third parties. We may share your information in the following situations:\n'
          '• With your consent\n'
          '• For legal reasons\n'
          '• To protect rights and safety\n\n'
          '4. Data Security\n'
          'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.\n\n'
          '5. Data Retention\n'
          'We retain your information for as long as necessary to provide our services and fulfill the purposes outlined in this policy.\n\n'
          '6. Your Rights\n'
          'You have the right to:\n'
          '• Access your personal information\n'
          '• Correct inaccurate information\n'
          '• Request deletion of your information\n'
          '• Object to processing of your information\n\n'
          '7. Changes to This Policy\n'
          'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.\n\n'
          '8. Contact Us\n'
          'If you have any questions about this Privacy Policy, please contact us at:\n'
          'Email: privacy@paramount.com\n'
          'Address: 123 Technology Drive, Innovation City, IC 12345\n\n'
          'Last updated: January 2024',
          style: AppTextStyles.bodyLarge.copyWith(
            height: 1.6,
          ),
        ),
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
