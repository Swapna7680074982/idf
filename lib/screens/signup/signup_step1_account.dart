import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../login_screen.dart';
import 'signup_step2_organization.dart';

class SignUpStep1Screen extends StatefulWidget {
  const SignUpStep1Screen({super.key});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpStep2Screen(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
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
              title: 'Account Details',
              subtitle: 'Create your IDF Digital Hub account',
              currentStep: 1,
              totalSteps: 4,
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Dr. Jane Smith',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),

                  PhoneInputField(
                    label: 'Mobile Number',
                    hintText: '0987654321',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 16),

                  PasswordTextField(
                    label: 'Password',
                    hintText: 'Min. 8 characters',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 16),

                  PasswordTextField(
                    label: 'Confirm Password',
                    hintText: 'Repeat password',
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 28),

                  // Continue Button
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: _onContinue,
                  ),
                  const SizedBox(height: 20),

                  // Log In Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
