import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../bloc/app_bloc.dart';
import '../../../bloc/app_event.dart';
import '../../../core/theme.dart';
import '../../../models/program_model.dart';
import '../../../widgets/custom_button.dart';
import 'program_registration_success_screen.dart';

class ProgramRegistrationConfirmationScreen extends StatefulWidget {
  final ProgramModel program;

  const ProgramRegistrationConfirmationScreen({
    super.key,
    required this.program,
  });

  @override
  State<ProgramRegistrationConfirmationScreen> createState() =>
      _ProgramRegistrationConfirmationScreenState();
}

class _ProgramRegistrationConfirmationScreenState
    extends State<ProgramRegistrationConfirmationScreen> {
  bool _isConfirming = false;

  void _onConfirm() async {
    setState(() {
      _isConfirming = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      context.read<AppBloc>().add(RegisterForProgramRequested(widget.program.id));

      setState(() {
        _isConfirming = false;
      });

      final updatedProgram = widget.program.copyWith(isRegistered: true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProgramRegistrationSuccessScreen(
            program: updatedProgram,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Registration Confirmation',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review your registration details',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You are about to register for this program.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: const Color(0xFF0369A1),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Program Details Section
              Text(
                'Program Details',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.1),
                ),
                child: Column(
                  children: [
                    _buildDetailItem(
                      emoji: '📋',
                      label: 'PROGRAM NAME',
                      value: program.title,
                      isBold: true,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailItem(
                      emoji: '🏷️',
                      label: 'PROGRAM TYPE',
                      value: program.category ?? program.tag,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailItem(
                      emoji: '📅',
                      label: 'DATE',
                      value: program.startDate,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailItem(
                      emoji: '📍',
                      label: 'LOCATION / VENUE',
                      value: program.venue.isNotEmpty ? program.venue : program.location,
                    ),
                    const Divider(height: 20, color: AppColors.border),
                    _buildDetailItem(
                      emoji: '🏢',
                      label: 'ORGANIZER',
                      value: program.organizer,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              CustomButton(
                text: 'Confirm Registration',
                isLoading: _isConfirming,
                onPressed: _onConfirm,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String emoji,
    required String label,
    required String value,
    bool isBold = false,
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
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
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
