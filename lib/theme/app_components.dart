import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  /// Universal Header
  /// 
  /// Standard header with logo and optional back navigation and actions
  static Widget universalHeader({
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button or spacer
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                )
              else
                const SizedBox(width: 48), // Spacer to center logo
              
              // Logo
              SvgPicture.asset(
                'lib/assets/logo.svg',
                height: 32,
              ),
              
              // Actions or spacer
              if (actions != null && actions.isNotEmpty)
                Row(children: actions)
              else
                const SizedBox(width: 48), // Spacer to center logo
            ],
          ),
          const SizedBox(height: 8),
        ],
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

  /// Simple Floating Action Button for Add Device
  static Widget addDeviceFAB({
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryAccent,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.fab,
      ),
      child: const Icon(
        Icons.add_circle_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Simple Floating Action Button for Service Request
  static Widget serviceRequestFAB({
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.secondaryAccent,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.fab,
      ),
      child: const Icon(
        Icons.build_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Floating Action Button with Expandable Menu (Deprecated - kept for compatibility)
  static Widget floatingActionButton({
    required VoidCallback onAddDevice,
    required VoidCallback onServiceRequest,
  }) {
    return _FloatingActionButtonWidget(
      onAddDevice: onAddDevice,
      onServiceRequest: onServiceRequest,
    );
  }
}

/// Status Type Enum
enum StatusType {
  pending,
  ongoing,
  completed,
  escalated,
}

/// Internal Floating Action Button Widget
class _FloatingActionButtonWidget extends StatefulWidget {
  final VoidCallback onAddDevice;
  final VoidCallback onServiceRequest;

  const _FloatingActionButtonWidget({
    required this.onAddDevice,
    required this.onServiceRequest,
  });

  @override
  State<_FloatingActionButtonWidget> createState() => _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState extends State<_FloatingActionButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop to close menu when tapped
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
        
        // Action buttons
        if (_isExpanded) ...[
          // Add Device button
          Positioned(
            bottom: 140,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Device',
                backgroundColor: AppColors.primaryAccent,
                onPressed: () {
                  _toggleExpanded();
                  widget.onAddDevice();
                },
              ),
            ),
          ),
          
          // Service Request button
          Positioned(
            bottom: 80,
            right: 16,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildActionButton(
                icon: Icons.build_outlined,
                label: 'Service Request',
                backgroundColor: AppColors.secondaryAccent,
                onPressed: () {
                  _toggleExpanded();
                  widget.onServiceRequest();
                },
              ),
            ),
          ),
        ],
        
        // Main FAB
        Positioned(
          bottom: 16,
          right: 16,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159 ,
                child: FloatingActionButton(
                  onPressed: _toggleExpanded,
                  backgroundColor: AppColors.primaryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.fab,
                  ),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: label,
 
      child: FloatingActionButton(
        heroTag: label,
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        mini: true,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.fab,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
