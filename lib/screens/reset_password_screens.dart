import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../core/theme.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

// -------------------------------------------------------------
// Step 1: Request Email
// -------------------------------------------------------------
class ResetPasswordStep1Screen extends StatefulWidget {
  const ResetPasswordStep1Screen({super.key});

  @override
  State<ResetPasswordStep1Screen> createState() => _ResetPasswordStep1ScreenState();
}

class _ResetPasswordStep1ScreenState extends State<ResetPasswordStep1Screen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final email = _emailController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordStep2Screen(
          email: email.isNotEmpty ? email : '123@gmail.com',
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
            const AuthHeader(
              title: 'Reset Password',
              subtitle: 'Enter your email to receive a verification code',
              currentStep: 1,
              totalSteps: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: _onContinue,
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

// -------------------------------------------------------------
// Step 2: Verify Code
// -------------------------------------------------------------
class ResetPasswordStep2Screen extends StatefulWidget {
  final String email;

  const ResetPasswordStep2Screen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordStep2Screen> createState() => _ResetPasswordStep2ScreenState();
}

class _ResetPasswordStep2ScreenState extends State<ResetPasswordStep2Screen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordStep3Screen(
          email: widget.email,
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
            AuthHeader(
              title: 'Verify Email',
              subtitle: 'We sent a code to ${widget.email}',
              currentStep: 2,
              totalSteps: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Verification Code',
                    hintText: '6-digit code',
                    keyboardType: TextInputType.number,
                    controller: _codeController,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    text: 'Continue',
                    onPressed: _onContinue,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification code resent successfully!'),
                            backgroundColor: AppColors.primaryBlue,
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

// -------------------------------------------------------------
// Step 3: New Password
// -------------------------------------------------------------
class ResetPasswordStep3Screen extends StatefulWidget {
  final String email;

  const ResetPasswordStep3Screen({
    super.key,
    this.email = '123@gmail.com',
  });

  @override
  State<ResetPasswordStep3Screen> createState() => _ResetPasswordStep3ScreenState();
}

class _ResetPasswordStep3ScreenState extends State<ResetPasswordStep3Screen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword() async {
    setState(() {
      _isLoading = true;
    });

    context.read<AppBloc>().add(
          ResetPasswordRequested(
            email: widget.email,
            newPassword: _newPasswordController.text,
          ),
        );

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please log in.'),
          backgroundColor: AppColors.primaryBlue,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHeader(
              title: 'New Password',
              subtitle: 'Create a new secure password',
              currentStep: 3,
              totalSteps: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasswordTextField(
                    label: 'New Password',
                    hintText: 'Min. 8 characters',
                    controller: _newPasswordController,
                  ),
                  const SizedBox(height: 18),

                  PasswordTextField(
                    label: 'Confirm Password',
                    hintText: 'Repeat password',
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    text: 'Reset Password',
                    isLoading: _isLoading,
                    onPressed: _onResetPassword,
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
