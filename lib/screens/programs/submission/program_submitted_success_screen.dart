import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/date_time_utils.dart';
import '../../../models/application_item_model.dart';
import '../../../models/program_model.dart';
import '../../../models/program_submission_model.dart';
import '../../../widgets/custom_button.dart';
import '../../applications/program_application_details_screen.dart';
import '../../home_screen.dart';

class ProgramSubmittedSuccessScreen extends StatelessWidget {
  final ProgramSubmissionModel submission;
  final ProgramApplicationItem? applicationItem;
  final ProgramModel? programModel;

  const ProgramSubmittedSuccessScreen({
    super.key,
    required this.submission,
    this.applicationItem,
    this.programModel,
  });

  @override
  Widget build(BuildContext context) {
    final refNumber = (submission.referenceNumber != null && submission.referenceNumber!.trim().isNotEmpty)
        ? submission.referenceNumber!.trim()
        : '—';
    final now = submission.submissionDate ?? DateTime.now();
    final dateStr = DateTimeUtils.formatDateTime(now.toIso8601String());

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
                'Your proposal has been received and evaluated by the AI auditing engine.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

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
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailRow(
                      iconEmoji: '📅',
                      label: 'SUBMISSION DATE',
                      value: dateStr,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailRow(
                      iconEmoji: '📊',
                      label: 'CURRENT STATUS',
                      value: submission.status,
                      valueColor: AppColors.primaryBlue,
                      isBoldValue: true,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailRow(
                      iconEmoji: '🤖',
                      label: 'AI VALIDATION',
                      value: 'Automated parameter audit ready',
                      valueColor: const Color(0xFF10B981),
                      isBoldValue: true,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Buttons
              CustomButton(
                text: 'View AI Validation & Score',
                onPressed: () {
                  final item = applicationItem ??
                      ProgramApplicationItem(
                        id: submission.referenceNumber ?? '',
                        programName: submission.programName,
                        programType: submission.programType,
                        category: submission.programType,
                        referenceNumber: refNumber,
                        startDate: submission.startDate != null
                            ? '${submission.startDate!.year}-${submission.startDate!.month.toString().padLeft(2, '0')}-${submission.startDate!.day.toString().padLeft(2, '0')}'
                            : '',
                        endDate: submission.endDate != null
                            ? '${submission.endDate!.year}-${submission.endDate!.month.toString().padLeft(2, '0')}-${submission.endDate!.day.toString().padLeft(2, '0')}'
                            : '',
                        location: [submission.city, submission.country]
                            .where((s) => s.isNotEmpty)
                            .join(', '),
                        venue: submission.venueAddress,
                        organizer: submission.organizingEntityName.isNotEmpty
                            ? submission.organizingEntityName
                            : 'You (Organizer)',
                        submittedDate: dateStr,
                        lastUpdatedDate: dateStr,
                        status: submission.status,
                        description: submission.description.isNotEmpty
                            ? submission.description
                            : submission.programDescription,
                        banner: submission.bannerUrl ?? submission.bannerPath,
                        contactPerson: submission.contactPerson,
                        contactPhone: submission.phone,
                        contactEmail: submission.email,
                        supportingMaterials: submission.uploadedFileNames,
                        materials: submission.materials,
                        agenda: submission.agendaItems,
                      );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProgramApplicationDetailsScreen(item: item),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(
                        initialTabIndex: 3,
                        initialAppTabIndex: 0,
                      ),
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
                  'My Applications',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
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
