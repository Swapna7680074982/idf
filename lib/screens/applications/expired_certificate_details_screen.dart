import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import '../certification/certification_wizard_screen.dart';

class ExpiredCertificateDetailsScreen extends StatelessWidget {
  final CertificateApplicationItem certificate;

  const ExpiredCertificateDetailsScreen({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Title & Status Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.institutionName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        certificate.certificateId,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Expired',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Warning Notice Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        'Certificate Expired',
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
                    'This certificate expired on ${certificate.expiresDate}. Renew to maintain your IDF Active status.',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: const Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => _openRenewal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    ),
                    child: Text(
                      'Renew Certificate',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 1. Institution Details Card
            _buildSectionCard(
              title: 'Institution Details',
              children: [
                _buildInfoRow('Institution', certificate.institutionName),
                _buildInfoRow('Category', certificate.institutionType),
                _buildInfoRow('Certificate ID', certificate.certificateId),
                _buildInfoRow('Score', certificate.score, isLast: true),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Certificate Period Card
            _buildSectionCard(
              title: 'Certificate Period',
              children: [
                _buildInfoRow('Submitted', '05 Jan 2024'),
                _buildInfoRow('Issue Date', certificate.issuedDate),
                _buildInfoRow('Expiry Date', certificate.expiresDate, isLast: true),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Certification Questionnaire Card
            _buildSectionCard(
              title: 'Certification Questionnaire',
              children: [
                _buildInfoRow('Infrastructure / Amenities', '9/10'),
                _buildInfoRow('Organizational / Policy', '8/10'),
                _buildInfoRow('Individual Level', '7/8'),
                _buildInfoRow('Scalability / Advocacy', '6/8', isLast: true),
              ],
            ),
            const SizedBox(height: 14),

            // 4. AI Audit Card
            _buildSectionCard(
              title: '🔍 AI Audit',
              children: [
                _buildCheckRow('Evidence Review', 'Completed', isDone: true),
                _buildCheckRow('Image / Location Validation', 'Completed', isDone: true),
                _buildCheckRow('Detail / Evidence Match', 'Completed', isDone: true),
                _buildCheckRow('Audit Status', 'Approved', isDone: true, isLast: true),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Application Timeline
            _buildSectionCard(
              title: 'Application Timeline',
              children: [
                _buildTimelineStep(title: 'Submitted', subtitle: '05 Jan 2024'),
                _buildTimelineStep(title: 'AI Audit', subtitle: 'Completed'),
                _buildTimelineStep(title: 'Manual Review', subtitle: 'Approved'),
                _buildTimelineStep(title: 'Scoring', subtitle: 'Final score: ${certificate.score}'),
                _buildTimelineStep(title: 'Certificate', subtitle: 'Issued', isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            // Renew Certificate Button (Inside Flow)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _openRenewal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Renew Certificate',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  void _openRenewal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CertificationWizardScreen(
          initialModel:
              CertificationApplicationModel.prefilledForCertificate(certificate),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String label, String status,
      {required bool isDone, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.check_box_rounded, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 4),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
