import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'globe_logo.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? currentStep;
  final int? totalSteps;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool showLogo;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.currentStep,
    this.totalSteps,
    this.onBack,
    this.showBackButton = true,
    this.showLogo = false,
  });

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      padding: EdgeInsets.only(
        top: topPadding + 8,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          if (showBackButton)
            GestureDetector(
              onTap: () => _handleBack(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 28),

          // Optional Logo
          if (showLogo) ...[
            const GlobeLogo(size: 54, showBackgroundGlow: false),
            const SizedBox(height: 14),
          ],

          // Step count (e.g. STEP 1 OF 4)
          if (currentStep != null && totalSteps != null) ...[
            Text(
              'STEP $currentStep OF $totalSteps',
              style: GoogleFonts.inter(
                color: Colors.white.withAlpha(204),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white.withAlpha(210),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),

          // Stepper indicator pills
          if (currentStep != null && totalSteps != null) ...[
            const SizedBox(height: 14),
            Row(
              children: List.generate(totalSteps!, (index) {
                final stepIndex = index + 1;
                final isActive = stepIndex == currentStep;
                final isCompleted = stepIndex < currentStep!;

                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: isActive ? 26 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? Colors.white
                        : Colors.white.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
