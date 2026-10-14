import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // POST /api/auth/forgot-password
      final forgotResult = await AuthService.forgotPassword(email: email);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A verification code has been sent to $email'),
            backgroundColor: const Color(0xFF0284C7),
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordStep2Screen(
              email: email,
              codeLength: forgotResult.verification.codeLength,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
                    isLoading: _isLoading,
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
  final int codeLength;

  const ResetPasswordStep2Screen({
    super.key,
    required this.email,
    this.codeLength = 6,
  });

  @override
  State<ResetPasswordStep2Screen> createState() => _ResetPasswordStep2ScreenState();
}

class _ResetPasswordStep2ScreenState extends State<ResetPasswordStep2Screen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // POST /api/auth/verify-reset-code
      final verifyResult = await AuthService.verifyResetCode(
        email: widget.email,
        code: code,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResetPasswordStep3Screen(
              email: widget.email,
              resetToken: verifyResult.resetToken,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onResendCode() async {
    if (_isResending) return;
    setState(() {
      _isResending = true;
    });

    try {
      // POST /api/auth/resend-code
      await AuthService.resendCode(
        email: widget.email,
        purpose: 'password_reset',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code resent to ${widget.email}'),
            backgroundColor: const Color(0xFF0284C7),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
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
                    hintText: '${widget.codeLength}-digit code',
                    keyboardType: TextInputType.number,
                    controller: _codeController,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    text: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _onContinue,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: _isResending ? null : _onResendCode,
                      child: Text(
                        _isResending ? 'Resending...' : 'Resend Code',
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
  final String resetToken;

  const ResetPasswordStep3Screen({
    super.key,
    this.email = '',
    this.resetToken = '',
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
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters long'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // POST /api/auth/reset-password
      final successMsg = await AuthService.resetPassword(
        resetToken: widget.resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: const Color(0xFF0284C7),
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
