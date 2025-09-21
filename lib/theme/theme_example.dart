import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_components.dart';

/// Theme Example Screen
/// 
/// This screen demonstrates how to use the theme system and components.
/// Use this as a reference for implementing consistent UI across the app.
class ThemeExampleScreen extends StatefulWidget {
  const ThemeExampleScreen({super.key});

  @override
  State<ThemeExampleScreen> createState() => _ThemeExampleScreenState();
}

class _ThemeExampleScreenState extends State<ThemeExampleScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Completed', 'Pending'];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Examples'),
        actions: [
          AppComponents.iconButton(
            icon: Icons.refresh,
            onPressed: () {
              AppComponents.showInfoSnackbar(context, 'Refreshed!');
            },
          ),
          const SizedBox(width: AppSizes.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography Examples
            AppComponents.sectionHeader(
              title: 'Typography',
              subtitle: 'Text style examples',
            ),
            AppComponents.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Heading 1', style: AppTextStyles.h1),
                  const SizedBox(height: AppSizes.sm),
                  Text('Heading 2', style: AppTextStyles.h2),
                  const SizedBox(height: AppSizes.sm),
                  Text('Heading 3', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.sm),
                  Text('Body Large', style: AppTextStyles.bodyLarge),
                  const SizedBox(height: AppSizes.sm),
                  Text('Body Medium', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSizes.sm),
                  Text('Body Small', style: AppTextStyles.bodySmall),
                  const SizedBox(height: AppSizes.sm),
                  Text('Caption Text', style: AppTextStyles.caption),
                ],
              ),
            ),

            // Button Examples
            AppComponents.sectionHeader(
              title: 'Buttons',
              subtitle: 'Button component examples',
            ),
            AppComponents.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppComponents.primaryButton(
                    text: 'Primary Button',
                    onPressed: _isLoading ? null : _toggleLoading,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppComponents.secondaryButton(
                    text: 'Secondary Button',
                    onPressed: () {
                      AppComponents.showSuccessSnackbar(context, 'Secondary button pressed!');
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      AppComponents.textButton(
                        text: 'Text Button',
                        onPressed: () {
                          AppComponents.showInfoSnackbar(context, 'Text button pressed!');
                        },
                      ),
                      const Spacer(),
                      AppComponents.iconButton(
                        icon: Icons.favorite,
                        onPressed: () {
                          AppComponents.showErrorSnackbar(context, 'Icon button pressed!');
                        },
                        backgroundColor: AppColors.cardBackground,
                        iconColor: AppColors.errorColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Input Examples
            AppComponents.sectionHeader(
              title: 'Input Fields',
              subtitle: 'Form input examples',
            ),
            AppComponents.card(
              child: Column(
                children: [
                  AppComponents.inputField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),
                  AppComponents.inputField(
                    controller: TextEditingController(),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                    suffixIcon: const Icon(Icons.visibility_off),
                  ),
                ],
              ),
            ),

            // Filter Chips Examples
            AppComponents.sectionHeader(
              title: 'Filter Chips',
              subtitle: 'Selectable filter examples',
            ),
            AppComponents.card(
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: _filters.map((filter) {
                  return AppComponents.filterChip(
                    label: filter,
                    isSelected: _selectedFilter == filter,
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // Status Chips Examples
            AppComponents.sectionHeader(
              title: 'Status Chips',
              subtitle: 'Status indicator examples',
            ),
            AppComponents.card(
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: [
                  AppComponents.statusChip(
                    text: 'Pending',
                    status: StatusType.pending,
                  ),
                  AppComponents.statusChip(
                    text: 'Ongoing',
                    status: StatusType.ongoing,
                  ),
                  AppComponents.statusChip(
                    text: 'Completed',
                    status: StatusType.completed,
                  ),
                  AppComponents.statusChip(
                    text: 'Escalated',
                    status: StatusType.escalated,
                  ),
                ],
              ),
            ),

            // Color Examples
            AppComponents.sectionHeader(
              title: 'Colors',
              subtitle: 'Color palette examples',
            ),
            AppComponents.card(
              child: Column(
                children: [
                  _buildColorRow('Primary Accent', AppColors.primaryAccent),
                  _buildColorRow('Secondary Accent', AppColors.secondaryAccent),
                  _buildColorRow('Success Color', AppColors.successColor),
                  _buildColorRow('Warning Color', AppColors.warningColor),
                  _buildColorRow('Error Color', AppColors.errorColor),
                  _buildColorRow('Info Color', AppColors.infoColor),
                ],
              ),
            ),

            // Empty State Example
            AppComponents.sectionHeader(
              title: 'Empty State',
              subtitle: 'Empty state component example',
            ),
            AppComponents.card(
              child: SizedBox(
                height: 200,
                child: AppComponents.emptyState(
                  icon: Icons.inbox_outlined,
                  title: 'No items found',
                  subtitle: 'There are no items to display at the moment.',
                  action: AppComponents.primaryButton(
                    text: 'Add Item',
                    onPressed: () {
                      AppComponents.showSuccessSnackbar(context, 'Add item pressed!');
                    },
                    width: 120,
                  ),
                ),
              ),
            ),

            // Loading Example
            AppComponents.sectionHeader(
              title: 'Loading Indicator',
              subtitle: 'Loading state example',
            ),
            AppComponents.card(
              child: SizedBox(
                height: 100,
                child: AppComponents.loadingIndicator(
                  message: 'Loading data...',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.dividerColor,
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Text(name, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            color.toString(),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// Usage Examples Documentation
/// 
/// Here are some common usage patterns for the theme system:
/// 
/// 1. Using Colors:
/// ```dart
/// Container(
///   color: AppColors.primaryAccent,
///   child: Text(
///     'Hello World',
///     style: AppTextStyles.h1.copyWith(color: Colors.white),
///   ),
/// )
/// ```
/// 
/// 2. Using Spacing:
/// ```dart
/// Padding(
///   padding: AppPaddings.screen,
///   child: Column(
///     children: [
///       Text('Title'),
///       SizedBox(height: AppSizes.lg),
///       Text('Content'),
///     ],
///   ),
/// )
/// ```
/// 
/// 3. Using Components:
/// ```dart
/// AppComponents.primaryButton(
///   text: 'Save',
///   onPressed: () => _saveData(),
///   isLoading: _isLoading,
/// )
/// ```
/// 
/// 4. Using Cards:
/// ```dart
/// AppComponents.card(
///   child: Column(
///     children: [
///       Text('Card Title', style: AppTextStyles.h3),
///       SizedBox(height: AppSizes.md),
///       Text('Card content', style: AppTextStyles.bodyMedium),
///     ],
///   ),
/// )
/// ```
/// 
/// 5. Showing Snackbars:
/// ```dart
/// AppComponents.showSuccessSnackbar(context, 'Operation successful!');
/// AppComponents.showErrorSnackbar(context, 'Something went wrong');
/// AppComponents.showInfoSnackbar(context, 'Information message');
/// ```
