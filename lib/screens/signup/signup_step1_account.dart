import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../login_screen.dart';
import 'signup_step2_organization.dart';

import '../../data/countries_data.dart';
import '../../models/meta_models.dart';
import '../../core/validators.dart';

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
  Country _selectedCountry = CountryData.defaultCountry;

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
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final phoneError = CountryData.validatePhoneNumber(
      country: _selectedCountry,
      phoneNumber: phone,
      isRequired: true,
      fieldName: 'mobile number',
    );
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpStep2Screen(
          fullName: fullName,
          email: email,
          phone: phone,
          phoneCountryCode: _selectedCountry.phoneCode,
          password: password,
          confirmPassword: confirmPassword,
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
              subtitle: 'Create your IDF Activate account',
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
                    capitalizeWords: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  CountryPhoneInputField(
                    label: 'Mobile Number',
                    hintText: 'Enter mobile number',
                    controller: _phoneController,
                    initialCountry: _selectedCountry,
                    textInputAction: TextInputAction.next,
                    onCountryChanged: (c) {
                      setState(() {
                        _selectedCountry = c;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  PasswordTextField(
                    label: 'Password',
                    hintText: 'Min. 8 characters',
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  PasswordTextField(
                    label: 'Confirm Password',
                    hintText: 'Repeat password',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
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
