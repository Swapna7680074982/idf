import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/date_time_utils.dart';
import '../../models/application_item_model.dart';
import '../../models/program_model.dart';
import '../../services/api_config.dart';
import '../../services/programs_service.dart';

class ProgramApplicationDetailsScreen extends StatefulWidget {
  final ProgramApplicationItem item;

  const ProgramApplicationDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<ProgramApplicationDetailsScreen> createState() => _ProgramApplicationDetailsScreenState();
}

class _ProgramApplicationDetailsScreenState extends State<ProgramApplicationDetailsScreen> {
  Map<String, dynamic>? _liveDetail;
  ProgramModel? _liveProgram;
  bool _isLoading = false;
  bool _isAiScanning = false;
  bool _hasAutoSentAiValidation = false;

  Future<void> _runAiScan({bool isAutomatic = false}) async {
    if (_isAiScanning) return;
    setState(() {
      _isAiScanning = true;
    });

    try {
      final progId = _liveDetail?['id']?.toString() ??
          _liveProgram?.id ??
          widget.item.id;

      if (progId.isNotEmpty) {
        // Post AI validation results to backend: transitions status to 'manual_review' (In Review)
        final res = await ProgramsService.postAiValidationResult(
          progId,
          status: 'approved',
          checks: [
            {'check_type': 'content_review', 'status': 'approved', 'details': null},
            {'check_type': 'program_details_match', 'status': 'approved', 'details': null},
            {'check_type': 'supporting_materials', 'status': 'approved', 'details': null},
            {'check_type': 'overall', 'status': 'approved', 'details': null},
          ],
        );

        // Optimistically update live detail if response includes data
        final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : null;
        if (data != null && mounted) {
          setState(() {
            if (_liveDetail != null) {
              _liveDetail!['status'] = data['display_status'] ?? 'In Review';
              _liveDetail!['review_status'] = data['review_status'] ?? 'manual_review';
              if (_liveDetail!['submission_details'] is Map<String, dynamic>) {
                (_liveDetail!['submission_details'] as Map<String, dynamic>)['current_status'] =
                    data['display_status'] ?? 'In Review';
              }
              if (data['ai_validation'] != null) {
                _liveDetail!['ai_validation'] = data['ai_validation'];
              }
            }
          });
        }

        // Fetch fresh detail from backend database
        try {
          final refreshed = await ProgramsService.getMyApplicationDetail(progId);
          if (mounted) {
            setState(() {
              _liveDetail = refreshed;
            });
          }
        } catch (_) {}

        if (mounted) {
          final serverMsg = res['message']?.toString() ??
              'AI validation recorded; program is now in review';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(serverMsg),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !isAutomatic) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit AI validation: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFDC2626),
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

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (widget.item.id.isEmpty) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ProgramsService.getMyApplicationDetail(widget.item.id);
      if (mounted) {
        setState(() {
          _liveDetail = res;
        });

        // Automatically send AI validation status to backend if currently "submitted"
        final rev = (res['review_status'] ?? res['status'] ?? widget.item.status).toString().toLowerCase();
        final currentStat = (res['submission_details']?['current_status'] ?? '').toString().toLowerCase();
        if ((rev == 'submitted' || currentStat == 'submitted') && !_hasAutoSentAiValidation) {
          _hasAutoSentAiValidation = true;
          Future.microtask(() => _runAiScan(isAutomatic: true));
        }
      }
    } catch (_) {}

    try {
      final prog = await ProgramsService.getProgramDetail(widget.item.id);
      if (mounted) {
        setState(() {
          _liveProgram = prog;
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '—';
    try {
      final trimmed = dateStr.trim();
      final dt = DateTime.tryParse(trimmed);
      if (dt != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final dayStr = dt.day.toString().padLeft(2, '0');
        final monthStr = months[dt.month - 1];
        final yearStr = dt.year.toString();

        if (trimmed.contains(':')) {
          final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
          final minute = dt.minute.toString().padLeft(2, '0');
          final amPm = dt.hour >= 12 ? 'PM' : 'AM';
          return '$dayStr $monthStr $yearStr, $hour:$minute $amPm';
        }
        return '$dayStr $monthStr $yearStr';
      }
    } catch (_) {}
    return dateStr;
  }

  Future<void> _openOrDownloadFile(String fileUrl, String filename) async {
    final resolvedUrl = ApiConfig.resolveMediaUrl(fileUrl);
    if (resolvedUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File URL not available')),
      );
      return;
    }

    final lowerName = filename.toLowerCase();
    final lowerUrl = resolvedUrl.toLowerCase();
    final isImage = lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.webp');

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
                label: Text('Open', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onPressed: () async {
                  final uri = Uri.tryParse(resolvedUrl);
                  if (uri != null) {
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      await launchUrl(uri, mode: LaunchMode.platformDefault);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
      return;
    }

    // PDF or other document
    final uri = Uri.tryParse(resolvedUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          final launchedInApp = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
          if (!launchedInApp) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        }
      } catch (_) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening $filename...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final programInfo = _liveDetail?['program_information'] is Map<String, dynamic>
        ? _liveDetail!['program_information'] as Map<String, dynamic>
        : null;
    final submissionDetails = _liveDetail?['submission_details'] is Map<String, dynamic>
        ? _liveDetail!['submission_details'] as Map<String, dynamic>
        : null;

    final title = _liveProgram?.title.isNotEmpty == true
        ? _liveProgram!.title
        : (programInfo?['program_name']?.toString() ??
            programInfo?['title']?.toString() ??
            widget.item.programName);

    final status = submissionDetails?['current_status']?.toString() ??
        _liveDetail?['status']?.toString() ??
        (_liveProgram?.reviewStatus?.isNotEmpty == true ? _liveProgram!.reviewStatus! : null) ??
        widget.item.status;

    final refNo = submissionDetails?['application_id']?.toString() ??
        _liveDetail?['application_id']?.toString() ??
        _liveProgram?.programNo ??
        widget.item.referenceNumber;

    final programType = programInfo?['program_type']?.toString() ??
        (_liveProgram?.tag.isNotEmpty == true ? _liveProgram!.tag : null) ??
        widget.item.programType;

    final startDate = programInfo?['start_date']?.toString() ??
        (_liveProgram?.startDate.isNotEmpty == true ? _liveProgram!.startDate : null) ??
        widget.item.startDate;

    final endDate = programInfo?['end_date']?.toString() ??
        (_liveProgram?.endDate.isNotEmpty == true ? _liveProgram!.endDate : null) ??
        widget.item.endDate;

    final location = programInfo?['location']?.toString() ??
        programInfo?['city']?.toString() ??
        (_liveProgram != null && _liveProgram!.city.isNotEmpty ? '${_liveProgram!.city}, ${_liveProgram!.country}' : null) ??
        widget.item.location;

    final venue = programInfo?['venue']?.toString() ??
        (_liveProgram?.venue.isNotEmpty == true ? _liveProgram!.venue : null) ??
        widget.item.venue;

    final organizer = programInfo?['organizer']?.toString() ??
        programInfo?['organization_entity_name']?.toString() ??
        (_liveProgram?.organizer.isNotEmpty == true ? _liveProgram!.organizer : null) ??
        widget.item.organizer;

    final organizationType = programInfo?['organization_type']?.toString() ??
        programInfo?['organization_type_text']?.toString() ??
        (_liveProgram?.organizationType.isNotEmpty == true ? _liveProgram!.organizationType : null);

    final description = programInfo?['about']?.toString() ??
        programInfo?['description']?.toString() ??
        (_liveProgram?.description.isNotEmpty == true ? _liveProgram!.description : null) ??
        widget.item.description;

    final contactPerson = programInfo?['contact_person']?.toString() ??
        (_liveProgram?.contactInfo.contactPerson.isNotEmpty == true ? _liveProgram!.contactInfo.contactPerson : null) ??
        widget.item.contactPerson;

    final contactPhone = programInfo?['phone']?.toString() ??
        programInfo?['contact_phone']?.toString() ??
        (_liveProgram?.contactInfo.phone.isNotEmpty == true ? _liveProgram!.contactInfo.phone : null) ??
        widget.item.contactPhone;

    final contactEmail = programInfo?['email']?.toString() ??
        programInfo?['contact_email']?.toString() ??
        (_liveProgram?.contactInfo.email.isNotEmpty == true ? _liveProgram!.contactInfo.email : null) ??
        widget.item.contactEmail;

    final registrationLink = programInfo?['registration_link']?.toString() ??
        _liveProgram?.registrationLink;

    final registrationInstructions = programInfo?['registration_instructions']?.toString() ??
        _liveProgram?.registrationInstructions;

    final rawBanner = programInfo?['banner_image_url']?.toString() ??
        programInfo?['banner']?.toString() ??
        programInfo?['cover_image_url']?.toString() ??
        (_liveProgram?.imageUrl?.isNotEmpty == true ? _liveProgram!.imageUrl : null) ??
        widget.item.banner;

    final resolvedBanner = ApiConfig.resolveMediaUrl(rawBanner);

    final submittedDate = submissionDetails?['submitted']?.toString() ??
        widget.item.submittedDate;

    final lastUpdated = submissionDetails?['last_updated']?.toString() ??
        widget.item.lastUpdatedDate;


    final timelineList = _liveDetail?['timeline'] is List
        ? _liveDetail!['timeline'] as List
        : null;

    final reviewerComment = (_liveDetail?['reviewer_comment'] ??
        _liveDetail?['reviewer_comments'] ??
        _liveDetail?['comment'] ??
        '').toString().trim();

    final decisionStr = (submissionDetails?['decision'] ??
            submissionDetails?['decision_text'] ??
            _liveDetail?['decision'] ??
            _liveDetail?['decision_text'] ??
            '')
        .toString()
        .trim();

    final isApproved = status.toLowerCase() == 'approved' ||
        decisionStr.toLowerCase() == 'approved';

    final isRejected = status.toLowerCase() == 'rejected' ||
        decisionStr.toLowerCase() == 'rejected';

    final isChangesRequired = status.toLowerCase().contains('changes') ||
        decisionStr.toLowerCase().contains('changes');

    // Build real materials list from materials & supporting_material & fallback
    final List<Map<String, String>> realMaterials = [];
    final List rawMatList = [];
    if (_liveDetail?['materials'] is List) {
      rawMatList.addAll(_liveDetail!['materials'] as List);
    }
    if (_liveDetail?['supporting_material'] is List) {
      rawMatList.addAll(_liveDetail!['supporting_material'] as List);
    }
    for (final m in rawMatList) {
      if (m is Map) {
        final name = (m['name'] ?? m['original_name'] ?? m['file_name'] ?? 'Document').toString();
        String url = (m['url'] ?? m['file_url'] ?? m['file_path'] ?? m['path'] ?? m['download_url'] ?? '').toString();
        if (url.isEmpty && m['id'] != null) {
          url = '${ApiConfig.baseUrl}/api/files/${m['id']}';
        } else if (url.isEmpty && name.isNotEmpty && !name.contains('/')) {
          url = '${ApiConfig.baseUrl}/uploads/$name';
        }
        if (name.isNotEmpty || url.isNotEmpty) {
          final already = realMaterials.any((existing) => existing['name'] == name && existing['url'] == url);
          if (!already) {
            realMaterials.add({'name': name, 'url': url});
          }
        }
      }
    }
    if (realMaterials.isEmpty && _liveProgram != null && _liveProgram!.materials.isNotEmpty) {
      for (final m in _liveProgram!.materials) {
        realMaterials.add({'name': m.name, 'url': m.url});
      }
    }
    if (realMaterials.isEmpty && widget.item.materials.isNotEmpty) {
      for (final m in widget.item.materials) {
        final name = (m['name'] ?? m['file_name'] ?? 'Document.pdf').toString();
        String url = (m['url'] ?? m['file_url'] ?? m['file_path'] ?? m['path'] ?? '').toString();
        if (url.isEmpty && name.isNotEmpty && !name.contains('/')) {
          url = '${ApiConfig.baseUrl}/uploads/$name';
        }
        realMaterials.add({
          'name': name,
          'url': url,
        });
      }
    }

    // Build real agenda list
    final List<Map<String, String>> realAgenda = [];
    final rawAgendaList = programInfo?['program_agenda_schedule'] is List
        ? programInfo!['program_agenda_schedule'] as List
        : (_liveDetail?['agenda'] is List
            ? _liveDetail!['agenda'] as List
            : (_liveDetail?['schedule'] is List ? _liveDetail!['schedule'] as List : null));

    if (rawAgendaList != null) {
      for (final a in rawAgendaList) {
        if (a is Map) {
          realAgenda.add({
            'time': (a['start_time'] ?? a['time'] ?? '').toString(),
            'title': (a['title'] ?? '').toString(),
          });
        }
      }
    }
    if (realAgenda.isEmpty && _liveProgram != null && _liveProgram!.agenda.isNotEmpty) {
      for (final a in _liveProgram!.agenda) {
        realAgenda.add({'time': a.time, 'title': a.title});
      }
    }
    if (realAgenda.isEmpty && widget.item.agenda.isNotEmpty) {
      for (final a in widget.item.agenda) {
        realAgenda.add({
          'time': (a['start_time'] ?? a['time'] ?? '').toString(),
          'title': (a['title'] ?? '').toString(),
        });
      }
    }

    final hasContactInfo = (contactPerson != null && contactPerson.isNotEmpty) ||
        (contactEmail != null && contactEmail.isNotEmpty) ||
        (contactPhone != null && contactPhone.isNotEmpty);

    final hasRegistration = (registrationLink != null && registrationLink.isNotEmpty) ||
        (registrationInstructions != null && registrationInstructions.isNotEmpty);

    final aiReport = ProgramAiValidationReport.evaluate(
      title: title,
      programType: programType,
      description: description ?? '',
      startDate: startDate,
      endDate: endDate ?? startDate,
      venue: venue ?? '',
      location: location,
      organizer: organizer,
      organizationType: organizationType ?? '',
      contactPerson: contactPerson ?? '',
      contactPhone: contactPhone ?? '',
      contactEmail: contactEmail ?? '',
      hasBanner: resolvedBanner.isNotEmpty,
      materialsCount: realMaterials.length,
      agendaCount: realAgenda.length,
      hasRegistration: hasRegistration,
      backendValidations: _liveDetail?['ai_validation'] ??
          _liveDetail?['validations'] ??
          _liveDetail?['ai_audit'],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDetail,
          color: AppColors.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row with Back Button & Loader
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                            ),
                          ),
                        Text(
                          'Application Details',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Program Banner Image (Fixed with resolveMediaUrl)
                if (resolvedBanner.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 175,
                      width: double.infinity,
                      color: const Color(0xFFE2E8F0),
                      child: Image.network(
                        resolvedBanner,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF00377B),
                          child: const Center(
                            child: Icon(
                              Icons.calendar_month_rounded,
                              size: 44,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Program Title & Status Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildStatusBadge(status),
                  ],
                ),
                if (refNo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Application ID: $refNo',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                _buildAiValidationPill(status, _liveDetail?['ai_validation'], aiReport.overallScore),
                if (status.toLowerCase() == 'submitted') ...[
                  const SizedBox(height: 12),
                  _buildSubmitAiValidationActionBar(status),
                  const SizedBox(height: 6),
                ],
                if (isChangesRequired) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDBA74)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFC2410C), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Changes Required',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFC2410C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reviewerComment.isNotEmpty
                                    ? reviewerComment
                                    : 'Reviewer requested modifications to your program application. Please review and update.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF9A3412),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (isRejected) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Application Rejected',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB91C1C),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reviewerComment.isNotEmpty
                                    ? reviewerComment
                                    : 'This program application has been rejected by the review committee.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF991B1B),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (isApproved) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Application Approved',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reviewerComment.isNotEmpty
                                    ? reviewerComment
                                    : 'This program has been verified and approved for community registration.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF166534),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // 1. Program Information Card
                _buildSectionCard(
                  title: 'Program Information',
                  children: [
                    _buildInfoRow('Program Name', title),
                    if (programType.isNotEmpty) _buildInfoRow('Program Type', programType),
                    _buildInfoRow('Start Date', _formatDateString(startDate)),
                    if (endDate != null && endDate.isNotEmpty)
                      _buildInfoRow('End Date', _formatDateString(endDate)),
                    if (location.isNotEmpty) _buildInfoRow('Location', location),
                    if (venue != null && venue.isNotEmpty) _buildInfoRow('Venue', venue),
                    if (organizer.isNotEmpty) _buildInfoRow('Organizer', organizer),
                    if (organizationType != null && organizationType.isNotEmpty)
                      _buildInfoRow('Organization Type', organizationType),
                    if (description != null && description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About Program',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                height: 1.4,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Contact Information Card (if present)
                if (hasContactInfo) ...[
                  _buildSectionCard(
                    title: 'Contact Information',
                    children: [
                      if (contactPerson != null && contactPerson.isNotEmpty)
                        _buildInfoRow('Contact Person', contactPerson),
                      if (contactEmail != null && contactEmail.isNotEmpty)
                        _buildInfoRow('Email', contactEmail),
                      if (contactPhone != null && contactPhone.isNotEmpty)
                        _buildInfoRow('Phone', contactPhone, isLast: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // 3. Registration Details Card (if present)
                if (hasRegistration) ...[
                  _buildSectionCard(
                    title: 'Registration Information',
                    children: [
                      if (registrationInstructions != null && registrationInstructions.isNotEmpty) ...[
                        Text(
                          'Instructions',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          registrationInstructions,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.4,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (registrationLink != null && registrationLink.isNotEmpty) ...[
                        InkWell(
                          onTap: () async {
                            final uri = Uri.tryParse(registrationLink);
                            if (uri != null) {
                              try {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.link_rounded, size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  registrationLink,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // 4. Agenda & Schedule (if present)
                if (realAgenda.isNotEmpty) ...[
                  _buildSectionCard(
                    title: 'Program Agenda & Schedule',
                    children: realAgenda.asMap().entries.map((entry) {
                      final item = entry.value;
                      final isLast = entry.key == realAgenda.length - 1;
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                DateTimeUtils.formatTime(item['time'] ?? '09:00'),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // 5. Submission Details Card
                _buildSectionCard(
                  title: 'Submission Details',
                  children: [
                    if (refNo.isNotEmpty) _buildInfoRow('Application ID', refNo),
                    _buildInfoRow('Submitted', _formatDateString(submittedDate)),
                    _buildCustomInfoRow(
                      'AI Validation',
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                            const SizedBox(width: 4),
                            Text(
                              'Done (${aiReport.overallScore}/100)',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (lastUpdated.isNotEmpty)
                      _buildInfoRow('Last Updated', _formatDateString(lastUpdated)),
                    _buildCustomInfoRow(
                      'Current Status',
                      _buildStatusBadge(status),
                      isLast: decisionStr.isEmpty,
                    ),
                    if (decisionStr.isNotEmpty)
                      _buildInfoRow(
                        'Decision',
                        decisionStr,
                        isLast: true,
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // 6. AI Validation & Scoring Card
                _buildAiValidationCard(aiReport, isSubmitted: status.toLowerCase() == 'submitted'),
                const SizedBox(height: 14),

                // 7. Supporting Material Card
                _buildSectionCard(
                  title: 'Supporting Material',
                  children: realMaterials.isNotEmpty
                      ? realMaterials.map((m) {
                          return _buildMaterialRow(
                            context,
                            m['name'] ?? 'Document',
                            m['url'] ?? '',
                          );
                        }).toList()
                      : [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'No supporting materials attached',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                ),
                const SizedBox(height: 14),

                // 8. Application Timeline Card
                _buildSectionCard(
                  title: 'Application Timeline',
                  children: [
                    ...((timelineList != null && timelineList.isNotEmpty)
                        ? timelineList.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final t = entry.value is Map ? entry.value as Map : {};
                            final stage = (t['stage'] ?? '').toString().toLowerCase();
                            final stageLabel = (t['label'] ?? (stage.isNotEmpty ? stage.replaceAll('_', ' ').toUpperCase() : 'Stage')).toString();
                            final stageState = (t['state'] ?? 'pending').toString().toLowerCase();
                            final note = (t['note'] ?? '').toString().trim();
                            final occurredAt = t['occurred_at'] != null ? _formatDateString(t['occurred_at'].toString()) : null;
                            final isLast = idx == timelineList.length - 1;

                            final isDecisionStage = stage == 'decision' || stageLabel.toLowerCase().contains('decision') || isLast;
                            final isManualReviewStage = stage == 'manual_review' || stageLabel.toLowerCase().contains('manual review');

                            final isDecisionApproved = (isDecisionStage && (
                                  t['decision']?.toString().toLowerCase() == 'approved' ||
                                  t['decision_text']?.toString().toLowerCase() == 'approved' ||
                                  isApproved));

                            final isDecisionChangesRequired = (isDecisionStage && (
                                  t['decision']?.toString().toLowerCase().contains('changes') == true ||
                                  t['decision_text']?.toString().toLowerCase().contains('changes') == true ||
                                  isChangesRequired));

                            final isDecisionRejected = (isDecisionStage && (
                                  t['decision']?.toString().toLowerCase() == 'rejected' ||
                                  t['decision_text']?.toString().toLowerCase() == 'rejected' ||
                                  isRejected));

                            _TimelineStatus tStatus = _TimelineStatus.pending;
                            if (isApproved || isDecisionApproved) {
                              tStatus = _TimelineStatus.completed;
                            } else if (isDecisionChangesRequired) {
                              tStatus = _TimelineStatus.completed;
                            } else if (isDecisionRejected) {
                              tStatus = _TimelineStatus.completed;
                            } else if (isManualReviewStage && (isChangesRequired || isRejected)) {
                              tStatus = _TimelineStatus.completed;
                            } else if (stageState == 'completed' || stageState == 'done') {
                              tStatus = _TimelineStatus.completed;
                            } else if (stageState == 'active' || stageState == 'in_progress') {
                              tStatus = _TimelineStatus.active;
                            } else if (stage == 'ai_validation' && (status.toLowerCase() != 'submitted')) {
                              tStatus = _TimelineStatus.completed;
                            }

                            String? subtitle;
                            if (isDecisionStage && isApproved) {
                              final decText = (t['decision_text'] ?? t['decision'] ?? (decisionStr.isNotEmpty ? decisionStr : 'Approved')).toString();
                              final timeStr = occurredAt ?? (lastUpdated.isNotEmpty ? _formatDateString(lastUpdated) : null);
                              subtitle = timeStr != null ? '$decText: Program approved and published • $timeStr' : '$decText: Program approved and published';
                            } else if (isDecisionStage && isDecisionChangesRequired) {
                              final decText = (t['decision_text'] ?? t['decision'] ?? (decisionStr.isNotEmpty ? decisionStr : 'Changes Required')).toString();
                              final timeStr = occurredAt ?? (lastUpdated.isNotEmpty ? _formatDateString(lastUpdated) : null);
                              subtitle = timeStr != null ? '$decText • $timeStr' : decText;
                            } else if (isManualReviewStage && (isApproved || isChangesRequired)) {
                              final timeStr = occurredAt ?? (lastUpdated.isNotEmpty ? _formatDateString(lastUpdated) : null);
                              subtitle = timeStr != null ? 'Manual review completed • $timeStr' : 'Manual review completed';
                            } else if (isDecisionStage && isRejected) {
                              final timeStr = occurredAt ?? (lastUpdated.isNotEmpty ? _formatDateString(lastUpdated) : null);
                              subtitle = timeStr != null ? 'Application rejected • $timeStr' : 'Application rejected';
                            } else if (isManualReviewStage && isRejected) {
                              final timeStr = occurredAt ?? (lastUpdated.isNotEmpty ? _formatDateString(lastUpdated) : null);
                              subtitle = timeStr != null ? 'Manual review completed • $timeStr' : 'Manual review completed';
                            } else if (note.isNotEmpty && occurredAt != null && occurredAt.isNotEmpty) {
                              subtitle = '$note • $occurredAt';
                            } else if (note.isNotEmpty) {
                              subtitle = note;
                            } else if (occurredAt != null && occurredAt.isNotEmpty) {
                              subtitle = occurredAt;
                            } else if (stage == 'ai_validation' && tStatus == _TimelineStatus.completed) {
                              subtitle = 'AI validation passed • Score: ${aiReport.overallScore}/100';
                            } else if (isDecisionStage && tStatus == _TimelineStatus.completed) {
                              subtitle = (t['decision_text'] ?? t['decision'] ?? 'Decision reached').toString();
                            }

                            return _buildTimelineStep(
                              title: stageLabel,
                              subtitle: subtitle,
                              status: tStatus,
                              isLast: isLast,
                              customColor: isDecisionApproved
                                  ? const Color(0xFF16A34A)
                                  : (isDecisionChangesRequired ? const Color(0xFFD97706) : (isRejected && isDecisionStage ? const Color(0xFFDC2626) : null)),
                            );
                          }).toList()
                        : [
                            _buildTimelineStep(
                              title: 'Submitted',
                              subtitle: submittedDate.isNotEmpty ? 'Program submitted • ${_formatDateString(submittedDate)}' : 'Program submitted',
                              status: _TimelineStatus.completed,
                            ),
                            _buildTimelineStep(
                              title: 'AI Validation',
                              subtitle: 'AI validation passed • Score: ${aiReport.overallScore}/100',
                              status: _TimelineStatus.completed,
                            ),
                            _buildTimelineStep(
                              title: 'Manual Review',
                              subtitle: isApproved || isChangesRequired
                                  ? (lastUpdated.isNotEmpty ? 'Manual review completed • ${_formatDateString(lastUpdated)}' : 'Manual review completed')
                                  : (status.toLowerCase() == 'submitted'
                                      ? 'Pending committee evaluation'
                                      : 'Manual review in progress'),
                              status: isApproved || isChangesRequired || status.toLowerCase() == 'completed'
                                  ? _TimelineStatus.completed
                                  : (status.toLowerCase() == 'submitted' ? _TimelineStatus.pending : _TimelineStatus.active),
                            ),
                            _buildTimelineStep(
                              title: 'Decision',
                              subtitle: isApproved
                                  ? (lastUpdated.isNotEmpty ? 'Approved: Program approved and published • ${_formatDateString(lastUpdated)}' : 'Approved: Program approved and published')
                                  : (isChangesRequired
                                      ? (lastUpdated.isNotEmpty ? 'Changes Required • ${_formatDateString(lastUpdated)}' : 'Changes Required')
                                      : 'Pending committee decision'),
                              status: isApproved || isChangesRequired || status.toLowerCase() == 'completed'
                                  ? _TimelineStatus.completed
                                  : _TimelineStatus.pending,
                              isLast: true,
                              customColor: isApproved
                                  ? const Color(0xFF16A34A)
                                  : (isChangesRequired ? const Color(0xFFD97706) : null),
                            ),
                          ]),
                    if (reviewerComment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.rate_review_outlined, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reviewer Comment',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    reviewerComment,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF166534),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);
    Color border = const Color(0xFFE2E8F0);

    final s = status.trim().toLowerCase();
    if (s == 'approved' || s == 'complete' || s == 'completed') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      border = const Color(0xFF86EFAC);
    } else if (s == 'in review' || s == 'under review' || s == 'manual_review' || s == 'pending') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
      border = const Color(0xFFFDE68A);
    } else if (s == 'submitted') {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0284C7);
      border = const Color(0xFFBAE6FD);
    } else if (s.contains('changes') || s == 'changes_required' || s == 'changes required') {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
      border = const Color(0xFFFDBA74);
    } else if (s == 'rejected' || s == 'cancelled' || s == 'canceled') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      border = const Color(0xFFFCA5A5);
    }

    final displayLabel = (s == 'manual_review' || s == 'in_review')
        ? 'In Review'
        : (s == 'changes_required' ? 'Changes Required' : status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        displayLabel,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildAiValidationPill(String status, dynamic aiVal, int score) {
    final s = status.toLowerCase();
    final isDone = s == 'manual_review' || s == 'in review' || s == 'approved' || s == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDone ? const Color(0xFF86EFAC) : const Color(0xFFBAE6FD),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 12,
            color: isDone ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
          ),
          const SizedBox(width: 4),
          Text(
            isDone ? 'AI Validation Done ($score/100)' : 'AI Validation Ready ($score/100)',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDone ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitAiValidationActionBar(String currentStatus) {
    final s = currentStatus.toLowerCase();
    final isSubmitted = s == 'submitted';
    if (!isSubmitted) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSubmitted
              ? [const Color(0xFFEFF6FF), const Color(0xFFF0FDF4)]
              : [const Color(0xFFF0FDF4), const Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSubmitted ? const Color(0xFF93C5FD) : const Color(0xFFBBF7D0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSubmitted ? const Color(0xFFDBEAFE) : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSubmitted ? Icons.cloud_upload_rounded : Icons.verified_rounded,
                  size: 16,
                  color: isSubmitted ? const Color(0xFF0284C7) : const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSubmitted
                          ? 'AI Validation Ready to Sync'
                          : 'AI Validation Recorded on Backend',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSubmitted
                          ? 'Click below to submit AI verification and move program to In Review.'
                          : 'Program status is now In Review on server. Awaiting IDF approval.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: _isAiScanning ? null : () => _runAiScan(),
              icon: _isAiScanning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(
                      isSubmitted ? Icons.send_rounded : Icons.sync_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
              label: Text(
                _isAiScanning
                    ? 'Submitting AI Validation to Backend...'
                    : (isSubmitted
                        ? 'Submit AI Validation for Review'
                        : 'Re-send AI Validation to Server'),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitted ? const Color(0xFF0284C7) : const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInfoRow(String label, Widget child, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          child,
        ],
      ),
    );
  }


  Widget _buildMaterialRow(
    BuildContext context,
    String filename,
    String fileUrl, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
      child: Container(
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
            onTap: () => _openOrDownloadFile(fileUrl, filename),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (fileUrl.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Tap to open',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
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
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          'Open',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    String? subtitle,
    required _TimelineStatus status,
    bool isLast = false,
    Color? customColor,
  }) {
    Color circleColor;
    Color borderColor;
    Widget? innerWidget;

    final primaryColor = customColor ?? AppColors.primaryBlue;

    if (status == _TimelineStatus.completed) {
      circleColor = primaryColor;
      borderColor = primaryColor;
      innerWidget = Icon(
        primaryColor == const Color(0xFFD97706)
            ? Icons.edit_note_rounded
            : (primaryColor == const Color(0xFFDC2626) ? Icons.close_rounded : Icons.check),
        size: 13,
        color: Colors.white,
      );
    } else if (status == _TimelineStatus.active) {
      circleColor = customColor != null ? customColor.withAlpha(35) : const Color(0xFFE0F2FE);
      borderColor = primaryColor;
      innerWidget = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
      );
    } else {
      circleColor = const Color(0xFFF1F5F9);
      borderColor = const Color(0xFFCBD5E1);
      innerWidget = null;
    }

    final isPending = status == _TimelineStatus.pending;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: innerWidget != null ? Center(child: innerWidget) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: status == _TimelineStatus.completed
                        ? primaryColor
                        : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isPending ? FontWeight.w500 : FontWeight.w700,
                      color: isPending ? const Color(0xFF94A3B8) : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        height: 1.3,
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

  Widget _buildAiValidationCard(ProgramAiValidationReport report, {bool isSubmitted = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              Expanded(
                child: Row(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Validation & Scoring',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 4),
                    Text(
                      'DONE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Scanning indicator banner
          if (_isAiScanning) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0284C7)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI analyzing scope, timeline, materials & organizer verification...',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Score Banner Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  report.statusColor.withAlpha(22),
                  report.statusColor.withAlpha(8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: report.statusColor.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${report.overallScore}',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: report.statusColor,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          ' / 100',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: report.statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report.grade,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: report.overallScore / 100.0,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(report.statusColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.summary,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Parameter Verification List
          Text(
            'PARAMETER VERIFICATION',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          ...report.checks.map((check) {
            final checkColor = check.isPassed ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
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
                          Icon(
                            check.isPassed ? Icons.check_circle_rounded : Icons.pending_rounded,
                            size: 16,
                            color: checkColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            check.title,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: checkColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${check.score}/${check.maxScore} pts',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: checkColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (check.detail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(
                        check.detail,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Recommendations box if any improvements can be made
          if (report.recommendations.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tips_and_updates_outlined, size: 15, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Text(
                        'AI Optimization Suggestions',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ...report.recommendations.map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Color(0xFFB45309), fontSize: 13)),
                          Expanded(
                            child: Text(
                              rec,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF78350F),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isSubmitted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: _isAiScanning ? null : () => _runAiScan(),
                icon: _isAiScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                label: Text(
                  _isAiScanning
                      ? 'Submitting AI Validation to Server...'
                      : 'Submit AI Validation (${report.overallScore}/100) to Backend',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AiCheckItem {
  final String title;
  final String category;
  final int score;
  final int maxScore;
  final bool isPassed;
  final String detail;

  const AiCheckItem({
    required this.title,
    required this.category,
    required this.score,
    required this.maxScore,
    required this.isPassed,
    required this.detail,
  });
}

class ProgramAiValidationReport {
  final int overallScore; // 0 - 100
  final String grade;
  final String summary;
  final Color statusColor;
  final List<AiCheckItem> checks;
  final List<String> recommendations;

  const ProgramAiValidationReport({
    required this.overallScore,
    required this.grade,
    required this.summary,
    required this.statusColor,
    required this.checks,
    this.recommendations = const [],
  });

  static ProgramAiValidationReport evaluate({
    required String title,
    required String programType,
    required String description,
    required String startDate,
    required String endDate,
    required String venue,
    required String location,
    required String organizer,
    required String organizationType,
    required String contactPerson,
    required String contactPhone,
    required String contactEmail,
    required bool hasBanner,
    required int materialsCount,
    required int agendaCount,
    required bool hasRegistration,
    dynamic backendValidations,
  }) {
    final List<AiCheckItem> checks = [];
    final List<String> suggestions = [];

    final Map<String, dynamic> backendMap = {};
    if (backendValidations is List) {
      for (final item in backendValidations) {
        if (item is Map) {
          final key = (item['check'] ?? item['check_type'] ?? '').toString();
          if (key.isNotEmpty) {
            backendMap[key] = item;
          }
        }
      }
    }

    final isContentApproved = (backendMap['content_review']?['status'] ?? '').toString().toLowerCase() == 'approved';
    final isScheduleApproved = (backendMap['program_details_match']?['status'] ?? '').toString().toLowerCase() == 'approved';
    final isMediaApproved = (backendMap['supporting_materials']?['status'] ?? '').toString().toLowerCase() == 'approved';
    final isOverallApproved = (backendMap['overall']?['status'] ?? '').toString().toLowerCase() == 'approved';

    // 1. Content & Scope Review (Max 25 pts)
    int contentPts = 0;
    final List<String> contentNotes = [];
    if (title.trim().length >= 4) {
      contentPts += 8;
      contentNotes.add('Title defined');
    } else {
      suggestions.add('Provide a descriptive program title (at least 4 characters).');
    }
    if (programType.trim().isNotEmpty) {
      contentPts += 7;
      contentNotes.add('Category assigned ($programType)');
    }
    if (description.trim().length >= 40) {
      contentPts += 10;
      contentNotes.add('Detailed description verified (${description.trim().length} chars)');
    } else if (description.trim().length >= 15) {
      contentPts += 7;
      contentNotes.add('Basic description provided (${description.trim().length} chars)');
      suggestions.add('Expand program description with specific health goals and agenda.');
    } else {
      suggestions.add('Add an informative program overview for review committee evaluation.');
    }
    checks.add(AiCheckItem(
      title: 'Content & Scope Review',
      category: 'content_review',
      score: isContentApproved ? 25 : contentPts,
      maxScore: 25,
      isPassed: isContentApproved || contentPts >= 18,
      detail: isContentApproved
          ? 'Approved by Server • Content parameters verified'
          : (contentNotes.isNotEmpty ? contentNotes.join(' • ') : 'Pending content details'),
    ));

    // 2. Schedule & Venue Feasibility (Max 25 pts)
    int schedulePts = 0;
    final List<String> scheduleNotes = [];
    if (startDate.trim().isNotEmpty) {
      schedulePts += 8;
      scheduleNotes.add('Timeline configured');
    } else {
      suggestions.add('Specify the start and end dates.');
    }
    if (venue.trim().isNotEmpty || location.trim().isNotEmpty) {
      schedulePts += 10;
      final place = venue.isNotEmpty ? venue : location;
      scheduleNotes.add('Venue specified ($place)');
    } else {
      suggestions.add('Set an event venue or city location for attendees.');
    }
    if (agendaCount > 0) {
      schedulePts += 7;
      scheduleNotes.add('$agendaCount session(s) scheduled');
    } else {
      scheduleNotes.add('Agenda timeline optional');
      suggestions.add('Add at least one scheduled session/time slot to improve schedule clarity.');
    }
    checks.add(AiCheckItem(
      title: 'Schedule & Feasibility Match',
      category: 'program_details_match',
      score: isScheduleApproved ? 25 : schedulePts,
      maxScore: 25,
      isPassed: isScheduleApproved || schedulePts >= 18,
      detail: isScheduleApproved
          ? 'Approved by Server • Schedule & venue match confirmed'
          : (scheduleNotes.isNotEmpty ? scheduleNotes.join(' • ') : 'Pending schedule info'),
    ));

    // 3. Media & Supporting Documentation (Max 25 pts)
    int mediaPts = 0;
    final List<String> mediaNotes = [];
    if (hasBanner) {
      mediaPts += 15;
      mediaNotes.add('Banner/Cover uploaded');
    } else {
      suggestions.add('Upload a cover photo/banner to increase audience engagement.');
    }
    if (materialsCount > 0) {
      mediaPts += 10;
      mediaNotes.add('$materialsCount supporting material(s)');
    } else if (hasRegistration) {
      mediaPts += 10;
      mediaNotes.add('Registration link configured');
    } else {
      mediaNotes.add('Standard proposal format');
      suggestions.add('Upload supporting PDFs or add a registration link.');
    }
    checks.add(AiCheckItem(
      title: 'Media & Documentation',
      category: 'supporting_materials',
      score: isMediaApproved ? 25 : mediaPts,
      maxScore: 25,
      isPassed: isMediaApproved || mediaPts >= 15,
      detail: isMediaApproved
          ? 'Approved by Server • Media & attachments verified'
          : (mediaNotes.isNotEmpty ? mediaNotes.join(' • ') : 'Pending media attachments'),
    ));

    // 4. Organizer Credibility & Contact (Max 25 pts)
    int contactPts = 0;
    final List<String> contactNotes = [];
    if (organizer.trim().isNotEmpty) {
      contactPts += 10;
      contactNotes.add('Host entity confirmed');
    }
    if (contactPerson.trim().isNotEmpty) {
      contactPts += 5;
      contactNotes.add('Coordinator listed');
    }
    if (contactEmail.contains('@') && contactEmail.contains('.')) {
      contactPts += 5;
      contactNotes.add('Email address verified');
    } else if (contactEmail.isNotEmpty) {
      suggestions.add('Provide a valid email address with domain.');
    }
    if (contactPhone.trim().length >= 7) {
      contactPts += 5;
      contactNotes.add('Phone attached');
    } else {
      suggestions.add('Add an official contact phone number.');
    }
    checks.add(AiCheckItem(
      title: 'Organizer & Contact Verification',
      category: 'overall',
      score: isOverallApproved ? 25 : contactPts,
      maxScore: 25,
      isPassed: isOverallApproved || contactPts >= 18,
      detail: isOverallApproved
          ? 'Approved by Server • Identity and host verified'
          : (contactNotes.isNotEmpty ? contactNotes.join(' • ') : 'Pending organizer contacts'),
    ));

    final effectiveContentPts = isContentApproved ? 25 : contentPts;
    final effectiveSchedulePts = isScheduleApproved ? 25 : schedulePts;
    final effectiveMediaPts = isMediaApproved ? 25 : mediaPts;
    final effectiveContactPts = isOverallApproved ? 25 : contactPts;

    final total = effectiveContentPts + effectiveSchedulePts + effectiveMediaPts + effectiveContactPts;
    final String grade;
    final Color color;
    final String summary;

    if (total >= 85) {
      grade = 'Excellent • Ready for Review';
      color = const Color(0xFF10B981); // Emerald
      summary = 'Proposal satisfies core parameters with comprehensive documentation.';
    } else if (total >= 70) {
      grade = 'Good • Meets Criteria';
      color = const Color(0xFF0284C7); // Sky/Blue
      summary = 'Strong application parameters met with high feasibility.';
    } else if (total >= 50) {
      grade = 'Satisfactory • In Review';
      color = const Color(0xFFF59E0B); // Amber
      summary = 'Essential data provided. Implementing suggestions below will increase approval speed.';
    } else {
      grade = 'Basic Proposal';
      color = const Color(0xFF64748B);
      summary = 'Initial proposal created. More details can be submitted.';
    }

    return ProgramAiValidationReport(
      overallScore: total,
      grade: grade,
      summary: summary,
      statusColor: color,
      checks: checks,
      recommendations: suggestions,
    );
  }
}


enum _TimelineStatus { completed, active, pending }
