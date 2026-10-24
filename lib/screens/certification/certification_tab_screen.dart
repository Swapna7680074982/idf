import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import '../../services/certification_service.dart';
import '../applications/certificate_view_screen.dart';
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


  Widget _buildCurrentApplicationCard(
      BuildContext context, CertificateApplicationItem app) {
    final statusText = app.displayReviewStatus;
    final isApproved = app.isApproved;
    final isChangesRequired = statusText.toLowerCase().contains('changes');
    final isReview = statusText.toLowerCase().contains('review') ||
        statusText.toLowerCase().contains('audit');

    Color statusBg = const Color(0xFFE0F2FE);
    Color statusFg = const Color(0xFF0284C7);
    if (isApproved) {
      statusBg = const Color(0xFFDCFCE7);
      statusFg = const Color(0xFF16A34A);
    } else if (isReview) {
      statusBg = const Color(0xFFFEF3C7);
      statusFg = const Color(0xFFD97706);
    } else if (isChangesRequired) {
      statusBg = const Color(0xFFFEE2E2);
      statusFg = const Color(0xFFDC2626);
    }

    return InkWell(
      onTap: () {
        if (isApproved && app.hasCertificate) {
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
                initialModel: CertificationApplicationModel.prefilledForCertificate(app),
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
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isReview
                    ? const Color(0xFFFEF3C7)
                    : (isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isApproved ? '🏅' : '🏢',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.institutionName.isNotEmpty
                        ? app.institutionName
                        : 'Institution Application',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (app.institutionType.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      app.institutionType,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusFg,
                          ),
                        ),
                      ),
                      if (app.applicationNo.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            app.applicationNo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isChangesRequired
                                ? 'Edit Application'
                                : (isApproved ? 'View Certificate' : 'View Details'),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isChangesRequired
                                  ? const Color(0xFFDC2626)
                                  : AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: isChangesRequired
                                ? const Color(0xFFDC2626)
                                : AppColors.primaryBlue,
                          ),
                        ],
                      ),
                      if (isApproved || isChangesRequired)
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CertificationDetailsScreen(
                                  applicationId: app.id.isNotEmpty ? app.id : app.applicationNo,
                                  certificateItem: app,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              'Auditor Notes',
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
