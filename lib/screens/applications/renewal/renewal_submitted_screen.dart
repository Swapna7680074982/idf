import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/date_time_utils.dart';
import '../../../core/theme.dart';
import '../../home_screen.dart';

class RenewalSubmittedScreen extends StatelessWidget {
  final String institutionName;
  final String applicationNumber;
  final String status;
  final String? submissionDate;
  final String? originalCertificateNo;

  const RenewalSubmittedScreen({
    super.key,
    required this.institutionName,
    required this.applicationNumber,
    this.status = 'Manual Review',
    this.submissionDate,
    this.originalCertificateNo,
  });

  String _formatCurrentDate() {
    return DateTimeUtils.formatDateTime(DateTime.now().toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = submissionDate ?? _formatCurrentDate();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Green Success Check Circle
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Title
              Text(
                'Renewal Application\nSubmitted',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Your renewal application has been submitted and queued for AI audit and IDF review.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow('Institution', institutionName),
                    const Divider(height: 18, color: Color(0xFFF1F5F9)),
                    _buildRow('Application ID', applicationNumber, isBold: true),
                    const Divider(height: 18, color: Color(0xFFF1F5F9)),
                    _buildRow('Submission Date', displayDate),
                    const Divider(height: 18, color: Color(0xFFF1F5F9)),
                    _buildRow('Status', status),
                    const Divider(height: 18, color: Color(0xFFF1F5F9)),
                    _buildRow(
                      'Original Certificate',
                      originalCertificateNo != null && originalCertificateNo!.isNotEmpty
                          ? originalCertificateNo!
                          : 'Previous Certificate',
                      isSmallValue: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary Action: View Application
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(
                          initialTabIndex: 3,
                          initialAppTabIndex: 1,
                        ),
                      ),
                      (route) => false,
                    );
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
                    'View Application',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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

  Widget _buildRow(String label, String value,
      {bool isBold = false, bool isSmallValue = false}) {
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
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(
              fontSize: isSmallValue ? 11.5 : 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
