import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../widgets/globe_logo.dart';
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
          // Top Blue Gradient Section with Decorative Bubbles
          Expanded(
            flex: 6,
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
                  top: -20,
                  left: -30,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ),
                // Decorative Circle 2 (Right Mid)
                Positioned(
                  top: 90,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(22),
                    ),
                  ),
                ),
                // Decorative Circle 3 (Right Inner)
                Positioned(
                  top: 130,
                  right: 40,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(18),
                    ),
                  ),
                ),
                // Content
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const GlobeLogo(size: 92),
                          const SizedBox(height: 24),
                          Text(
                            'IDF Digital Hub',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Supporting physical activity programs\nand institutional certification for a\nhealthier world.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withAlpha(235),
                              height: 1.45,
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

          // Bottom Action Section
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      // Log In Button
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
                      // Create Account Button
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
                          const TextSpan(text: ' and\n'),
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
