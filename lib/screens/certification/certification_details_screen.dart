import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import 'certification_wizard_screen.dart';

class CertificationDetailsScreen extends StatelessWidget {
  final CertificationApplicationModel? application;

  const CertificationDetailsScreen({super.key, this.application});

  @override
  Widget build(BuildContext context) {
    final app = application ??
        CertificationApplicationModel.prefilledForCertificate(
          const CertificateApplicationItem(
            id: '2',
            institutionName: 'Lagos State University',
            institutionType: 'College / University',
            certificateId: '',
            issuedDate: '01 Sep 2025',
            expiresDate: '01 Sep 2027',
            status: 'Changes Required',
            score: '7/10',
          ),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Application Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('🏫', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '${app.institutionTypeTitle}${(app.applicationId != null && app.applicationId!.isNotEmpty) ? ' · ${app.applicationId}' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Changes Required',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Submitted: 9/15/2026',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Auditor Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📝', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Auditor Action Items',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Safe Exercise Area photo is missing GPS metadata.\n• Please attach the formal physical activity policy document.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: const Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Score Summary
            Text(
              'Audit Score Breakdown',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildScoreRow('Infrastructure / Amenities', '4 / 5 pts'),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  _buildScoreRow('Organizational / Policy', '3 / 4 pts'),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  _buildScoreRow('Individual Level', '2 / 3 pts'),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  _buildScoreRow('Scalability / Advocacy', '2 / 2 pts'),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                  _buildScoreRow('Total Score', '11 / 14 pts', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action Button: Update Application
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CertificationWizardScreen(
                        initialModel: app,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: Text(
                  'Update Application',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String score, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 13.5 : 12.5,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : const Color(0xFF64748B),
          ),
        ),
        Text(
          score,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 13.5 : 12.5,
            fontWeight: FontWeight.w700,
            color: isTotal ? AppColors.primaryBlue : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
