import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../services/api_config.dart';
import '../../services/file_download_helper.dart';
import '../../services/token_storage.dart';
import 'renewal/renewal_wizard_screen.dart';

class CertificateViewScreen extends StatefulWidget {
  final CertificateApplicationItem certificate;

  const CertificateViewScreen({
    super.key,
    required this.certificate,
  });

  @override
  State<CertificateViewScreen> createState() => _CertificateViewScreenState();
}

class _CertificateViewScreenState extends State<CertificateViewScreen> {
  bool _isDownloading = false;
  bool _isDownloaded = false;
  String? _downloadedFilePath;
  String? _downloadFileName;
  String? _downloadError;
  bool _showTopBand = false;

  String _formatScore(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return 'N/A';
    if (s.endsWith('.00')) {
      return s.substring(0, s.length - 3);
    }
    return s;
  }

  Future<void> _handleDownload() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _showTopBand = true;
      _downloadError = null;
    });

    try {
      final certId = widget.certificate.id.isNotEmpty ? widget.certificate.id : '1';
      final token = TokenStorage.accessToken;

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
        final safeCertNo = widget.certificate.certificateId
            .replaceAll('/', '-')
            .replaceAll('\\', '-')
            .replaceAll(' ', '_');
        final fileName = '${safeCertNo.isNotEmpty ? safeCertNo : "Certificate_$certId"}.pdf';

        // Save directly to device Downloads / File Manager storage
        final savedFile = await FileDownloadHelper.saveFileToDownloads(
          fileName: fileName,
          bytes: res.bodyBytes,
        );

        if (!mounted) return;

        setState(() {
          _isDownloading = false;
          _isDownloaded = true;
          _downloadedFilePath = savedFile.path;
          _downloadFileName = fileName;
          _showTopBand = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Downloaded: $fileName',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Auto-dismiss top band after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isDownloaded) {
            setState(() {
              _showTopBand = false;
            });
          }
        });
      } else {
        throw Exception('Server returned ${res.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadError = 'Download failed: $e';
        _showTopBand = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openDownloadedFile() async {
    if (_downloadedFilePath == null) {
      await _handleDownload();
      return;
    }

    final file = File(_downloadedFilePath!);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloaded file not found. Downloading again...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      await _handleDownload();
      return;
    }

    final result = await FileDownloadHelper.openFile(
      _downloadedFilePath!,
      mimeType: 'application/pdf',
    );

    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: ${result.message}'),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleShareWhatsApp(BuildContext context) async {
    final certNo = widget.certificate.certificateId;
    final instName = widget.certificate.institutionName;
    final issued = widget.certificate.issuedDate;
    final expires = widget.certificate.expiresDate;
    final score = _formatScore(widget.certificate.score);

    final certId = widget.certificate.id.isNotEmpty ? widget.certificate.id : '1';
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

  Widget _buildTopBand() {
    if (!_showTopBand) return const SizedBox.shrink();

    // 1. Downloading state top band
    if (_isDownloading) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border(
            bottom: BorderSide(color: AppColors.primaryBlue.withAlpha(90), width: 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Downloading Certificate...',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Saving directly to device storage',
                          style: GoogleFonts.inter(
                            color: Colors.white.withAlpha(190),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const LinearProgressIndicator(
              minHeight: 2.5,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ],
        ),
      );
    }

    // 2. Download error state top band
    if (_downloadError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF991B1B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _downloadError!,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: _handleDownload,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text('RETRY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _showTopBand = false),
            ),
          ],
        ),
      );
    }

    // 3. Downloaded successfully state top band (Tap to open)
    if (_isDownloaded && _downloadedFilePath != null) {
      return Material(
        color: const Color(0xFF0F172A),
        child: InkWell(
          onTap: _openDownloadedFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: const Color(0xFF10B981).withAlpha(150), width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(35),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Color(0xFF34D399), size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _downloadFileName ?? 'Certificate.pdf',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Saved to device Downloads',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF86EFAC),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: () => setState(() => _showTopBand = false),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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
          widget.certificate.institutionName,
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
        child: Column(
          children: [
            // Top Band (Loading progress, success with tap to open, or error)
            _buildTopBand(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

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
                                  border: Border.all(color: Colors.white.withAlpha(40), width: 1),
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
                            widget.certificate.institutionName,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.certificate.institutionType,
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
                                  value: _formatScore(widget.certificate.score),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCertStatTile(
                                  label: 'STATUS',
                                  value: widget.certificate.status,
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
                                  value: widget.certificate.issuedDate,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCertStatTile(
                                  label: 'EXPIRES',
                                  value: widget.certificate.expiresDate,
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
                            widget.certificate.certificateId,
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

                    const SizedBox(height: 28),

                    if (widget.certificate.isExpiredOrRenewable) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RenewalWizardScreen(certificate: widget.certificate),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(Icons.autorenew_rounded, size: 20),
                          label: Text(
                            'Renew Certificate',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Primary Action Button: Open if downloaded, Download if not
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading
                            ? null
                            : (_isDownloaded ? _openDownloadedFile : _handleDownload),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDownloaded
                              ? const Color(0xFF16A34A)
                              : AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: AppColors.primaryBlue.withAlpha(160),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isDownloaded
                                    ? Icons.file_open_rounded
                                    : Icons.download_rounded,
                                size: 19,
                              ),
                        label: Text(
                          _isDownloading
                              ? 'Downloading Certificate...'
                              : (_isDownloaded ? 'Open Certificate' : 'Download Certificate'),
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Re-download option if already downloaded
                    if (_isDownloaded) ...[
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: _isDownloading ? null : _handleDownload,
                        icon: const Icon(Icons.refresh_rounded, size: 15, color: Color(0xFF64748B)),
                        label: Text(
                          'Download Again',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Share Certificate Button (WhatsApp)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleShareWhatsApp(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.primaryBlue),
                        label: Text(
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
          ],
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
