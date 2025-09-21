import 'package:flutter/material.dart';
import 'app_theme.dart';

/// App Components
/// 
/// Pre-built UI components that follow the design system.
/// These components ensure consistency across the app.
class AppComponents {
  AppComponents._();

  /// Primary Button
  /// 
  /// Standard primary button with consistent styling
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    EdgeInsets? padding,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding ?? AppPaddings.button,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text),
      ),
    );
  }

  /// Secondary Button
  /// 
  /// Outlined button for secondary actions
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
    double? width,
    EdgeInsets? padding,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: padding ?? AppPaddings.button,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                ),
              )
            : Text(text),
      ),
    );
  }

  /// Text Button
  /// 
  /// Simple text button for minimal actions
  static Widget textButton({
    required String text,
    required VoidCallback? onPressed,
    Color? textColor,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.buttonText.copyWith(
          color: textColor ?? AppColors.secondaryAccent,
        ),
      ),
    );
  }

  /// Icon Button
  /// 
  /// Consistent icon button with optional background
  static Widget iconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    EdgeInsets? padding,
  }) {
    return Container(
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: AppBorderRadius.button,
              boxShadow: AppShadows.elevated,
            )
          : null,
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? AppColors.primaryText,
          size: size ?? AppSizes.iconMedium,
        ),
        onPressed: onPressed,
        padding: padding ?? const EdgeInsets.all(AppSizes.sm),
      ),
    );
  }

  /// App Card
  /// 
  /// Standard card container with consistent styling
  static Widget card({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSizes.md),
      padding: padding ?? AppPaddings.card,
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBackground,
        borderRadius: AppBorderRadius.card,
        boxShadow: boxShadow ?? AppShadows.card,
      ),
      child: child,
    );
  }

  /// Filter Chip
  /// 
  /// Selectable chip for filters and categories
  static Widget filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.defaultCurve,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.xl,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.cardBackground,
          borderRadius: AppBorderRadius.chip,
          boxShadow: AppShadows.card,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Status Chip
  /// 
  /// Chip for displaying status with appropriate colors
  static Widget statusChip({
    required String text,
    required StatusType status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: _getStatusTextColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Input Field
  /// 
  /// Consistent text input field
  static Widget inputField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
      enabled: enabled,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: AppColors.tertiaryText) 
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }

  /// Section Header
  /// 
  /// Consistent section header with optional action
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Padding(
      padding: AppPaddings.section,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.xs),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  /// Loading Indicator
  /// 
  /// Consistent loading indicator
  static Widget loadingIndicator({
    String? message,
    double? size,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.lg),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.tertiaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Empty State
  /// 
  /// Consistent empty state display
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: AppPaddings.screen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconXLarge * 2,
              color: AppColors.tertiaryText,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.tertiaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.tertiaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSizes.xl),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Divider
  /// 
  /// Consistent divider with proper spacing
  static Widget divider({
    EdgeInsets? margin,
    Color? color,
    double? thickness,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Divider(
        color: color ?? AppColors.dividerColor,
        thickness: thickness ?? 1,
        height: 1,
      ),
    );
  }

  /// Success Snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.button,
        ),
      ),
    );
  }

  /// Error Snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.button,
        ),
      ),
    );
  }

  /// Info Snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.infoColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.button,
        ),
      ),
    );
  }

  // Helper methods for status colors
  static Color _getStatusBackgroundColor(StatusType status) {
    switch (status) {
      case StatusType.pending:
        return AppColors.pendingBackground;
      case StatusType.ongoing:
        return AppColors.ongoingBackground;
      case StatusType.completed:
        return AppColors.completedBackground;
      case StatusType.escalated:
        return AppColors.escalatedBackground;
    }
  }

  static Color _getStatusTextColor(StatusType status) {
    switch (status) {
      case StatusType.pending:
        return AppColors.pendingText;
      case StatusType.ongoing:
        return AppColors.ongoingText;
      case StatusType.completed:
        return AppColors.completedText;
      case StatusType.escalated:
        return AppColors.escalatedText;
    }
  }
}

/// Status Type Enum
enum StatusType {
  pending,
  ongoing,
  completed,
  escalated,
}
