import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/application_item_model.dart';
import '../../../models/certification_model.dart';
import '../../../services/api_client.dart';
import '../../../services/certification_service.dart';
import '../../certification/certification_wizard_screen.dart';
import '../../certification/widgets/yes_no_selector.dart';
import 'renewal_submitted_screen.dart';

class RenewalWizardScreen extends StatefulWidget {
  final CertificateApplicationItem certificate;

  const RenewalWizardScreen({
    super.key,
    required this.certificate,
  });

  @override
  State<RenewalWizardScreen> createState() => _RenewalWizardScreenState();
}

class _RenewalWizardScreenState extends State<RenewalWizardScreen> {
  int _currentStep = 1; // 1: Institution, 2: Questionnaire, 3: Evidence, 4: Review
  bool _isLoading = true;
  bool _isSubmitting = false;
  late CertificationApplicationModel _model;
  final List<Map<String, dynamic>> _uploadedEvidence = [];

  @override
  void initState() {
    super.initState();
    _model = CertificationApplicationModel.prefilledForCertificate(widget.certificate);
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    final targetId = widget.certificate.id.isNotEmpty
        ? widget.certificate.id
        : widget.certificate.applicationNo;

    if (targetId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final fullModel = await CertificationService.getApplicationModelForEdit(targetId);

      // If categoryConfig is null or sections empty, resolve categoryConfig by category name or id
      if (fullModel.categoryConfig == null || fullModel.categoryConfig!.sections.isEmpty) {
        try {
          final cats = await CertificationService.getCategories();
          final typeName = widget.certificate.institutionType.trim().toLowerCase();
          final modelTypeName = fullModel.institutionTypeTitle.trim().toLowerCase();

          final match = cats.firstWhere(
            (c) =>
                c.name.trim().toLowerCase() == typeName ||
                c.name.trim().toLowerCase() == modelTypeName,
            orElse: () => cats.first,
          );

          final config = await CertificationService.getCategoryConfig(match.id);
          fullModel.categoryConfig = config;
          fullModel.categoryId = config.category.id;
          fullModel.categoryMaxScore = config.category.maxScore;
          fullModel.passScore = config.category.passScore;
          fullModel.institutionTypeTitle = config.category.name;

          if (config.evidenceRequirements.isNotEmpty) {
            final existingEvidence = List<EvidenceItem>.from(fullModel.evidenceItems);
            fullModel.evidenceItems = config.evidenceRequirements.map((req) {
              final m = existingEvidence.firstWhere(
                (e) =>
                    e.requirementId == req.id.toString() ||
                    e.id == req.id.toString() ||
                    e.title.trim().toLowerCase() == req.title.trim().toLowerCase(),
                orElse: () => EvidenceItem.fromRequirement(req),
              );
              return m.copyWithRequirement(req);
            }).toList();
          }
        } catch (e) {
          debugPrint('Notice resolving category config for renewal: $e');
        }
      }

      // Ensure institution name and type fallback to widget.certificate if model is sparse
      if (fullModel.institutionName.isEmpty && widget.certificate.institutionName.isNotEmpty) {
        fullModel.institutionName = widget.certificate.institutionName;
      }
      if (fullModel.institutionTypeTitle.isEmpty && widget.certificate.institutionType.isNotEmpty) {
        fullModel.institutionTypeTitle = widget.certificate.institutionType;
      }

      // Also parse materials / evidence if available
      try {
        final rawData = await CertificationService.getApplicationRawMap(targetId);
        final rawMaterials = rawData['materials'] ??
            rawData['evidence'] ??
            rawData['supporting_material'] ??
            (rawData['application'] is Map ? (rawData['application'] as Map)['materials'] : null);

        _uploadedEvidence.clear();
        if (rawMaterials is List && rawMaterials.isNotEmpty) {
          for (final m in rawMaterials) {
            if (m is Map) {
              final name = m['name']?.toString() ?? m['file_name']?.toString();
              final title = m['title']?.toString() ?? name ?? 'Evidence File';
              if (name != null && name.isNotEmpty) {
                _uploadedEvidence.add({
                  'title': title,
                  'fileName': name,
                  'url': m['url']?.toString(),
                  'size': 'Uploaded on record',
                  'gpsTagged': m['latitude'] != null || m['requires_gps'] == true,
                });
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Notice reading raw materials: $e');
      }

      if (!mounted) return;
      setState(() {
        _model = fullModel;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading renewal data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Submits the renewal request using the dedicated renewal API:
  /// POST /api/certification/certificates/:id/renew
  /// Option A: isQuick = true -> { "submit": true, "declaration_accepted": true }
  /// Option B: isQuick = false -> { "submit": true, "declaration_accepted": true, "institution_name": ..., "details": ..., "answers": [...] }
  Future<void> _submitRenewal({required bool isQuick}) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    // Show loading modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryBlue),
                const SizedBox(height: 18),
                Text(
                  isQuick
                      ? 'Submitting Instant Renewal...'
                      : 'Submitting Renewal Application...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Validating eligibility & queuing IDF AI audit',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final certId = widget.certificate.effectiveCertificateId;
      final altId = widget.certificate.certificateId != certId
          ? widget.certificate.certificateId
          : widget.certificate.id;

      final response = await CertificationService.renewCertificate(
        certificateId: certId,
        alternativeCertificateId: altId,
        isQuickRenewal: isQuick,
        submit: true,
        declarationAccepted: true,
        model: isQuick ? null : _model,
      );

      final newAppNo = CertificationService.extractRenewalApplicationNo(
        response,
        fallback: _model.applicationNo ??
            'RNW-${widget.certificate.certificateId.isNotEmpty ? widget.certificate.certificateId : widget.certificate.id}',
      );

      String displayStatus = 'Manual Review';
      if (response['data'] is Map && (response['data'] as Map)['application'] is Map) {
        displayStatus = ((response['data'] as Map)['application']['display_status'] ?? 'Manual Review').toString();
      } else if (response['application'] is Map) {
        displayStatus = (response['application']['display_status'] ?? 'Manual Review').toString();
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RenewalSubmittedScreen(
              institutionName: _model.institutionName.isNotEmpty
                  ? _model.institutionName
                  : widget.certificate.institutionName,
              applicationNumber: newAppNo,
              status: CertificateApplicationItem.formatReviewStatus(displayStatus),
              originalCertificateNo: widget.certificate.certificateId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // dismiss loading dialog
        setState(() => _isSubmitting = false);

        String errorMsg = e.toString();
        if (e is ApiException) {
          errorMsg = e.displayMessage;
        }

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Renewal Submission Error',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              errorMsg.replaceAll('Exception: ', ''),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF475569),
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Dismiss',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  /*
  /// Option A: Quick Instant Renewal Confirmation
  void _showQuickInstantRenewalDialog() {
    bool declarationChecked = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final instName = _model.institutionName.isNotEmpty
                ? _model.institutionName
                : widget.certificate.institutionName;
            final certNo = widget.certificate.certificateId.isNotEmpty
                ? widget.certificate.certificateId
                : widget.certificate.id;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Instant Renewal',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Option A · No Form Changes',
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Institution', instName),
                          const SizedBox(height: 6),
                          _buildDetailRow('Certificate No', certNo),
                          const SizedBox(height: 6),
                          _buildDetailRow('Renewal Mode', 'Duplicate Previous Verified Record'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => setSheetState(() => declarationChecked = !declarationChecked),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: declarationChecked,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (val) => setSheetState(() => declarationChecked = val ?? true),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'I accept the IDF declaration and confirm that all previous institution details, facilities, and questionnaire answers remain accurate and unchanged.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF475569),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: !declarationChecked
                            ? null
                            : () {
                                Navigator.pop(ctx);
                                _submitRenewal(isQuick: true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Confirm & Submit Renewal',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  */

  /// Option B: Submit Confirmation after Reviewing / Updating
  void _showSubmitConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Submit Renewal Application?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review your updated application before submitting. Once submitted, it will be queued for IDF accreditation AI audit and committee review.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _submitRenewal(isQuick: false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Submit Renewal',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// In-place quick edit sheet for Contact & Institution details (Option B updates)
  void _showEditContactDetailsSheet() {
    final nameCtrl = TextEditingController(text: _model.institutionName);
    final contactCtrl = TextEditingController(text: _model.contactPerson);
    final emailCtrl = TextEditingController(text: _model.contactEmail);
    final phoneCtrl = TextEditingController(text: _model.contactPhone);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Institution & Contact',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Institution Name',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Contact Person',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: contactCtrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Contact Email',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Contact Phone',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (nameCtrl.text.trim().isNotEmpty) _model.institutionName = nameCtrl.text.trim();
                        _model.contactPerson = contactCtrl.text.trim();
                        _model.contactEmail = emailCtrl.text.trim();
                        _model.contactPhone = phoneCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text('Save Changes', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with 4-segment progress bar
            _buildTopHeader(),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                      child: _buildCurrentStepContent(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Institution();
      case 2:
        return _buildStep2Questionnaire();
      case 3:
        return _buildStep3Evidence();
      case 4:
        return _buildStep4Review();
      default:
        return _buildStep1Institution();
    }
  }

  Widget _buildTopHeader() {
    String stepTitle = 'Institution';
    if (_currentStep == 2) stepTitle = 'Questionnaire';
    if (_currentStep == 3) stepTitle = 'Evidence';
    if (_currentStep == 4) stepTitle = 'Review';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (_currentStep > 1) {
                    setState(() => _currentStep--);
                  } else {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RENEWAL · STEP $_currentStep OF 4',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    stepTitle,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 4-segment bar
          Row(
            children: List.generate(4, (index) {
              final isCompleted = (index + 1) <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Step 1: Pre-populated Institution Details
  Widget _buildStep1Institution() {
    final instName = _model.institutionName.isNotEmpty
        ? _model.institutionName
        : widget.certificate.institutionName;
    final catName = _model.institutionTypeTitle.isNotEmpty
        ? _model.institutionTypeTitle
        : widget.certificate.institutionType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Option A: Quick Instant Renewal Card (Commented out)
        /*
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF93C5FD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Option A: Quick Instant Renewal',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'No changes to institution details or questionnaire? Renew instantly with 1-tap confirmation.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF334155),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _showQuickInstantRenewalDialog,
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: Text(
                    'Renew Instantly (No Changes)',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section Divider
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'OR UPDATE INFORMATION (OPTION B)',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
        const SizedBox(height: 18),
        */

        Container(
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
                  Text(
                    'Institution Details',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _showEditContactDetailsSheet,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            'Edit Info',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CertificationWizardScreen(
                                applicationId: widget.certificate.id.isNotEmpty
                                    ? widget.certificate.id
                                    : widget.certificate.applicationNo,
                                initialModel: _model,
                              ),
                            ),
                          ).then((_) => _loadRealData());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            'Full Wizard',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDetailRow('Institution Name', instName),
              if (catName.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Category', catName),
              ],
              if (widget.certificate.certificateId.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Previous Cert ID', widget.certificate.certificateId),
              ],
              if (_model.contactPerson.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Primary Contact', _model.contactPerson),
              ],
              if (_model.contactEmail.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Contact Email', _model.contactEmail),
              ],
              if (_model.contactPhone.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Contact Phone', _model.contactPhone),
              ],
              if (_model.address.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Address', _model.address),
              ],
              if (_model.city.isNotEmpty || _model.country.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Location',
                  [_model.city, _model.country].where((s) => s.isNotEmpty).join(', '),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Info Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your previously submitted information has been pre-populated. Review and update as needed for the 2026-2028 certification period.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF1D4ED8),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // Step 2: Questionnaire (Prefilled with real questions same as submit flow)
  Widget _buildStep2Questionnaire() {
    final sections = _model.categoryConfig?.sections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pre-filled notice banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pre-filled from previous audit. Toggle answers if any campus policies or facilities have changed.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF15803D),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Questions organized by section exact as submit flow
        if (sections != null && sections.isNotEmpty)
          ...sections.map((section) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Text(section.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          section.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Text(
                        '${section.questions.length} questions',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (section.questions.isNotEmpty)
                  ...section.questions.map((q) {
                    final val = _model.getQuestionBool(q.id);
                    return YesNoSelector(
                      question: q.text,
                      value: val,
                      onChanged: (newVal) {
                        setState(() {
                          _model.setQuestionAnswer(q.id, newVal);
                        });
                      },
                    );
                  })
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No questions available in this section.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                'No questionnaire questions recorded for this category.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 3),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Save as Draft Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress saved as draft.')),
              );
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Save as Draft',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // Step 3: Evidence Materials
  Widget _buildStep3Evidence() {
    final evidenceItems = _model.evidenceItems.isNotEmpty
        ? _model.evidenceItems
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GPS notice banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📸', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Timestamped & GPS-tagged photos are verified for physical amenities. You can keep existing verified photos or replace them with recent ones.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF1D4ED8),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Evidence list
        if (evidenceItems != null && evidenceItems.isNotEmpty)
          ...evidenceItems.map((evidence) {
            final hasFile = evidence.fileName != null && evidence.fileName!.isNotEmpty;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          evidence.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (hasFile)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'On File',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (hasFile) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attachment_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evidence.fileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (evidence.requiresGps) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text(
                          'GPS Location metadata required / attached',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Replace photo for ${evidence.title}')),
                        );
                      },
                      child: Text(
                        hasFile ? 'Replace Photo / File' : 'Upload Photo / File',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          })
        else if (_uploadedEvidence.isNotEmpty)
          ..._uploadedEvidence.map((evidence) {
            final gpsTagged = evidence['gpsTagged'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          evidence['title'] ?? 'Evidence File',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'On File',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attachment_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          evidence['fileName'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (gpsTagged) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text(
                          'GPS Location metadata attached',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          })
        else
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Text(
                'No prior evidence files recorded on file.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => setState(() => _currentStep = 4),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Save as Draft Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress saved as draft.')),
              );
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Save as Draft',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // Step 4: Review Application (Exact submit flow style without documents)
  Widget _buildStep4Review() {
    final sections = _model.categoryConfig?.sections;
    final instName = _model.institutionName.isNotEmpty
        ? _model.institutionName
        : widget.certificate.institutionName;
    final catName = _model.institutionTypeTitle.isNotEmpty
        ? _model.institutionTypeTitle
        : widget.certificate.institutionType;

    // Calculate answered questions count
    int totalQuestions = 0;
    int answeredCount = 0;
    if (sections != null) {
      for (final s in sections) {
        totalQuestions += s.questions.length;
        for (final q in s.questions) {
          if (_model.getQuestionBool(q.id) != null) {
            answeredCount++;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review your renewal application before submitting.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),

        // 1. Completion Status Card (Exact submit flow Step 8 style)
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completion Status',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusRow(
                'Institution Details',
                isDone: true,
                onEdit: () => setState(() => _currentStep = 1),
              ),
              if (sections != null && sections.isNotEmpty)
                ...sections.map((sect) {
                  return _buildStatusRow(
                    sect.name,
                    isDone: true,
                    onEdit: () => setState(() => _currentStep = 2),
                  );
                })
              else
                _buildStatusRow(
                  'Certification Questionnaire',
                  isDone: true,
                  onEdit: () => setState(() => _currentStep = 2),
                ),
              _buildStatusRow(
                'Evidence',
                isDone: true,
                onEdit: () => setState(() => _currentStep = 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Institution Details Card
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Institution Details',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentStep = 1),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailItem('Institution', instName),
              const SizedBox(height: 6),
              _buildDetailItem('Category', catName),
              if (_model.categoryMaxScore > 0) ...[
                const SizedBox(height: 6),
                _buildDetailItem('Max Score', '${_model.categoryMaxScore} points'),
              ],
              if (widget.certificate.certificateId.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildDetailItem('Previous Cert ID', widget.certificate.certificateId),
              ],
              if (_model.contactPerson.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildDetailItem('Primary Contact', _model.contactPerson),
              ],
              if (_model.city.isNotEmpty || _model.country.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildDetailItem(
                  'Location',
                  [_model.city, _model.country].where((s) => s.isNotEmpty).join(', '),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Questionnaire Responses Breakdown Card (exact review format)
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Questionnaire Responses',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentStep = 2),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              if (totalQuestions > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '$answeredCount of $totalQuestions criteria answered',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (sections != null && sections.isNotEmpty)
                ...sections.map((sect) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 6),
                        child: Text(
                          '${sect.emoji} ${sect.name}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                      ...sect.questions.map((q) {
                        final val = _model.getQuestionBool(q.id);
                        final String answerLabel = val == true ? 'Yes' : (val == false ? 'No' : '—');
                        final Color badgeBg = val == true
                            ? const Color(0xFFDCFCE7)
                            : (val == false ? const Color(0xFFF1F5F9) : const Color(0xFFFEF3C7));
                        final Color badgeFg = val == true
                            ? const Color(0xFF16A34A)
                            : (val == false ? const Color(0xFF475569) : const Color(0xFFD97706));

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  q.text,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF475569),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  answerLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: badgeFg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    ],
                  );
                })
              else
                Text(
                  'No questionnaire items available.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 4. Evidence Summary Card
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Evidence Files',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _currentStep = 3),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_model.evidenceItems.isNotEmpty)
                ..._model.evidenceItems.map((ev) {
                  final hasFile = ev.fileName != null && ev.fileName!.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(
                      children: [
                        Icon(
                          hasFile ? Icons.check_circle_rounded : Icons.pending_outlined,
                          size: 15,
                          color: hasFile ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ev.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (hasFile)
                          Text(
                            ev.fileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  );
                })
              else if (_uploadedEvidence.isNotEmpty)
                ..._uploadedEvidence.map((ev) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF16A34A)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ev['title'] ?? 'Evidence File',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          ev['fileName'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                Text(
                  'No evidence files attached.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Notice Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ℹ️', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Please review your renewal submission before submitting. Once submitted, it will be transferred directly to IDF review.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF1D4ED8),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _showSubmitConfirmationSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Submit Renewal Application',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Save as Draft Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Renewal application saved as draft.')),
              );
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Save as Draft',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatusRow(
    String title, {
    required bool isDone,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 19,
            color: Color(0xFF16A34A),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
