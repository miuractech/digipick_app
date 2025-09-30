import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class PreloaderScreen extends StatefulWidget {
  const PreloaderScreen({super.key});

  @override
  State<PreloaderScreen> createState() => _PreloaderScreenState();
}

class _PreloaderScreenState extends State<PreloaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Preloader duration variable
  static const Duration preloaderDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.defaultCurve,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.smoothCurve,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();
    // Navigate to preloader2 after first preloader
    await Future.delayed(preloaderDuration);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/preloader2');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundColor,
                      Color(0xFFFFFFFF),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                      decoration: BoxDecoration(
                        color: Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: AppSizes.xxxl * 2),
                          
                          // Rise Above Logo
                          Container(
                            width: 200,
                            height: 140,
                          
                            child: Center(
                              child: Image.asset(
                                'lib/assets/logo-square.png',
                             
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.xxxl * 2),
                          
                          // Welcome Text
                          Text(
                            'WELCOME',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            'to the',
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'WORLD OF',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: AppColors.primaryText,
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.xxxl * 3),
                          
                          // Paramount Logo Section
                          Column(
                            children: [
                              // Paramount Logo
                              SvgPicture.asset(
                                'lib/assets/Paramount_logo.svg',
                               
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: AppSizes.xs),
                             
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.xxxl * 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
