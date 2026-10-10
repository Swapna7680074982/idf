import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/program_model.dart';
import '../../../widgets/custom_button.dart';
import '../../home_screen.dart';

class ProgramRegistrationSuccessScreen extends StatelessWidget {
  final ProgramModel program;

  const ProgramRegistrationSuccessScreen({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Green Success Checkmark Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Registration Successful!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'You have successfully registered for this program.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      emoji: '📋',
                      label: 'PROGRAM NAME',
                      value: program.title,
                      isBold: true,
                    ),
                    const Divider(height: 22, color: AppColors.border),
                    _buildDetailRow(
                      emoji: '📅',
                      label: 'DATE',
                      value: program.startDate,
                    ),
                    const Divider(height: 22, color: AppColors.border),
                    _buildDetailRow(
                      emoji: '📍',
                      label: 'LOCATION',
                      value: program.location,
                    ),
                    const Divider(height: 22, color: AppColors.border),
                    _buildDetailRow(
                      emoji: '📊',
                      label: 'REGISTRATION STATUS',
                      value: 'Confirmed',
                      valueColor: const Color(0xFF16A34A),
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Buttons
              CustomButton(
                text: 'View Program',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String emoji,
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
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
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
