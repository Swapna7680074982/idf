import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../core/theme.dart';
import '../../models/meta_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../services/metadata_service.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../common/legal_document_screen.dart';
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
  final String registrationToken;

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
    this.registrationToken = '',
  });

  @override
  State<SignUpStep4Screen> createState() => _SignUpStep4ScreenState();
}

class _SignUpStep4ScreenState extends State<SignUpStep4Screen> {
  bool _agreedToTerms = false;
  bool _confirmedAccuracy = false;
  bool _isLoading = false;

  LegalDocument? _termsDoc;
  bool _isLoadingTerms = true;
  String? _termsError;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        LegalDocumentScreen.open(
          context,
          slug: 'terms',
          title: 'Terms of Service',
          document: _termsDoc,
        );
      };

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        LegalDocumentScreen.open(
          context,
          slug: 'privacy',
          title: 'Privacy Policy',
        );
      };

    _loadTerms();
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _loadTerms() async {
    setState(() {
      _isLoadingTerms = true;
      _termsError = null;
    });

    try {
      final doc = await MetadataService.getLegalDocumentBySlug('terms');
      if (mounted) {
        setState(() {
          _termsDoc = doc;
          _isLoadingTerms = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _termsError = 'Unable to load Terms of Service. Please check your network connection.';
          _isLoadingTerms = false;
        });
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final clean = email.replaceFirst('mailto:', '').trim();
    final uri = Uri(scheme: 'mailto', path: clean);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  List<InlineSpan> _buildClickableSpans(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(
      r'(\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b)|(https?:\/\/[^\s<>"{}|\\^`]+)|(mailto:[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})',
      caseSensitive: false,
    );

    int lastIndex = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      final matchedStr = match.group(0)!;
      final isEmail = match.group(1) != null || match.group(3) != null;
      final displayStr = matchedStr.startsWith('mailto:') ? matchedStr.substring(7) : matchedStr;

      spans.add(
        TextSpan(
          text: displayStr,
          style: baseStyle.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (isEmail) {
                _launchEmail(matchedStr);
              } else {
                final uri = Uri.tryParse(matchedStr);
                if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }

  void _onCreateAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // POST /api/auth/register/complete
      final authResult = await AuthService.registerComplete(
        registrationToken: widget.registrationToken,
        acceptTerms: _agreedToTerms,
        confirmAccuracy: _confirmedAccuracy,
        deviceName: 'Mobile App',
        pushToken: FirebaseService.token,
      );

      if (mounted) {
        context.read<AppBloc>().add(SetAuthenticatedUser(authResult.user));
        FirebaseService.syncTokenWithBackend();
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const AccountCreatedScreen(),
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
            content: Text('Registration completion error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _termsDoc?.title.isNotEmpty == true
                                  ? _termsDoc!.title
                                  : 'Terms of Service',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_termsDoc?.version.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Text(
                                  'v${_termsDoc!.version}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_isLoadingTerms)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          )
                        else if (_termsError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _termsError!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _loadTerms,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text(
                                    'Retry Loading',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    foregroundColor: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: const BoxConstraints(maxHeight: 180),
                                child: SingleChildScrollView(
                                  child: Text.rich(
                                    TextSpan(
                                      children: _buildClickableSpans(
                                        _termsDoc!.content,
                                        GoogleFonts.inter(
                                          fontSize: 12.5,
                                          color: const Color(0xFF475569),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  LegalDocumentScreen.open(
                                    context,
                                    slug: 'terms',
                                    title: 'Terms of Service',
                                    document: _termsDoc,
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View full document',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 13,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: _privacyRecognizer,
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
