import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/email_illustration.dart';
import 'signup_step4_terms.dart';

class SignUpStep3Screen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String organizationName;
  final String organizationType;
  final String country;
  final String state;
  final String city;
  final String address;

  const SignUpStep3Screen({
    super.key,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.organizationName = '',
    this.organizationType = '',
    this.country = '',
    this.state = '',
    this.city = '',
    this.address = '',
  });

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpStep4Screen(
          fullName: widget.fullName,
          email: widget.email,
          phone: widget.phone,
          password: widget.password,
          organizationName: widget.organizationName,
          organizationType: widget.organizationType,
          country: widget.country,
          state: widget.state,
          city: widget.city,
          address: widget.address,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header
            const AuthHeader(
              title: 'Verify Email',
              subtitle: 'Enter the 6-digit code sent to your email',
              currentStep: 3,
              totalSteps: 4,
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  // Email Image from assets
                  Image.asset(
                    'assets/icons/email.png',
                    width: 78,
                    height: 78,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/email.png',
                        width: 78,
                        height: 78,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const EmailIllustration(size: 78);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 22),

                  // Title
                  Text(
                    'Check your email',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'We sent a verification code to your email address.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Verification Code Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Code',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: GoogleFonts.inter(
                            letterSpacing: 2.0,
                            color: AppColors.textMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Verify & Continue Button
                  PrimaryButton(
                    text: 'Verify & Continue',
                    onPressed: _onVerify,
                  ),
                  const SizedBox(height: 20),

                  // Resend Code Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification code resent successfully!'),
                          backgroundColor: AppColors.primaryBlue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Change email address
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Change email address',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
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
}
