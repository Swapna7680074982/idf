import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/token_storage.dart';
import '../widgets/dr_mohans_logo.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Keep splash visible for at least 1.5 seconds for branding animation
    final minSplashDuration = Future.delayed(const Duration(milliseconds: 1500));

    await TokenStorage.init();

    final hasTokens = TokenStorage.isAuthenticated ||
        (TokenStorage.refreshToken != null && TokenStorage.refreshToken!.isNotEmpty);

    bool shouldNavigateToHome = false;

    if (hasTokens) {
      try {
        final authUser = await AuthService.getMe();
        if (mounted) {
          context.read<AppBloc>().add(SetAuthenticatedUser(authUser));
        }
        shouldNavigateToHome = true;
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          // Token has expired and refresh token rotation failed
          await TokenStorage.clearAuth();
          shouldNavigateToHome = false;
        } else {
          // Network error or server glitch: if cached user exists, stay logged in
          if (TokenStorage.currentUser != null) {
            if (mounted) {
              context.read<AppBloc>().add(SetAuthenticatedUser(TokenStorage.currentUser!));
            }
            shouldNavigateToHome = true;
          } else {
            shouldNavigateToHome = false;
          }
        }
      } catch (_) {
        // Offline / socket error: keep session if user data was previously saved
        if (TokenStorage.currentUser != null) {
          if (mounted) {
            context.read<AppBloc>().add(SetAuthenticatedUser(TokenStorage.currentUser!));
          }
          shouldNavigateToHome = true;
        } else {
          shouldNavigateToHome = false;
        }
      }
    }

    await minSplashDuration;
    if (!mounted) return;

    final targetScreen = shouldNavigateToHome ? const HomeScreen() : const WelcomeScreen();
    if (shouldNavigateToHome) {
      FirebaseService.syncTokenWithBackend();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.blueGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),

              // Center Logo & Title
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DrMohansLogo(
                    size: 52,
                    withWhiteBackground: true,
                    borderRadius: 18,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Dr. Mohan's",
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DIABETES SPECIALITIES CENTRE',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(210),
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),

              // Bottom Powered By
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Powered by',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withAlpha(190),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Hetero Healthcare',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
