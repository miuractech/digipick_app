import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class Preloader2Screen extends StatefulWidget {
  const Preloader2Screen({super.key});

  @override
  State<Preloader2Screen> createState() => _Preloader2ScreenState();
}

class _Preloader2ScreenState extends State<Preloader2Screen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  
  int _currentStep = 0;
  final List<String> _loadingSteps = [
    'Checking Authentication...',
    'Loading User Data...',
    'Preparing Dashboard...',
    'Almost Ready...',
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppCurves.defaultCurve,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startLoadingSequence();
  }

  void _startLoadingSequence() async {
    // Start fade animation
    await _fadeController.forward();
    
    // Start pulse animation loop
    _pulseController.repeat(reverse: true);
    
    // Cycle through loading steps
    for (int i = 0; i < _loadingSteps.length; i++) {
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        await Future.delayed(const Duration(milliseconds: 750));
      }
    }
    
    // Final delay before navigation
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      // Navigate to home or appropriate screen after loading
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _pulseController]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.backgroundColor,
                    Color(0xFFF8F9FA),
                    AppColors.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top section with QCVation logo
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // QCVation Logo
                            Container(
                              width: 180,
                              height: 120,
                              child: Image.asset(
                                'lib/assets/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              'QUALITY CONTROL',
                              style: AppTextStyles.h2.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: AppColors.primaryText.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Middle section with robot-human interaction GIF
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Container(
                          width: 280,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            boxShadow: AppShadows.card,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            child: Image.asset(
                              'lib/assets/robot-human-hand.gif',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom section with loading text and progress
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Loading text
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _loadingSteps[_currentStep],
                              key: ValueKey(_currentStep),
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.lg),
                          
                          // Progress indicator
                          Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primaryText.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 200 * ((_currentStep + 1) / _loadingSteps.length),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF1D4ED8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.md),
                          
                          // Progress percentage
                          Text(
                            '${((_currentStep + 1) / _loadingSteps.length * 100).round()}%',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText.withOpacity(0.7),
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.xxxl),
                          
                          // Paramount logo at bottom
                          SvgPicture.asset(
                            'lib/assets/Paramount_logo.svg',
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
