# Medient Flutter App - Design System Guide

## Overview
This design system guide provides comprehensive styling guidelines for maintaining consistency across the Medient Flutter application. The design follows a clean, modern approach with emphasis on readability and user experience.

## Color Palette

### Primary Colors
```dart
// Background Colors
const Color backgroundColor = Color(0xFFF8F9FA);  // Light grey background
const Color cardBackground = Colors.white;        // Pure white cards

// Text Colors
const Color primaryText = Colors.black;           // Main text
const Color secondaryText = Color(0xFF424242);    // Secondary text
const Color tertiaryText = Color(0xFF9E9E9E);     // Tertiary/hint text

// Accent Colors
const Color primaryAccent = Colors.black;         // Primary buttons, selected states
const Color secondaryAccent = Colors.blue;       // Icons, links
```

### Status Colors
```dart
// Task Status Colors - Background
const Color pendingBackground = Color(0xFFFFF4E6);    // Orange tint
const Color ongoingBackground = Color(0xFFF5F5F5);    // Grey tint  
const Color completedBackground = Color(0xFFE8F5E8);  // Green tint
const Color escalatedBackground = Color(0xFFFFE8E8);  // Red tint

// Task Status Colors - Text
const Color pendingText = Color(0xFFFF9800);      // Orange
const Color ongoingText = Color(0xFF424242);      // Grey dark
const Color completedText = Color(0xFF4CAF50);    // Green
const Color escalatedText = Color(0xFFF44336);    // Red
```

### Semantic Colors
```dart
const Color errorColor = Colors.red;
const Color warningColor = Color(0xFFFF9800);
const Color successColor = Color(0xFF4CAF50);
const Color infoColor = Colors.blue;
```

## Typography

### Font Weights
```dart
const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
const FontWeight semiBold = FontWeight.w600;
const FontWeight bold = FontWeight.w700;
```

### Text Styles
```dart
// Headers
const TextStyle h1 = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

const TextStyle h2 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

const TextStyle h3 = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.black,
  height: 1.2,
);

// Body Text
const TextStyle bodyLarge = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

const TextStyle bodyMedium = TextStyle(
  fontSize: 14,
  color: Color(0xFF424242),
  height: 1.3,
);

const TextStyle bodySmall = TextStyle(
  fontSize: 12,
  color: Color(0xFF9E9E9E),
);

// Caption Text
const TextStyle caption = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color(0xFF9E9E9E),
);

// Button Text
const TextStyle buttonText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);
```

## Spacing System

### Padding & Margins
```dart
// Standard spacing values
const double xs = 4.0;
const double sm = 8.0;
const double md = 12.0;
const double lg = 16.0;
const double xl = 20.0;
const double xxl = 24.0;
const double xxxl = 32.0;

// Common padding patterns
const EdgeInsets cardPadding = EdgeInsets.all(16);
const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
```

## Border Radius

### Standard Radius Values
```dart
const double radiusSmall = 8.0;
const double radiusMedium = 12.0;
const double radiusLarge = 20.0;
const double radiusXLarge = 25.0;
const double radiusRound = 56.0;  // For circular elements
```

### Common BorderRadius
```dart
const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));
const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12));
const BorderRadius chipRadius = BorderRadius.all(Radius.circular(25));
const BorderRadius inputRadius = BorderRadius.all(Radius.circular(12));
```

## Shadows & Elevation

### Card Shadows
```dart
// Light shadow for cards
final List<BoxShadow> cardShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

// Medium shadow for elevated elements
final List<BoxShadow> elevatedShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 4,
    offset: const Offset(0, 2),
  ),
];

// Heavy shadow for navigation
final List<BoxShadow> navigationShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 10,
    offset: const Offset(0, 5),
  ),
];
```

## Component Styles

### Cards
```dart
Container buildCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}
```

### Buttons

#### Primary Button
```dart
Container buildPrimaryButton({
  required String text,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}
```

#### Icon Button
```dart
Container buildIconButton({
  required IconData icon,
  required VoidCallback onPressed,
  Color? backgroundColor,
  Color? iconColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      icon: Icon(icon, color: iconColor ?? Colors.black, size: 20),
      onPressed: onPressed,
    ),
  );
}
```

### Filter Chips
```dart
Widget buildFilterChip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    ),
  );
}
```

### Status Chips
```dart
Widget buildStatusChip({
  required String text,
  required TaskStatus status,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _getStatusChipColor(status),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: _getStatusTextColor(status),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
```

### Input Fields
```dart
InputDecoration buildInputDecoration({
  required String labelText,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    prefixIcon: prefixIcon != null 
        ? Icon(prefixIcon, color: Colors.grey[600]) 
        : null,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.grey[50],
  );
}
```

## Navigation

### Bottom Navigation Bar
```dart
// Navigation container styling
Container buildNavigationBar() {
  return Container(
    margin: const EdgeInsets.fromLTRB(48, 0, 48, 24),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(56),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Container(
      height: 106,
      // Navigation items...
    ),
  );
}

// Navigation item styling
Widget buildNavItem({
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected ? Colors.black : Colors.white,
      ),
    ),
  );
}
```

## App Bar Styling

```dart
AppBar buildAppBar({
  required String title,
  List<Widget>? actions,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    backgroundColor: const Color(0xFFF8F9FA),
    elevation: 0,
    actions: actions,
  );
}
```

## Animation Guidelines

### Transition Durations
```dart
const Duration fastTransition = Duration(milliseconds: 200);
const Duration normalTransition = Duration(milliseconds: 300);
const Duration slowTransition = Duration(milliseconds: 400);
```

### Common Curves
```dart
const Curve defaultCurve = Curves.easeInOutCubic;
const Curve bouncyCurve = Curves.elasticOut;
const Curve smoothCurve = Curves.easeOut;
```

## Icon Guidelines

### Common Icons
- **Tasks**: `Icons.task_alt`, `Icons.apps`
- **Calendar**: `Icons.calendar_today_outlined`
- **Profile**: `Icons.person_outline`
- **Search**: `Icons.search`
- **Refresh**: `Icons.refresh`
- **Movie/Project**: `Icons.movie`
- **Comments**: `Icons.chat_bubble_outline`
- **Time**: `Icons.calendar_today_outlined`

### Icon Sizes
```dart
const double iconSmall = 16.0;
const double iconMedium = 20.0;
const double iconLarge = 24.0;
const double iconXLarge = 40.0;
```

## Layout Guidelines

### Screen Structure
1. **Background**: Always use `Color(0xFFF8F9FA)`
2. **Content**: Wrap in cards with white background
3. **Padding**: Use consistent 16px horizontal padding
4. **Spacing**: Use 12px vertical spacing between elements

### Card Layout Pattern
```dart
Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: cardShadow,
  ),
  child: // Content
);
```

## Theme Integration

### Material Theme
```dart
ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FA),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
```

## Best Practices

### Do's
- Use consistent spacing from the spacing system
- Apply shadows to create depth hierarchy
- Use semantic colors for status indicators
- Maintain consistent border radius across similar components
- Use proper text hierarchy with defined text styles

### Don'ts
- Don't use arbitrary spacing values
- Don't mix different shadow styles
- Don't use colors outside the defined palette
- Don't create inconsistent border radius patterns
- Don't use random font weights or sizes

## Implementation Notes

1. **State Management**: Use consistent loading states with `CircularProgressIndicator`
2. **Error Handling**: Use `SnackBar` with red background for errors
3. **Empty States**: Include appropriate icons and messaging
4. **Responsive Design**: Components should adapt to different screen sizes
5. **Accessibility**: Ensure proper contrast ratios and touch targets

This design system ensures visual consistency and maintainable code across the entire Medient Flutter application.
