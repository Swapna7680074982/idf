import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../core/theme.dart';
import '../../models/program_model.dart';
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

  @override
  void initState() {
    super.initState();
    _currentProgram = widget.program;
  }

  void _navigateToRegistration() async {
    final result = await Navigator.of(context).push<ProgramModel>(
      MaterialPageRoute(
        builder: (_) => ProgramRegistrationConfirmationScreen(
          program: _currentProgram,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentProgram = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final programFromBloc = context.watch<AppBloc>().state.programs.firstWhere(
      (p) => p.id == widget.program.id,
      orElse: () => _currentProgram,
    );
    final activeProgram = programFromBloc.isRegistered ? programFromBloc : _currentProgram;
    final isRegistered = activeProgram.isRegistered;

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
                      _currentProgram.title,
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
                            label: _currentProgram.category ?? _currentProgram.tag,
                            bgColor: const Color(0xFFFEF3C7),
                            textColor: const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 8),
                          _buildMetaChip(
                            emoji: '📍',
                            label: _currentProgram.location,
                            bgColor: const Color(0xFFFFE4E6),
                            textColor: const Color(0xFFE11D48),
                          ),
                          const SizedBox(width: 8),
                          _buildMetaChip(
                            emoji: '📅',
                            label: _currentProgram.startDate,
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
                        _currentProgram.description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF475569),
                          height: 1.5,
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
                            value: _currentProgram.organizer,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildEventDetailRow(
                            emoji: '📍',
                            label: 'VENUE',
                            value: _currentProgram.venue.isNotEmpty
                                ? _currentProgram.venue
                                : _currentProgram.location,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildEventDetailRow(
                            emoji: '🏁',
                            label: 'END DATE',
                            value: _currentProgram.endDate,
                          ),
                        ],
                      ),
                    ),
                    // Program Agenda Card
                    _buildSectionCard(
                      title: 'Program Agenda',
                      child: AgendaTimelineWidget(
                        agenda: _currentProgram.agenda,
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
                            value: _currentProgram.contactInfo.contactPerson,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildContactRow(
                            icon: Icons.phone_outlined,
                            label: 'PHONE',
                            value: _currentProgram.contactInfo.phone,
                          ),
                          const Divider(height: 18, color: AppColors.border),
                          _buildContactRow(
                            icon: Icons.mail_outline_rounded,
                            label: 'EMAIL',
                            value: _currentProgram.contactInfo.email,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Register Button (or Registered confirmation banner) at the end
                    if (isRegistered)
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
                              'You are registered for this program',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      PrimaryButton(
                        text: 'Register for this Program',
                        onPressed: _navigateToRegistration,
                      ),
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
