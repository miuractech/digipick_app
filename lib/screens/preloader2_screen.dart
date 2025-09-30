import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

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
  
  
  int _currentStep = 0;
  final List<String> _loadingSteps = [
    'Checking Authentication...',
    'Verifying User Access...',
    'Loading Device Data...',
    'Preparing Dashboard...',
    'Ready!',
  ];
  
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userRole;
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _loadingStartTime;

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

    _startLoadingSequence();
  }

  void _startLoadingSequence() async {
    try {
      // Record start time for minimum display duration
      _loadingStartTime = DateTime.now();
      
      // Start fade animation
      await _fadeController.forward();
      
      // Start pulse animation loop
      _pulseController.repeat(reverse: true);
      
      // Step 1: "Checking Authentication..." - Check if user is logged in
      if (mounted) {
        setState(() {
          _currentStep = 0;
        });
      }
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        // User not authenticated, ensure minimum display time before redirect
        await _ensureMinimumDisplayTime();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
        return;
      }
      
      // Step 2: "Verifying User Access..." - Check authorization and load user role
      if (mounted) {
        setState(() {
          _currentStep = 1;
        });
      }
      final isAuthorized = await _authService.checkUserAuthorization(currentUser.id);
      if (!isAuthorized) {
        setState(() {
          _hasError = true;
          _errorMessage = 'User not authorized. Please contact administrator.';
        });
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signOut();
          Navigator.of(context).pushReplacementNamed('/auth');
        }
        return;
      }
      
      _userRole = await _authService.getPrimaryUserRole(currentUser.id);
      if (_userRole == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load user profile. Please try again.';
        });
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
        return;
      }
      
      // Step 3: "Loading Device Data..." - Load devices and statistics
      if (mounted) {
        setState(() {
          _currentStep = 2;
        });
      }
      
      await _authService.getDevicesForUser(currentUser.id);
      await _authService.getDeviceStatisticsForUser(currentUser.id);
      
      // Step 4: "Preparing Dashboard..." - Update auth provider with loaded data
      if (mounted) {
        setState(() {
          _currentStep = 3;
        });
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.recheckAuthorization();
      
      // Check if organization is archived
      if (authProvider.isOrganizationArchived && authProvider.organization != null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Access restricted. Please contact Paramount Instruments.';
        });
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/archived_organization');
        }
        return;
      }
      
      // Check if user is still authorized after organization check
      if (!authProvider.isAuthorized) {
        Navigator.of(context).pushReplacementNamed('/unauthorized');
        return;
      }
      
      // Step 5: "Ready!" - Show completion
      if (mounted) {
        setState(() {
          _currentStep = 4;
        });
      }
      
      // Ensure minimum display time of 1 second
      await _ensureMinimumDisplayTime();
      
      if (mounted) {
        // Navigate to home with all data preloaded
        Navigator.of(context).pushReplacementNamed('/home');
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load application data. Please check your connection and try again.';
        });
        await Future.delayed(const Duration(seconds: 3));
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    }
  }

  Future<void> _ensureMinimumDisplayTime() async {
    if (_loadingStartTime == null) return;
    
    const minimumDisplayDuration = Duration(seconds: 3);
    final elapsedTime = DateTime.now().difference(_loadingStartTime!);
    
    if (elapsedTime < minimumDisplayDuration) {
      final remainingTime = minimumDisplayDuration - elapsedTime;
      await Future.delayed(remainingTime);
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
                          // Loading text or error message
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _hasError ? 
                              Column(
                                key: ValueKey('error'),
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red[600],
                                    size: 32,
                                  ),
                                  const SizedBox(height: AppSizes.sm),
                                  Text(
                                    _errorMessage ?? 'An error occurred',
                                    style: AppTextStyles.h3.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ) :
                              Text(
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
                          
                          // Progress indicator (only show if not error)
                          if (!_hasError) ...[
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
                            
                          ],
                          
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
