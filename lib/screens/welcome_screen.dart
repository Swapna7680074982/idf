import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../widgets/dr_mohans_logo.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'signup/signup_step1_account.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Blue Gradient Section with Decorative Bubbles (Image 2)
          Expanded(
            flex: 65,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.blueGradient,
                  ),
                ),
                // Decorative Circle 1 (Top Left)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ),
                // Decorative Circle 2 (Right Mid Large)
                Positioned(
                  top: 60,
                  right: 30,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(18),
                    ),
                  ),
                ),
                // Decorative Circle 3 (Right Mid Inner Overlay)
                Positioned(
                  top: 110,
                  right: 65,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(16),
                    ),
                  ),
                ),
                // Center Content (Logo + Dr. Mohan's + Diabetes Specialities centre)
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const DrMohansLogo(
                            size: 52,
                            withWhiteBackground: true,
                            borderRadius: 18,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            "Dr. Mohan's",
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Diabetes Specialities centre',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withAlpha(240),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Section (White Background)
          Expanded(
            flex: 35,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      // Log In Button (Blue)
                      PrimaryButton(
                        text: 'Log In',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      // Create Account Button (Outlined)
                      OutlineButtonWidget(
                        text: 'Create Account',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpStep1Screen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Terms & Privacy Notice
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text.rich(
                      TextSpan(
                        text: 'By continuing, you agree to our ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
