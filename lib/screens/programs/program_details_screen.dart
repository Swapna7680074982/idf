import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../core/theme.dart';
import '../../models/program_model.dart';
import '../../services/api_client.dart';
import '../../services/programs_service.dart';
import '../../widgets/custom_button.dart';
import 'registration/program_registration_confirmation_screen.dart';
import 'widgets/agenda_timeline_widget.dart';
import 'widgets/program_image_banner.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final ProgramModel program;

  const ProgramDetailsScreen({
    super.key,
    required this.program,
  });

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  late ProgramModel _currentProgram;
  bool _isLoadingDetail = false;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentProgram = widget.program;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (widget.program.id.isEmpty) return;
    setState(() {
      _isLoadingDetail = true;
    });
    try {
      final detail = await ProgramsService.getProgramDetail(widget.program.id);
      if (mounted) {
        setState(() {
          _currentProgram = detail;
          _isLoadingDetail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  void _navigateToRegistration(ProgramModel program) async {
    final result = await Navigator.of(context).push<ProgramModel>(
      MaterialPageRoute(
        builder: (_) => ProgramRegistrationConfirmationScreen(
          program: program,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentProgram = result;
      });
      _fetchDetail();
    }
  }

  Future<void> _cancelRegistration() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Cancel Registration',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel your registration for "${_currentProgram.title}"?',
          style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Cancel Registration',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await ProgramsService.cancelProgramRegistration(_currentProgram.id);
      if (mounted) {
        context.read<AppBloc>().add(CancelProgramRegistrationRequested(_currentProgram.id));
        setState(() {
          _currentProgram = _currentProgram.copyWith(isRegistered: false);
          _isCancelling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration cancelled successfully.'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.displayMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel registration: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocProgram = context.watch<AppBloc>().state.programs.where((p) => p.id == widget.program.id).firstOrNull;
    final isRegistered = blocProgram?.isRegistered ?? _currentProgram.isRegistered;
    final activeProgram = _currentProgram.copyWith(isRegistered: isRegistered);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner with Back Button
              Stack(
                children: [
                  ProgramImageBanner(
                    program: activeProgram,
                    height: 220,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    showFloatingStatus: true,
                  ),
                  if (_isLoadingDetail)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        color: AppColors.primaryBlue,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program Title
                    Text(
                      activeProgram.title,
                      style: GoogleFonts.inter(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Meta Tags Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildMetaChip(
                            emoji: '📋',
                            label: activeProgram.category ?? activeProgram.tag,
                            bgColor: const Color(0xFFFEF3C7),
                            textColor: const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 8),
                          _buildMetaChip(
                            emoji: '📍',
                            label: activeProgram.location,
                            bgColor: const Color(0xFFFFE4E6),
                            textColor: const Color(0xFFE11D48),
                          ),
                          const SizedBox(width: 8),
                          _buildMetaChip(
                            emoji: '📅',
                            label: activeProgram.startDate,
                            bgColor: const Color(0xFFF1F5F9),
                            textColor: const Color(0xFF475569),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // About This Program Card
                    _buildSectionCard(
                      title: 'About This Program',
                      child: Text(
                        activeProgram.description.isNotEmpty
                            ? activeProgram.description
                            : 'No description available for this program.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: const Color(0xFF475569),
                          height: 1.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Event Details Card
                    _buildSectionCard(
                      title: 'Event Details',
                      child: Column(
                        children: [
                          _buildEventDetailRow(
                            emoji: '🏢',
                            label: 'ORGANIZER',
                            value: activeProgram.organizer,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildEventDetailRow(
                            emoji: '📍',
                            label: 'VENUE',
                            value: activeProgram.venue.isNotEmpty
                                ? activeProgram.venue
                                : activeProgram.location,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildEventDetailRow(
                            emoji: '🏁',
                            label: 'END DATE',
                            value: activeProgram.endDate,
                          ),
                        ],
                      ),
                    ),
                    // Program Agenda Card
                    _buildSectionCard(
                      title: 'Program Agenda',
                      child: AgendaTimelineWidget(
                        agenda: activeProgram.agenda,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Contact Information Card
                    _buildSectionCard(
                      title: 'Contact Information',
                      child: Column(
                        children: [
                          _buildContactRow(
                            icon: Icons.person_outline_rounded,
                            label: 'CONTACT PERSON',
                            value: activeProgram.contactInfo.contactPerson,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildContactRow(
                            icon: Icons.phone_outlined,
                            label: 'PHONE',
                            value: activeProgram.contactInfo.phone,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildContactRow(
                            icon: Icons.mail_outline_rounded,
                            label: 'EMAIL',
                            value: activeProgram.contactInfo.email,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Event Status Registration Actions
                    if (activeProgram.status == ProgramStatus.cancelled) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'This event has been cancelled',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (activeProgram.status == ProgramStatus.completed) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_busy_rounded, color: Color(0xFF64748B), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Registration Closed (Event Completed)',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (isRegistered) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              activeProgram.status == ProgramStatus.ongoing
                                  ? 'Registered • Session is Live!'
                                  : 'You are registered for this program',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: _isCancelling
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.errorRed),
                              )
                            : Icon(Icons.cancel_outlined, color: AppColors.errorRed, size: 18),
                        label: Text(
                          _isCancelling ? 'Cancelling...' : 'Cancel Registration',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorRed,
                          ),
                        ),
                        onPressed: _isCancelling ? null : _cancelRegistration,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 46),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ] else ...[
                      PrimaryButton(
                        text: activeProgram.status == ProgramStatus.ongoing
                            ? 'Join Session • Register Now'
                            : (activeProgram.registrationLink != null && activeProgram.registrationLink!.isNotEmpty
                                ? 'Register Now'
                                : 'Register for this Program'),
                        onPressed: () => _navigateToRegistration(activeProgram),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required String emoji,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEventDetailRow({
    required String emoji,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
