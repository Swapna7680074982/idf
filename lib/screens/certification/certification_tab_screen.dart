import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/date_time_utils.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import '../../services/certification_service.dart';
import '../applications/certificate_view_screen.dart';
import '../applications/expired_certificate_details_screen.dart';
import '../applications/renewal/renewal_wizard_screen.dart';
import 'certification_details_screen.dart';
import 'certification_wizard_screen.dart';

class CertificationTabScreen extends StatefulWidget {
  final Future<void> Function()? onRefresh;

  const CertificationTabScreen({
    super.key,
    this.onRefresh,
  });

  @override
  State<CertificationTabScreen> createState() => _CertificationTabScreenState();
}

class _CertificationTabScreenState extends State<CertificationTabScreen> {
  CertificateApplicationItem? _latestApp;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestApplication();
  }

  Future<void> _fetchLatestApplication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final certs = await CertificationService.getMyCertificateApplications();
      if (mounted) {
        final items = certs
            .map((c) => CertificateApplicationItem.fromJson(c))
            .toList();
        // Sort latest first (by id descending or date descending)
        items.sort((a, b) {
          final idA = int.tryParse(a.id) ?? 0;
          final idB = int.tryParse(b.id) ?? 0;
          return idB.compareTo(idA);
        });

        setState(() {
          _latestApp = items.isNotEmpty ? items.first : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      if (widget.onRefresh != null) widget.onRefresh!(),
      _fetchLatestApplication(),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'IDF Active',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Accreditation & Certification',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Teal Hero Banner Card
            _buildHeroCard(context),
            const SizedBox(height: 24),

            // Current Application Section
            Text(
              'Current Application',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              _buildLoadingCard()
            else if (_latestApp != null)
              _buildCurrentApplicationCard(context, _latestApp!)
            else
              _buildEmptyApplicationCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF00828A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00828A).withAlpha(45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🏅', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'IDF Active Certification',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Certify your institution / workplace for promoting physical activity, lifelong movement & healthier lifestyle.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withAlpha(235),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CertificationWizardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00828A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Apply for Certification',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCertBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);
    Color border = const Color(0xFFE2E8F0);

    final s = status.trim().toLowerCase();
    String displayLabel = status;

    if (s == 'active' || s == 'approved' || s == 'completed' || s == 'certified') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      border = const Color(0xFF86EFAC);
      displayLabel = 'Approved';
    } else if (s == 'renew in progress' || s == 'renew_in_progress' || s.contains('progress')) {
      bg = const Color(0xFFEFF6FF);
      text = const Color(0xFF2563EB);
      border = const Color(0xFF93C5FD);
      displayLabel = 'Renew in Progress';
    } else if (s.contains('manual') ||
        s.contains('review') ||
        s == 'pending' ||
        s == 'under_review' ||
        s == 'submitted' ||
        s == 'ai_audit') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
      border = const Color(0xFFFDE68A);
      displayLabel = 'Manual Review';
    } else if (s.contains('renew') || s == 'renewal') {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
      border = const Color(0xFFFDBA74);
      displayLabel = 'Renewal';
    } else if (s.contains('changes') || s == 'changes required') {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
      border = const Color(0xFFFDBA74);
      displayLabel = 'Changes Required';
    } else if (s == 'expired' || s == 'rejected' || s == 'cancelled') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      border = const Color(0xFFFCA5A5);
      displayLabel = s == 'expired' ? 'Expired' : 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        displayLabel,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildCurrentApplicationCard(
      BuildContext context, CertificateApplicationItem app) {
    final isRenewInProgress = app.isRenewInProgress;
    final isExpired = app.isExpiredOrRenewable && !isRenewInProgress;
    final isChangesRequired = app.status.toLowerCase() == 'changes required' ||
        app.status.toLowerCase() == 'changes_required' ||
        app.displayReviewStatus.toLowerCase().contains('changes');
    final hasCert = app.certificateId.isNotEmpty && app.certificateId != 'null';
    final isApproved = (app.isApproved || isRenewInProgress) && hasCert;

    void openCert() {
      if (isRenewInProgress && hasCert) {
        // For renew in progress with an existing certificate, show CertificateViewScreen!
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificateViewScreen(certificate: app),
          ),
        );
      } else if (isExpired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RenewalWizardScreen(certificate: app),
          ),
        );
      } else if (isApproved) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificateViewScreen(certificate: app),
          ),
        );
      } else if (isChangesRequired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificationWizardScreen(
              applicationId: app.id.isNotEmpty ? app.id : app.applicationNo,
              initialModel:
                  CertificationApplicationModel.prefilledForCertificate(app),
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificationDetailsScreen(
              applicationId: app.id.isNotEmpty ? app.id : app.applicationNo,
              certificateItem: app,
            ),
          ),
        );
      }
    }

    void openDetailsRedirect() {
      if (isExpired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpiredCertificateDetailsScreen(certificate: app),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificationDetailsScreen(
              applicationId: app.id.isNotEmpty ? app.id : app.applicationNo,
              certificateItem: app,
            ),
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: openCert,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🏅', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              app.institutionName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildCertBadge(app.displayReviewStatus),
                        ],
                      ),
                      Text(
                        app.institutionType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isApproved
                            ? 'Certificate No: ${app.certificateId}'
                            : 'Application No: ${app.applicationNo.isNotEmpty ? app.applicationNo : app.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      if (app.issuedDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Issued: ${DateTimeUtils.formatDateTime(app.issuedDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      if (app.expiresDate.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Expires: ${DateTimeUtils.formatDateTime(app.expiresDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (hasCert && (isApproved || isRenewInProgress))
                                    ? 'View Certificate'
                                    : isExpired
                                        ? 'Renew Certificate'
                                        : isChangesRequired
                                            ? 'Edit Application'
                                            : 'View Details',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isChangesRequired
                                      ? const Color(0xFFDC2626)
                                      : (isExpired && !isRenewInProgress)
                                          ? const Color(0xFFEA580C)
                                          : AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: isChangesRequired
                                    ? const Color(0xFFDC2626)
                                    : (isExpired && !isRenewInProgress)
                                        ? const Color(0xFFEA580C)
                                        : AppColors.primaryBlue,
                              ),
                            ],
                          ),
                          if (!isRenewInProgress && ((isExpired && !isRenewInProgress) || isChangesRequired || isApproved))
                            InkWell(
                              onTap: openDetailsRedirect,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Text(
                                  isExpired ? 'View Details' : 'Auditor Notes',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyApplicationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Applications Yet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap "Apply for Certification" above to submit your institution.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
