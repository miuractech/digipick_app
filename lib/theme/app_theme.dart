import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme Configuration
/// 
/// This file contains the comprehensive theme configuration for the QCVATION app.
/// It follows the design system guide and ensures consistent styling across the app.
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        brightness: Brightness.light,
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.cardBackground,
        background: AppColors.backgroundColor,
        error: AppColors.errorColor,
      ),
      
      // Material 3
      useMaterial3: true,
      
      // Background
      scaffoldBackgroundColor: AppColors.backgroundColor,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h1,
        iconTheme: const IconThemeData(
          color: AppColors.primaryText,
          size: AppSizes.iconLarge,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.card,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryAccent,
          textStyle: AppTextStyles.buttonText.copyWith(
            color: AppColors.secondaryAccent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          side: const BorderSide(color: AppColors.primaryAccent),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.button,
          ),
          textStyle: AppTextStyles.buttonText.copyWith(
            color: AppColors.primaryAccent,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: const BorderSide(color: AppColors.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.input,
          borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.tertiaryText,
        ),
        contentPadding: const EdgeInsets.all(AppSizes.lg),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primaryAccent,
        labelStyle: AppTextStyles.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chip,
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: AppSizes.lg,
      ),
      
      // Text Theme with Poppins font
      textTheme: GoogleFonts.poppinsTextTheme(),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryAccent,
        linearTrackColor: AppColors.backgroundColor,
        circularTrackColor: AppColors.backgroundColor,
      ),
      
      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryAccent,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.button,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dark Theme Configuration (optional - for future use)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryAccent,
        brightness: Brightness.dark,
      ),
    );
  }
}

/// App Colors
/// 
/// Centralized color palette following the design system guide
class AppColors {
  AppColors._();

  // Background Colors
  static const Color backgroundColor = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color primaryText = Color(0xFF585958); // Davy's Gray for primary text
  static const Color secondaryText = Color(0xFF424242);
  static const Color tertiaryText = Color(0xFF9E9E9E);

  // Accent Colors - New Theme Colors
  static const Color primaryAccent = Color(0xFF245BA0); // Lapis Lazuli
  static const Color secondaryAccent = Color(0xFFE0623A); // Flame
  static const Color tertiaryAccent = Color(0xFF585958); // Davy's Gray

  // Status Colors - Background
  static const Color pendingBackground = Color(0xFFFFF4E6);
  static const Color ongoingBackground = Color(0xFFE8F0FF); // Light blue background for ongoing
  static const Color completedBackground = Color(0xFFE8F5E8);
  static const Color escalatedBackground = Color(0xFFFDF2ED); // Light flame background

  // Status Colors - Text
  static const Color pendingText = Color(0xFFFF9800);
  static const Color ongoingText = Color(0xFF245BA0); // Lapis Lazuli for ongoing
  static const Color completedText = Color(0xFF4CAF50);
  static const Color escalatedText = Color(0xFFE0623A); // Flame for escalated

  // Semantic Colors
  static const Color errorColor = Color(0xFFE0623A); // Flame for errors
  static const Color warningColor = Color(0xFFFF9800);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color infoColor = Color(0xFF245BA0); // Lapis Lazuli for info

  // Additional Colors
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color shadowColor = Color(0x0A000000);
}

/// App Text Styles
/// 
/// Centralized text styles following the design system guide
class AppTextStyles {
  AppTextStyles._();

  // Headers with Poppins font
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.2,
  );

  // Body Text with Poppins font
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.3,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.tertiaryText,
    height: 1.3,
  );

  // Caption Text with Poppins font
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.tertiaryText,
  );

  // Button Text with Poppins font
  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Special Text Styles with Poppins font
  static TextStyle link = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryAccent,
    decoration: TextDecoration.underline,
  );

  static TextStyle error = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.errorColor,
  );
}

/// App Sizes
/// 
/// Centralized spacing and sizing system
class AppSizes {
  AppSizes._();

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 40.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 25.0;
  static const double radiusRound = 56.0;
  static const double radiusFAB = 48.0;
}

/// App Border Radius
/// 
/// Centralized border radius configurations
class AppBorderRadius {
  AppBorderRadius._();

  static const BorderRadius card = BorderRadius.all(Radius.circular(AppSizes.radiusSmall));
  static const BorderRadius button = BorderRadius.all(Radius.circular(AppSizes.radiusSmall));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(AppSizes.radiusSmall));
  static const BorderRadius input = BorderRadius.all(Radius.circular(AppSizes.radiusSmall));
  static const BorderRadius round = BorderRadius.all(Radius.circular(AppSizes.radiusRound));
  static const BorderRadius fab = BorderRadius.all(Radius.circular(AppSizes.radiusFAB));
}

/// App Shadows
/// 
/// Centralized shadow configurations
class AppShadows {
  AppShadows._();

  // Card Shadow
  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Elevated Shadow
  static final List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // Navigation Shadow
  static final List<BoxShadow> navigation = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];
}

/// App Paddings
/// 
/// Common padding configurations
class AppPaddings {
  AppPaddings._();

  static const EdgeInsets card = EdgeInsets.all(AppSizes.lg);
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: AppSizes.lg);
  static const EdgeInsets section = EdgeInsets.symmetric(
    horizontal: AppSizes.lg,
    vertical: AppSizes.md,
  );
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSizes.xl,
    vertical: AppSizes.lg,
  );
}

/// App Durations
/// 
/// Animation duration constants
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
}

/// App Curves
/// 
/// Animation curve constants
class AppCurves {
  AppCurves._();

  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOut;
}
