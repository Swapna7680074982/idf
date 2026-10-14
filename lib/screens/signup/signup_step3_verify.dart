import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
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
  final int codeLength;

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
    this.codeLength = 8,
  });

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final _codeController = TextEditingController();
  late String _currentEmail;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _currentEmail = widget.email;
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() async {
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
      // POST /api/auth/register/verify-email
      final verifyResult = await AuthService.verifyEmail(
        email: _currentEmail,
        code: code,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SignUpStep4Screen(
              fullName: widget.fullName,
              email: _currentEmail,
              phone: widget.phone,
              password: widget.password,
              organizationName: widget.organizationName,
              organizationType: widget.organizationType,
              country: widget.country,
              state: widget.state,
              city: widget.city,
              address: widget.address,
              registrationToken: verifyResult.registrationToken,
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
        email: _currentEmail,
        purpose: 'signup',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A new verification code was sent to $_currentEmail'),
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

  void _showChangeEmailDialog() {
    final newEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Change Email Address',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the new email address for this account. A new verification code will be sent.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'new.email@org.com',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newEmail = newEmailController.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid email address'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);

              setState(() {
                _isLoading = true;
              });

              try {
                // POST /api/auth/register/change-email
                await AuthService.changeEmail(
                  email: _currentEmail,
                  password: widget.password,
                  newEmail: newEmail,
                );

                if (mounted) {
                  setState(() {
                    _currentEmail = newEmail;
                    _codeController.clear();
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Verification code sent to $newEmail'),
                      backgroundColor: const Color(0xFF0284C7),
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update & Send Code'),
          ),
        ],
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
              subtitle: 'Enter the verification code sent to your email',
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
                    'We sent an ${widget.codeLength}-digit code to\n$_currentEmail',
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
                        maxLength: widget.codeLength,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.0,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '12345678',
                          counterText: '',
                          hintStyle: GoogleFonts.inter(
                            letterSpacing: 4.0,
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
                    isLoading: _isLoading,
                    onPressed: _onVerify,
                  ),
                  const SizedBox(height: 20),

                  // Resend Code Button
                  GestureDetector(
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
                  const SizedBox(height: 14),

                  // Change email address
                  GestureDetector(
                    onTap: _showChangeEmailDialog,
                    child: Text(
                      'Change email address',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        decoration: TextDecoration.underline,
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
