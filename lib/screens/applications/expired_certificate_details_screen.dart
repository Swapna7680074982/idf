import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/date_time_utils.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import '../../services/certification_service.dart';
import 'renewal/renewal_wizard_screen.dart';

class ExpiredCertificateDetailsScreen extends StatefulWidget {
  final CertificateApplicationItem certificate;

  const ExpiredCertificateDetailsScreen({
    super.key,
    required this.certificate,
  });

  @override
  State<ExpiredCertificateDetailsScreen> createState() =>
      _ExpiredCertificateDetailsScreenState();
}

class _ExpiredCertificateDetailsScreenState
    extends State<ExpiredCertificateDetailsScreen> {
  CertificationApplicationDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    final certId = widget.certificate.id.isNotEmpty
        ? widget.certificate.id
        : widget.certificate.applicationNo;

    if (certId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final detail = await CertificationService.getApplicationDetail(certId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cert = widget.certificate;
    final detail = _detail;
    final inst = detail?.institution;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
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
                              inst?.name ?? cert.institutionName,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (cert.certificateId.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                cert.certificateId,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDBA74)),
                        ),
                        child: Text(
                          cert.displayReviewStatus,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFEA580C),
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
                              cert.displayReviewStatus,
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
                          cert.expiresDate.isNotEmpty
                              ? 'This certificate expired on ${DateTimeUtils.formatDateTime(cert.expiresDate)}. Renew to maintain your IDF Active status.'
                              : 'Renew your certificate to maintain your IDF Active accreditation status.',
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
                            backgroundColor: const Color(0xFFEA580C),
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

                  // 1. Institution Details Card (Only real fields)
                  _buildSectionCard(
                    title: 'Institution Details',
                    children: [
                      _buildInfoRow('Institution', inst?.name ?? cert.institutionName),
                      if ((inst?.category ?? cert.institutionType).isNotEmpty)
                        _buildInfoRow('Category', inst?.category ?? cert.institutionType),
                      if (cert.certificateId.isNotEmpty)
                        _buildInfoRow('Certificate ID', cert.certificateId),
                      if (inst != null && inst.contactPerson.isNotEmpty)
                        _buildInfoRow('Contact Person', inst.contactPerson),
                      if (inst != null && inst.contactEmail.isNotEmpty)
                        _buildInfoRow('Contact Email', inst.contactEmail),
                      if (inst != null && inst.contactPhone.isNotEmpty)
                        _buildInfoRow('Contact Phone', inst.contactPhone),
                      if (inst != null && inst.address.isNotEmpty && inst.address != '—')
                        _buildInfoRow('Address', inst.address),
                      if (inst != null && inst.country.isNotEmpty && inst.country != '—')
                        _buildInfoRow('Country', inst.country),
                      if (cert.score.isNotEmpty)
                        _buildInfoRow('Score', cert.score, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Certificate Period Card (Only real dates, no dummy fallback)
                  if (cert.issuedDate.isNotEmpty ||
                      cert.expiresDate.isNotEmpty ||
                      (detail != null && detail.submittedAt != null && detail.submittedAt!.isNotEmpty)) ...[
                    _buildSectionCard(
                      title: 'Certificate Period',
                      children: [
                        if (detail != null && detail.submittedAt != null && detail.submittedAt!.isNotEmpty)
                          _buildInfoRow(
                            'Submitted',
                            DateTimeUtils.formatDateTime(detail.submittedAt!),
                          ),
                        if (cert.issuedDate.isNotEmpty)
                          _buildInfoRow(
                            'Issue Date',
                            DateTimeUtils.formatDateTime(cert.issuedDate),
                          ),
                        if (cert.expiresDate.isNotEmpty)
                          _buildInfoRow(
                            'Expiry Date',
                            DateTimeUtils.formatDateTime(cert.expiresDate),
                            isLast: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 3. AI Audit Card (Only real checks if present from API)
                  if (detail != null && detail.aiValidation.isNotEmpty) ...[
                    _buildSectionCard(
                      title: '🔍 AI Audit',
                      children: detail.aiValidation.map((c) {
                        final isApproved = c.status.toLowerCase() == 'approved';
                        return _buildCheckRow(
                          c.label,
                          isApproved ? 'Approved' : c.status,
                          isDone: isApproved,
                          isLast: c == detail.aiValidation.last,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 4. Application Timeline (Only real stages if present from API)
                  if (detail != null && detail.timeline.isNotEmpty) ...[
                    _buildSectionCard(
                      title: 'Application Timeline',
                      children: detail.timeline.map((stage) {
                        return _buildTimelineStep(
                          title: stage.label,
                          subtitle: stage.occurredAt != null
                              ? DateTimeUtils.formatDateTime(stage.occurredAt!)
                              : (stage.note ?? stage.state),
                          isLast: stage == detail.timeline.last,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Renew Certificate Button (Bottom)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _openRenewal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
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
        builder: (_) => RenewalWizardScreen(certificate: widget.certificate),
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
