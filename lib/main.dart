import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/preloader_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/unauthorized_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://owcanqgrymdruzdrttfo.supabase.co',
    anonKey: 'sb_publishable_h4qjPODt0V22BAolM6R_ug_OrkKwQ6b',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        
        return ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          child: MaterialApp(
            title: 'IMAGEPICK',
            theme: AppTheme.lightTheme,
            home: const PreloaderScreen(),
            routes: {
              '/preloader': (context) => const PreloaderScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/unauthorized': (context) => const UnauthorizedScreen(),
              '/auth': (context) => const AuthWrapper(),
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    // Small delay to ensure Supabase is fully initialized
    await Future.delayed(Duration(milliseconds: 100));
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Only show loading screen during initial load (not when authenticated)
        if (authProvider.isLoading && !authProvider.isInitialized) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Text(
                          'Loading...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          if (authProvider.isAuthorized) {
            return const HomeScreen();
          } else if (authProvider.isLoading) {
            // Show a minimal loading indicator for authorization check
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Setting up your account...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.tertiaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const UnauthorizedScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

