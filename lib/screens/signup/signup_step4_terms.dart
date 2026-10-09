import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../core/theme.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import 'signup_success.dart';

class SignUpStep4Screen extends StatefulWidget {
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

  const SignUpStep4Screen({
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
  State<SignUpStep4Screen> createState() => _SignUpStep4ScreenState();
}

class _SignUpStep4ScreenState extends State<SignUpStep4Screen> {
  bool _agreedToTerms = false;
  bool _confirmedAccuracy = false;
  bool _isLoading = false;

  void _onCreateAccount() async {
    setState(() {
      _isLoading = true;
    });

    context.read<AppBloc>().add(
          RegisterAccountRequested(
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
        );

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AccountCreatedScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _agreedToTerms && _confirmedAccuracy;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header
            const AuthHeader(
              title: 'Terms & Consent',
              subtitle: 'Please review and accept the terms',
              currentStep: 4,
              totalSteps: 4,
            ),

            // Form & Terms Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Terms Box Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms of Service',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'By registering for the IDF Digital Hub, you agree to use this platform solely for legitimate physical activity program submissions and IDF ACTIVE certification applications. You warrant that all information provided is accurate and complete. The International Diabetes Federation reserves the right to verify, reject, or remove any submissions that violate these terms.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Checkbox 1
                  _buildCustomCheckbox(
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                      });
                    },
                    labelWidget: Text.rich(
                      TextSpan(
                        text: 'I have read and agree to the ',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFF334155),
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checkbox 2
                  _buildCustomCheckbox(
                    value: _confirmedAccuracy,
                    onChanged: (val) {
                      setState(() {
                        _confirmedAccuracy = val ?? false;
                      });
                    },
                    labelWidget: Text(
                      'I confirm that the information and evidence I provide will be accurate and complete to the best of my knowledge.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF334155),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create Account Button
                  PrimaryButton(
                    text: 'Create Account',
                    isEnabled: canSubmit,
                    isLoading: _isLoading,
                    onPressed: canSubmit ? _onCreateAccount : null,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget labelWidget,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              color: value ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: value ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          Expanded(child: labelWidget),
        ],
      ),
    );
  }
}
