import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/program_submission_model.dart';
import '../../../widgets/custom_button.dart';
import '../../home_screen.dart';

class ProgramSubmittedSuccessScreen extends StatelessWidget {
  final ProgramSubmissionModel submission;

  const ProgramSubmittedSuccessScreen({
    super.key,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final refNumber = submission.referenceNumber ??
        'APP-PRG-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 11)}';
    final now = submission.submissionDate ?? DateTime.now();
    final dateStr = '${now.month}/${now.day}/${now.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Celebration Emoji / Illustration
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withAlpha(120),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 46),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Program Submitted!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Your program has been submitted and is under review.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      iconEmoji: '🏷️',
                      label: 'REFERENCE NUMBER',
                      value: refNumber,
                      isBoldValue: true,
                    ),
                    const Divider(height: 22, color: AppColors.border),
                    _buildDetailRow(
                      iconEmoji: '📅',
                      label: 'SUBMISSION DATE',
                      value: dateStr,
                    ),
                    const Divider(height: 22, color: AppColors.border),
                    _buildDetailRow(
                      iconEmoji: '📊',
                      label: 'CURRENT STATUS',
                      value: submission.status,
                      valueColor: AppColors.primaryBlue,
                      isBoldValue: true,
                    ),
                    const Divider(height: 22, color: AppColors.border),
                    _buildDetailRow(
                      iconEmoji: 'ℹ️',
                      label: 'NEXT STEP',
                      value: 'AI validation will complete within 24 hours',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Buttons
              CustomButton(
                text: 'View Applications',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String iconEmoji,
    required String label,
    required String value,
    bool isBoldValue = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(iconEmoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
