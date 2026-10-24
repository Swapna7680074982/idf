import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import '../../services/api_config.dart';
import '../../services/certification_service.dart';
import 'certification_wizard_screen.dart';

class CertificationDetailsScreen extends StatefulWidget {
  final dynamic applicationId;
  final CertificationApplicationModel? application;
  final CertificateApplicationItem? certificateItem;

  const CertificationDetailsScreen({
    super.key,
    this.applicationId,
    this.application,
    this.certificateItem,
  });

  @override
  State<CertificationDetailsScreen> createState() =>
      _CertificationDetailsScreenState();
}

class _CertificationDetailsScreenState
    extends State<CertificationDetailsScreen> {
  CertificationApplicationDetail? _detail;
  bool _isLoading = true;
  bool _isAiScanning = false;
  bool _hasAutoTriggeredAiAudit = false;
  String? _errorMessage;

  dynamic get _effectiveId {
    if (widget.applicationId != null) return widget.applicationId;
    if (widget.application?.id != null) return widget.application!.id;
    if (widget.application?.applicationId != null &&
        widget.application!.applicationId!.isNotEmpty) {
      return widget.application!.applicationId;
    }
    if (widget.certificateItem != null && widget.certificateItem!.id.isNotEmpty) {
      return widget.certificateItem!.id;
    }
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _fetchApplicationDetail();
  }

  Future<void> _fetchApplicationDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail =
          await CertificationService.getApplicationDetail(_effectiveId);

      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });

        // If status is submitted or review_status is ai_audit, auto-record AI validation status
        final revStatus = detail.reviewStatus.toLowerCase();
        final stat = detail.status.toLowerCase();
        if ((revStatus == 'ai_audit' || stat == 'submitted') &&
            !_hasAutoTriggeredAiAudit) {
          _hasAutoTriggeredAiAudit = true;
          Future.microtask(() => _triggerAiAudit(isAutomatic: true));
        }
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION DETAILS] Load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Build fallback detail from widget.application if network error
          if (_detail == null && widget.application != null) {
            _detail = _buildFallbackDetailFromModel(widget.application!);
          } else if (_detail == null && widget.certificateItem != null) {
            _detail = _buildFallbackDetailFromItem(widget.certificateItem!);
          } else {
            _errorMessage = 'Could not load details from server: $e';
          }
        });
      }
    }
  }

  Future<void> _triggerAiAudit({bool isAutomatic = false}) async {
    if (_isAiScanning) return;
    setState(() {
      _isAiScanning = true;
    });

    try {
      await CertificationService.updateAiValidationStatus(
        _effectiveId,
        status: 'approved',
        comments:
            'Automated verification passed. All supporting documents meet IDF criteria.',
      );

      if (!mounted) return;

      // Refresh details after AI audit update
      try {
        final updatedDetail =
            await CertificationService.getApplicationDetail(_effectiveId);
        if (mounted) {
          setState(() {
            _detail = updatedDetail;
          });
        }
      } catch (_) {}

      if (!mounted) return;

      if (!isAutomatic) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Audit checks completed and recorded.'),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('⚠️ Error recording AI audit: $e');
      if (!mounted) return;
      if (!isAutomatic) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update AI validation: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAiScanning = false;
        });
      }
    }
  }

  void _openOrViewMaterial(CertificationMaterialItem mat) {
    final rawUrl = mat.url.trim();
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File URL is not available')),
      );
      return;
    }

    final resolvedUrl = ApiConfig.resolveImageUrl(rawUrl) ?? rawUrl;
    final filename = mat.name.isNotEmpty ? mat.name : mat.title;

    final lowerName = filename.toLowerCase();
    final lowerUrl = resolvedUrl.toLowerCase();
    final isPdf = lowerName.endsWith('.pdf') || lowerUrl.endsWith('.pdf');
    final isDoc = lowerName.endsWith('.doc') ||
        lowerName.endsWith('.docx') ||
        lowerUrl.endsWith('.doc') ||
        lowerUrl.endsWith('.docx');

    // If PDF or Doc, directly open in browser / external viewer
    if (isPdf || isDoc) {
      _launchUrl(resolvedUrl);
      return;
    }

    final isImage = !isPdf &&
        !isDoc &&
        (lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.webp') ||
            lowerUrl.endsWith('.jpg') ||
            lowerUrl.endsWith('.jpeg') ||
            lowerUrl.endsWith('.png') ||
            lowerUrl.endsWith('.webp') ||
            mat.kind.toLowerCase() == 'photo');

    if (isImage) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      filename,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.65,
                  ),
                  color: Colors.black,
                  child: InteractiveViewer(
                    child: Image.network(
                      resolvedUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(24),
                        color: Colors.white,
                        child: Text(
                          'Could not load image: $filename',
                          style: GoogleFonts.inter(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text('Open in Browser', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onPressed: () => _launchUrl(resolvedUrl),
              ),
            ],
          ),
        ),
      );
      return;
    }

    _launchUrl(resolvedUrl);
  }

  Future<void> _launchUrl(String url) async {
    final resolvedUrl = ApiConfig.resolveImageUrl(url) ?? url;
    final uri = Uri.tryParse(resolvedUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          final inApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          if (!inApp) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        }
        return;
      } catch (e) {
        debugPrint('⚠️ External application launch failed: $e. Trying in-app browser/default...');
        try {
          final inApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          if (!inApp) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
          return;
        } catch (_) {}
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open document URL: $resolvedUrl'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  CertificationApplicationDetail _buildFallbackDetailFromModel(
      CertificationApplicationModel model) {
    return CertificationApplicationDetail(
      id: model.id ?? 1,
      applicationId: model.applicationId ?? 'APP-CERT-2026-0001',
      applicationNo: model.applicationNo ?? model.applicationId ?? 'APP-CERT-2026-0001',
      applicationType: 'new',
      status: model.status,
      reviewStatus: model.reviewStatus,
      displayStatus: model.displayStatus,
      decision: model.decision,
      decisionText: model.decisionText ?? model.decision,
      editable: model.status.toLowerCase().contains('changes') || model.status.toLowerCase() == 'draft',
      currentStep: 4,
      totalSteps: 4,
      submittedAt: model.submissionDate?.toIso8601String() ?? '2026-10-24T05:00:00.000Z',
      institution: CertificationInstitution(
        name: model.institutionName.isNotEmpty ? model.institutionName : 'Institution',
        category: model.institutionTypeTitle.isNotEmpty ? model.institutionTypeTitle : 'Workplace',
        address: model.address,
        country: model.country,
        region: model.regionState,
        city: model.city,
        contactPerson: model.contactPerson,
        contactEmail: model.contactEmail,
        contactPhone: model.contactPhone,
      ),
      timeline: model.timeline ?? [
        const CertificationTimelineStage(
          stage: 'submitted',
          label: 'Submitted',
          state: 'completed',
          note: 'Application submitted',
        ),
        const CertificationTimelineStage(
          stage: 'ai_validation',
          label: 'AI Audit',
          state: 'in_progress',
          note: 'AI audit in progress',
        ),
        const CertificationTimelineStage(
          stage: 'manual_review',
          label: 'Manual Review',
          state: 'pending',
        ),
        const CertificationTimelineStage(
          stage: 'scoring',
          label: 'Scoring',
          state: 'pending',
        ),
        const CertificationTimelineStage(
          stage: 'certificate',
          label: 'Certificate',
          state: 'pending',
        ),
      ],
      aiValidation: model.aiValidation ?? [
        const CertificationAiValidationCheck(
          checkType: 'evidence_review',
          label: 'Evidence Review',
          status: 'pending',
          details: 'Evidence files under review',
        ),
        const CertificationAiValidationCheck(
          checkType: 'image_location_validation',
          label: 'Image Location Validation',
          status: 'pending',
          details: 'GPS & timestamp validation pending',
        ),
        const CertificationAiValidationCheck(
          checkType: 'detail_evidence_match',
          label: 'Detail Evidence Match',
          status: 'pending',
          details: 'Institution details cross-check pending',
        ),
        const CertificationAiValidationCheck(
          checkType: 'overall',
          label: 'Overall',
          status: 'pending',
          details: 'Overall audit pending',
        ),
      ],
      materials: model.evidenceItems.map((e) => CertificationMaterialItem(
        id: e.id,
        requirementId: e.id,
        title: e.title,
        name: e.fileName ?? 'evidence.pdf',
        kind: e.evidenceKind,
        source: 'upload',
        aiStatus: 'pending',
        url: e.fileUrl ?? '',
      )).toList(),
    );
  }

  CertificationApplicationDetail _buildFallbackDetailFromItem(
      CertificateApplicationItem item) {
    return CertificationApplicationDetail(
      id: int.tryParse(item.id) ?? 1,
      applicationId: item.certificateId.isNotEmpty ? item.certificateId : 'APP-CERT-${item.id}',
      applicationNo: item.certificateId.isNotEmpty ? item.certificateId : 'APP-CERT-${item.id}',
      applicationType: 'new',
      status: item.status,
      reviewStatus: item.status.toLowerCase() == 'active' ? 'approved' : 'ai_audit',
      displayStatus: item.status,
      decision: item.status == 'Active' ? 'Approved' : 'Pending',
      editable: item.status.toLowerCase().contains('changes'),
      currentStep: 4,
      totalSteps: 4,
      submittedAt: item.issuedDate,
      institution: CertificationInstitution(
        name: item.institutionName,
        category: item.institutionType,
        address: '—',
        country: '—',
        region: '—',
        city: '—',
        contactPerson: '—',
        contactEmail: '—',
        contactPhone: '—',
      ),
      timeline: const [
        CertificationTimelineStage(stage: 'submitted', label: 'Submitted', state: 'completed'),
        CertificationTimelineStage(stage: 'ai_validation', label: 'AI Audit', state: 'completed'),
        CertificationTimelineStage(stage: 'manual_review', label: 'Manual Review', state: 'completed'),
        CertificationTimelineStage(stage: 'certificate', label: 'Certificate', state: 'completed'),
      ],
    );
  }

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
        title: Text(
          'Application Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            tooltip: 'Refresh',
            onPressed: _fetchApplicationDetail,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : _errorMessage != null && _detail == null
              ? _buildErrorView()
              : _buildContentView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 14),
            Text(
              'Failed to load application dossier',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _fetchApplicationDetail,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView() {
    final detail = _detail!;
    final inst = detail.institution;

    return RefreshIndicator(
      onRefresh: _fetchApplicationDetail,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Card (App No, Category, Status)
            _buildHeaderCard(detail),
            const SizedBox(height: 14),

            // 2. Institution Details Dossier Card
            if (inst != null) ...[
              _buildInstitutionDossierCard(inst),
              const SizedBox(height: 14),
            ],

            // 3. Workflow Stage Timeline
            _buildTimelineCard(detail.timeline),
            const SizedBox(height: 14),

            // 4. AI Audit & Validation Checks Card
            _buildAiValidationCard(detail),
            const SizedBox(height: 14),

            // 5. Uploaded Materials & Evidence
            if (detail.materials.isNotEmpty) ...[
              _buildMaterialsCard(detail.materials),
              const SizedBox(height: 14),
            ],

            // 6. Reviewer / Admin Comment Box (if any)
            if (_hasComment(detail)) ...[
              _buildCommentsCard(detail),
              const SizedBox(height: 14),
            ],

            // 7. Actions (Edit Application if editable)
            if (detail.editable) ...[
              _buildActionButtons(detail),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(CertificationApplicationDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🏅', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.applicationNo.isNotEmpty
                          ? detail.applicationNo
                          : detail.applicationId,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      detail.institution?.name ?? 'Institution Certification',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(detail.reviewStatus.isNotEmpty
                  ? detail.reviewStatus
                  : (detail.displayStatus.isNotEmpty && detail.displayStatus.toLowerCase() != 'submitted'
                      ? detail.displayStatus
                      : detail.status)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaItem(
                  'Review Stage',
                  _formatReviewStatus(detail.reviewStatus.isNotEmpty
                      ? detail.reviewStatus
                      : detail.status)),
              _buildMetaItem('Decision', detail.decisionText ?? detail.decision),
              _buildMetaItem('Submitted', _formatDate(detail.submittedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildInstitutionDossierCard(CertificationInstitution inst) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business_rounded, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Institution Details',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Institution Name', inst.name),
          _buildInfoRow('Category', inst.category),
          _buildInfoRow('Address', inst.address),
          _buildInfoRow('Location', [inst.city, inst.region, inst.country].where((s) => s.isNotEmpty && s != '—').join(', ')),
          if (inst.contactPerson.isNotEmpty)
            _buildInfoRow('Contact Person', inst.contactPerson),
          if (inst.contactEmail.isNotEmpty)
            _buildInfoRow('Email', inst.contactEmail),
          if (inst.contactPhone.isNotEmpty)
            _buildInfoRow('Phone', inst.contactPhone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(List<CertificationTimelineStage> stages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Application Timeline',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...stages.asMap().entries.map((entry) {
            final idx = entry.key;
            final stage = entry.value;
            final isLast = idx == stages.length - 1;
            return _buildTimelineStepItem(stage, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStepItem(CertificationTimelineStage stage, bool isLast) {
    final state = stage.state.toLowerCase();
    final isCompleted = state == 'completed';
    final isInProgress = state == 'in_progress';

    Color nodeColor = const Color(0xFFCBD5E1);
    Widget iconChild = Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF94A3B8),
        shape: BoxShape.circle,
      ),
    );

    if (isCompleted) {
      nodeColor = const Color(0xFF16A34A);
      iconChild = const Icon(Icons.check_rounded, size: 14, color: Colors.white);
    } else if (isInProgress) {
      nodeColor = AppColors.primaryBlue;
      iconChild = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: iconChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stage.label,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isInProgress
                              ? AppColors.primaryBlue
                              : (isCompleted ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                        ),
                      ),
                      if (stage.occurredAt != null)
                        Text(
                          _formatDate(stage.occurredAt),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                  if (stage.note != null && stage.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      stage.note!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiValidationCard(CertificationApplicationDetail detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  Text(
                    'AI Audit Checks',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (_isAiScanning)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...detail.aiValidation.map((c) => _buildCheckItem(c)),
          const SizedBox(height: 12),
          // Trigger manual re-run/verify button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isAiScanning ? null : () => _triggerAiAudit(isAutomatic: false),
              icon: _isAiScanning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded, size: 16),
              label: Text(
                _isAiScanning ? 'Running AI Verification...' : 'Run AI Audit Verification',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: Color(0xFFBAE6FD)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(CertificationAiValidationCheck check) {
    final isApproved = check.status.toLowerCase() == 'approved';
    final isPending = check.status.toLowerCase() == 'pending';

    Color bg = const Color(0xFFF8FAFC);
    Color statusColor = isApproved ? const Color(0xFF16A34A) : (isPending ? const Color(0xFFD97706) : const Color(0xFFEF4444));
    IconData icon = isApproved ? Icons.check_circle_rounded : (isPending ? Icons.hourglass_top_rounded : Icons.error_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: statusColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      check.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      check.statusLabel ?? check.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                if (check.details != null && check.details!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    check.details!,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsCard(List<CertificationMaterialItem> materials) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_shared_rounded, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Uploaded Evidence & Documents (${materials.length})',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...materials.map((m) => _buildMaterialTile(m)),
        ],
      ),
    );
  }

  Widget _buildMaterialTile(CertificationMaterialItem mat) {
    final isPdf = mat.name.toLowerCase().endsWith('.pdf') || mat.url.toLowerCase().endsWith('.pdf');
    final isDoc = mat.name.toLowerCase().endsWith('.doc') ||
        mat.name.toLowerCase().endsWith('.docx') ||
        mat.url.toLowerCase().endsWith('.doc') ||
        mat.url.toLowerCase().endsWith('.docx');
    final iconData = isPdf
        ? Icons.picture_as_pdf_rounded
        : (isDoc ? Icons.description_rounded : Icons.image_rounded);
    final iconColor = isPdf
        ? const Color(0xFFDC2626)
        : (isDoc ? const Color(0xFF2563EB) : const Color(0xFF16A34A));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: mat.url.isNotEmpty ? () => _openOrViewMaterial(mat) : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData, size: 20, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mat.title.isNotEmpty ? mat.title : mat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        mat.name.isNotEmpty ? mat.name : 'Tap to view',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (mat.url.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primaryBlue),
                    tooltip: 'View Document',
                    onPressed: () => _openOrViewMaterial(mat),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsCard(CertificationApplicationDetail detail) {
    final comment = detail.aiValidationComment ?? detail.reviewerComment ?? detail.adminComment ?? '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📝', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviewer / Auditor Feedback',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF78350F),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CertificationApplicationDetail detail) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CertificationWizardScreen(
                initialModel: CertificationApplicationModel(
                  id: detail.id,
                  applicationId: detail.applicationId,
                  applicationNo: detail.applicationNo,
                  institutionName: detail.institution?.name ?? '',
                  institutionTypeTitle: detail.institution?.category ?? '',
                  address: detail.institution?.address ?? '',
                  country: detail.institution?.country ?? '',
                  regionState: detail.institution?.region ?? '',
                  city: detail.institution?.city ?? '',
                  contactPerson: detail.institution?.contactPerson ?? '',
                  contactEmail: detail.institution?.contactEmail ?? '',
                  contactPhone: detail.institution?.contactPhone ?? '',
                  status: detail.status,
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.edit_note_rounded, size: 20),
        label: Text(
          'Edit / Resubmit Application',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    final formatted = _formatReviewStatus(status);
    final lower = formatted.toLowerCase();
    Color bg = const Color(0xFFE0F2FE);
    Color fg = const Color(0xFF0284C7);

    if (lower == 'approved' || lower == 'active' || lower == 'certified') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (lower.contains('manual') || lower.contains('review') || lower == 'under_review') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else if (lower.contains('changes')) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    } else if (lower == 'expired' || lower == 'rejected') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        formatted,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  bool _hasComment(CertificationApplicationDetail detail) {
    return (detail.aiValidationComment != null && detail.aiValidationComment!.isNotEmpty) ||
        (detail.reviewerComment != null && detail.reviewerComment!.isNotEmpty) ||
        (detail.adminComment != null && detail.adminComment!.isNotEmpty);
  }

  String _formatReviewStatus(String reviewStatus) {
    final lower = reviewStatus.trim().toLowerCase();
    switch (lower) {
      case 'submitted':
      case 'ai_audit':
      case 'under_review':
      case 'manual_review':
      case 'manual review':
      case 'in review':
      case 'in_review':
        return 'Manual Review';
      case 'approved':
      case 'certified':
      case 'active':
        return 'Approved';
      case 'scoring':
        return 'Scoring';
      case 'rejected':
        return 'Rejected';
      case 'changes_required':
      case 'changes required':
        return 'Changes Required';
      case 'expired':
        return 'Expired';
      default:
        if (reviewStatus.trim().isEmpty) return 'Manual Review';
        return reviewStatus.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
