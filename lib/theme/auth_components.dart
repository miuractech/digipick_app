import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Common UI components for authentication screens
class AuthComponents {
  AuthComponents._();

  /// Logo header with QCVATION logo and tagline
  static Widget logoHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // QCVATION Logo
        SvgPicture.asset(
          'lib/assets/logo.svg',
          height: 80,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          'THE FUTURE OF QC',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  /// Page title widget
  static Widget pageTitle(String title) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  /// Custom input field with consistent styling
  static Widget inputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  /// Custom primary button with loading state
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25599F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }

  /// Forgot password link
  static Widget forgotPasswordLink({required VoidCallback onPressed}) {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          'Forgot Password',
          style: GoogleFonts.poppins(
            color: Colors.red[400],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Bottom navigation text with link
  static Widget bottomNavigation({
    required String text,
    required String linkText,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            linkText,
            style: GoogleFonts.poppins(
              color: const Color(0xFF4A90E2),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Paramount logo footer
  static Widget paramountFooter() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Image.asset(
          'lib/assets/Paramount_logo.png',
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  /// Common auth screen layout wrapper
  static Widget authScreenLayout({
    required List<Widget> children,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
