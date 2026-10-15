import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
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
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: Text('Open / Download', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                onPressed: () async {
                  final uri = Uri.tryParse(resolvedUrl);
                  if (uri != null) {
                    try {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (_) {}
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
          await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $filename...')),
          );
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

    final aiValidationList = _liveDetail?['ai_validation'] is List
        ? _liveDetail!['ai_validation'] as List
        : null;

    final timelineList = _liveDetail?['timeline'] is List
        ? _liveDetail!['timeline'] as List
        : null;

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
        final url = (m['url'] ?? m['file_url'] ?? '').toString();
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
        realMaterials.add({
          'name': (m['name'] ?? m['file_name'] ?? 'Document.pdf').toString(),
          'url': (m['url'] ?? m['file_url'] ?? '').toString(),
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
                const SizedBox(height: 16),

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
                                item['time'] ?? '09:00',
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
                    if (lastUpdated.isNotEmpty)
                      _buildInfoRow('Last Updated', _formatDateString(lastUpdated)),
                    _buildInfoRow('Current Status', status, isLast: true),
                  ],
                ),
                const SizedBox(height: 14),

                // 6. AI Validation Card (only if real AI validation checks exist)
                if (aiValidationList != null && aiValidationList.isNotEmpty) ...[
                  _buildSectionCard(
                    title: '🤖 AI Validation',
                    children: aiValidationList.map((check) {
                      final label = (check['label'] ?? check['check'] ?? 'Validation Check').toString();
                      final s = (check['status_label'] ?? check['status'] ?? 'Pending').toString();
                      final isDone = s.toLowerCase() == 'completed' ||
                          s.toLowerCase() == 'passed' ||
                          s.toLowerCase() == 'complete';
                      return _buildCheckRow(label, s, isDone: isDone);
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],

                // 7. Supporting Material Card (With Real Open & Download Action)
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
                  children: timelineList != null && timelineList.isNotEmpty
                      ? timelineList.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final t = entry.value;
                          final stageLabel = (t['label'] ?? t['stage'] ?? 'Stage').toString();
                          final stageState = (t['state'] ?? 'pending').toString().toLowerCase();
                          final subtitle = t['occurred_at'] != null ? _formatDateString(t['occurred_at'].toString()) : null;
                          final isLast = idx == timelineList.length - 1;

                          _TimelineStatus tStatus = _TimelineStatus.pending;
                          if (stageState == 'completed' || stageState == 'done') {
                            tStatus = _TimelineStatus.completed;
                          } else if (stageState == 'active' || stageState == 'in_progress') {
                            tStatus = _TimelineStatus.active;
                          }

                          return _buildTimelineStep(
                            title: stageLabel,
                            subtitle: subtitle,
                            status: tStatus,
                            isLast: isLast,
                          );
                        }).toList()
                      : [
                          _buildTimelineStep(
                            title: 'Application Submitted',
                            subtitle: _formatDateString(submittedDate),
                            status: _TimelineStatus.completed,
                          ),
                          _buildTimelineStep(
                            title: 'Status: $status',
                            subtitle: status.toLowerCase() == 'approved'
                                ? 'Approved by IDF'
                                : (status.toLowerCase() == 'submitted'
                                    ? 'Awaiting review'
                                    : 'Under active review'),
                            status: status.toLowerCase() == 'approved' || status.toLowerCase() == 'completed'
                                ? _TimelineStatus.completed
                                : _TimelineStatus.active,
                            isLast: true,
                          ),
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

    final s = status.toLowerCase();
    if (s == 'approved' || s == 'complete' || s == 'completed') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
    } else if (s == 'in review' || s == 'under review' || s == 'pending') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else if (s == 'submitted') {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0284C7);
    } else if (s == 'rejected' || s == 'cancelled' || s == 'canceled') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: text,
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

  Widget _buildCheckRow(String label, String status,
      {required bool isDone, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDone ? '✅' : '🔄',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
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
                            'Tap to view / download',
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
  }) {
    Color circleColor;
    Color borderColor;
    Widget? innerWidget;

    if (status == _TimelineStatus.completed) {
      circleColor = AppColors.primaryBlue;
      borderColor = AppColors.primaryBlue;
      innerWidget = const Icon(Icons.check, size: 12, color: Colors.white);
    } else if (status == _TimelineStatus.active) {
      circleColor = const Color(0xFFE0F2FE);
      borderColor = AppColors.primaryBlue;
      innerWidget = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
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
                        ? AppColors.primaryBlue
                        : const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
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
}

enum _TimelineStatus { completed, active, pending }
