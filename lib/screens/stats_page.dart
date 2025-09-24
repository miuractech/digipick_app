import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatsPage extends StatelessWidget {
  final Map<String, dynamic>? device;

  const StatsPage({super.key, this.device});

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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Device Statistics',
                    style: AppTextStyles.h1,
                  ),
                ],
              ),
              if (device != null) ...[
                const SizedBox(height: 16),
                Text(
                  device!['device_name'] ?? 'Unknown Device',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Device ID: ${device!['id'] != null && device!['id'].length >= 6 ? device!['id'].substring(device!['id'].length - 6) : device!['id'] ?? ''}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 80,
                        color: AppColors.tertiaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Statistics Page',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        device != null 
                            ? 'Statistics for ${device!['device_name'] ?? 'this device'} will be displayed here'
                            : 'Device statistics will be displayed here',
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
