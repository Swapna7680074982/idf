import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../services/programs_service.dart';
import 'certificate_view_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final programInfo = _liveDetail?['program_information'] is Map<String, dynamic>
        ? _liveDetail!['program_information'] as Map<String, dynamic>
        : null;
    final submissionDetails = _liveDetail?['submission_details'] is Map<String, dynamic>
        ? _liveDetail!['submission_details'] as Map<String, dynamic>
        : null;

    final title = programInfo?['program_name']?.toString() ??
        programInfo?['title']?.toString() ??
        widget.item.programName;
    final status = submissionDetails?['current_status']?.toString() ??
        _liveDetail?['status']?.toString() ??
        widget.item.status;
    final refNo = submissionDetails?['application_id']?.toString() ??
        _liveDetail?['application_id']?.toString() ??
        widget.item.referenceNumber;
    final programType = programInfo?['program_type']?.toString() ?? widget.item.programType;
    final startDate = programInfo?['start_date']?.toString() ?? widget.item.startDate;
    final location = programInfo?['location']?.toString() ??
        programInfo?['city']?.toString() ??
        widget.item.location;
    final organizer = programInfo?['organizer']?.toString() ??
        programInfo?['organization_entity_name']?.toString() ??
        widget.item.organizer;
    final submittedDate = submissionDetails?['submitted']?.toString() ?? widget.item.submittedDate;
    final lastUpdated = submissionDetails?['last_updated']?.toString() ?? widget.item.lastUpdatedDate;

    final isApproved = status.toLowerCase() == 'approved';

    final aiValidationList = _liveDetail?['ai_validation'] is List
        ? _liveDetail!['ai_validation'] as List
        : null;

    final timelineList = _liveDetail?['timeline'] is List
        ? _liveDetail!['timeline'] as List
        : null;

    final materialsList = _liveDetail?['supporting_material'] is List
        ? _liveDetail!['supporting_material'] as List
        : null;

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
                // Top Header Row with Circular Back Button & Loader
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
                    if (_isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title & Status Row
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
                const SizedBox(height: 4),
                Text(
                  'Application ID: $refNo',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // If Approved: show Active Institution banner
                if (isApproved) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CertificateViewScreen(
                                certificate: CertificateApplicationItem(
                                  id: '2',
                                  institutionName: 'Lagos State University',
                                  institutionType: 'College / University',
                                  certificateId: 'IDFAC-2025-LSU-001',
                                  issuedDate: '01 Sep 2025',
                                  expiresDate: '01 Sep 2027',
                                  status: 'Active',
                                  score: '8/10',
                                ),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Color(0xFFD97706),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lagos State University',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'College / University · Score: 8/10',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Active',
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF16A34A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Expires: 01 Sep 2027',
                                          style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            color: const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // 1. Program Information Card
                _buildSectionCard(
                  title: 'Program Information',
                  children: [
                    _buildInfoRow('Program Name', title),
                    _buildInfoRow('Program Type', programType),
                    _buildInfoRow('Start Date', startDate),
                    _buildInfoRow('Location', location),
                    _buildInfoRow('Organizer', organizer, isLast: true),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Submission Details Card
                _buildSectionCard(
                  title: 'Submission Details',
                  children: [
                    _buildInfoRow('Application ID', refNo),
                    _buildInfoRow('Submitted', submittedDate),
                    _buildInfoRow('Last Updated', lastUpdated),
                    _buildInfoRow('Current Status', status, isLast: true),
                  ],
                ),
                const SizedBox(height: 14),

                // 3. AI Validation Card
                _buildSectionCard(
                  title: '🤖 AI Validation',
                  children: aiValidationList != null && aiValidationList.isNotEmpty
                      ? aiValidationList.map((check) {
                          final label = (check['label'] ?? check['check'] ?? 'Validation Check').toString();
                          final s = (check['status_label'] ?? check['status'] ?? 'Pending').toString();
                          final isDone = s.toLowerCase() == 'completed' || s.toLowerCase() == 'passed' || s.toLowerCase() == 'complete';
                          return _buildCheckRow(label, s, isDone: isDone);
                        }).toList()
                      : [
                          _buildCheckRow('Content Review', 'Completed', isDone: true),
                          _buildCheckRow('Program Details Match', 'Completed', isDone: true),
                          _buildCheckRow('Supporting Materials', 'Reviewed', isDone: true),
                          _buildCheckRow(
                            'Validation Status',
                            isApproved ? 'Complete' : 'In Progress',
                            isDone: isApproved,
                            isLast: true,
                          ),
                        ],
                ),
                const SizedBox(height: 14),

                // 4. Supporting Material Card
                _buildSectionCard(
                  title: 'Supporting Material',
                  children: materialsList != null && materialsList.isNotEmpty
                      ? materialsList.map((m) {
                          final name = (m['name'] ?? m['original_name'] ?? 'Document.pdf').toString();
                          return _buildMaterialRow(context, name);
                        }).toList()
                      : [
                          _buildMaterialRow(context, 'Program flyer.pdf'),
                          _buildMaterialRow(context, 'Schedule 2026.pdf', isLast: true),
                        ],
                ),
                const SizedBox(height: 14),

                // 5. Application Timeline Card
                _buildSectionCard(
                  title: 'Application Timeline',
                  children: timelineList != null && timelineList.isNotEmpty
                      ? timelineList.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final t = entry.value;
                          final stageLabel = (t['label'] ?? t['stage'] ?? 'Stage').toString();
                          final stageState = (t['state'] ?? 'pending').toString().toLowerCase();
                          final subtitle = t['occurred_at']?.toString();
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
                            title: 'Submitted',
                            subtitle: submittedDate,
                            status: _TimelineStatus.completed,
                          ),
                          _buildTimelineStep(
                            title: 'AI Validation',
                            subtitle: isApproved ? 'Completed' : 'In progress',
                            status: isApproved ? _TimelineStatus.completed : _TimelineStatus.active,
                          ),
                          _buildTimelineStep(
                            title: 'Manual Review',
                            subtitle: isApproved ? 'Approved by IDF' : null,
                            status: isApproved ? _TimelineStatus.completed : _TimelineStatus.pending,
                          ),
                          _buildTimelineStep(
                            title: 'Decision',
                            subtitle: isApproved ? 'Final Decision: Approved' : null,
                            status: isApproved ? _TimelineStatus.completed : _TimelineStatus.pending,
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

    if (status == 'Approved') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
    } else if (status == 'In Review') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else if (status == 'Submitted') {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0284C7);
    } else if (status == 'Completed') {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF475569);
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

  Widget _buildMaterialRow(BuildContext context, String filename,
      {bool isLast = false}) {
    void openFile() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening $filename...'),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: openFile,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      size: 18, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Text(
                    'View',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
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
