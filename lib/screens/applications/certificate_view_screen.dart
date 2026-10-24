import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../services/api_config.dart';
import '../../services/token_storage.dart';

class CertificateViewScreen extends StatelessWidget {
  final CertificateApplicationItem certificate;

  const CertificateViewScreen({
    super.key,
    required this.certificate,
  });

  String _formatScore(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'N/A';
    if (s.endsWith('.00')) {
      return s.substring(0, s.length - 3);
    }
    return s;
  }

  Future<void> _handleDownload(BuildContext context) async {
    try {
      final certId = certificate.id.isNotEmpty ? certificate.id : '1';
      final token = TokenStorage.accessToken;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading certificate for ${certificate.institutionName}...'),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      final uri = Uri.parse('${ApiConfig.baseUrl}/api/applications/certificates/$certId/download');
      http.Response res = await http.get(uri, headers: {
        'Accept': 'application/pdf',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      });

      if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
        // Fallback to alt certification endpoint
        final altUri = Uri.parse('${ApiConfig.baseUrl}/api/certification/certificates/$certId/download');
        res = await http.get(altUri, headers: {
          'Accept': 'application/pdf',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        });
      }

      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        final safeCertNo = certificate.certificateId.replaceAll('/', '-').replaceAll('\\', '-');
        final fileName = '${safeCertNo.isNotEmpty ? safeCertNo : "Certificate_$certId"}.pdf';

        final savedUri = await FilePicker.saveFile(
          dialogTitle: 'Save Certificate PDF',
          fileName: fileName,
          mimeType: 'application/pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: res.bodyBytes,
        );

        if (context.mounted && savedUri != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate downloaded successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Server returned ${res.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleShareWhatsApp(BuildContext context) async {
    final certNo = certificate.certificateId;
    final instName = certificate.institutionName;
    final issued = certificate.issuedDate;
    final expires = certificate.expiresDate;
    final score = _formatScore(certificate.score);

    final certId = certificate.id.isNotEmpty ? certificate.id : '1';
    final verifyUrl =
        '${ApiConfig.baseUrl}/api/applications/certificates/$certId/download';

    final shareText = '''🏆 *IDF ACTIVE CERTIFICATION*
🏛 *Institution:* $instName
📜 *Certificate No:* $certNo
⭐ *Score:* $score
📅 *Issued On:* $issued
⏳ *Expires On:* $expires

Verified by International Diabetes Federation (IDF) Active Accreditation Program.
Download / Verify: $verifyUrl''';

    final encoded = Uri.encodeComponent(shareText);
    final waDeepLink = Uri.parse('whatsapp://send?text=$encoded');
    final waUniversalLink = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      final launched = await launchUrl(waDeepLink, mode: LaunchMode.externalNonBrowserApplication);
      if (!launched) {
        await launchUrl(waUniversalLink, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(waUniversalLink, mode: LaunchMode.externalApplication);
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open WhatsApp: $err'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
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
          certificate.institutionName,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Digital Certificate Card (Screen 40)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF003366),
                      Color(0xFF005596),
                      Color(0xFF027CBF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003366).withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IDF Logo mark & Tag
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'IDF ACTIVE CERTIFICATION',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(200),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Institution Name
                    Text(
                      certificate.institutionName,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      certificate.institutionType,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withAlpha(210),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2x2 Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildCertStatTile(
                            label: 'SCORE',
                            value: _formatScore(certificate.score),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCertStatTile(
                            label: 'STATUS',
                            value: certificate.status,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCertStatTile(
                            label: 'ISSUED',
                            value: certificate.issuedDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCertStatTile(
                            label: 'EXPIRES',
                            value: certificate.expiresDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Certificate No
                    Text(
                      'CERTIFICATE NO',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withAlpha(180),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      certificate.certificateId,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Download Certificate Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handleDownload(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Download Certificate',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Share Certificate Button (WhatsApp)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _handleShareWhatsApp(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Share Certificate',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
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

  Widget _buildCertStatTile({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha(190),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
