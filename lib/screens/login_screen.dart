import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_event.dart';
import '../core/theme.dart';
import '../widgets/auth_header.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';
import 'reset_password_screens.dart';
import 'signup/signup_step1_account.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Empty controllers so grey placeholders show properly
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authResult = await AuthService.login(
        email: email,
        password: password,
      );

      if (mounted) {
        context.read<AppBloc>().add(SetAuthenticatedUser(authResult.user));
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
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
            content: Text('Login failed: ${e.toString()}'),
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
            // Top Header
            AuthHeader(
              title: 'Welcome back',
              subtitle: 'Sign in to your IDF Digital Hub account',
              onBack: () => Navigator.of(context).pop(),
            ),

            // Login Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 18),

                  PasswordTextField(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordStep1Screen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Log In Button
                  PrimaryButton(
                    text: 'Log In',
                    isLoading: _isLoading,
                    onPressed: _onLogin,
                  ),
                  const SizedBox(height: 24),

                  // Create Account Link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SignUpStep1Screen(),
                          ),
                        );
                      },
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(
                              text: 'Create Account',
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
