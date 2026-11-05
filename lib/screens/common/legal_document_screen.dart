import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../models/meta_models.dart';
import '../../services/metadata_service.dart';

class LegalDocumentScreen extends StatefulWidget {
  final String slug;
  final String? initialTitle;
  final LegalDocument? initialDocument;

  const LegalDocumentScreen({
    super.key,
    required this.slug,
    this.initialTitle,
    this.initialDocument,
  });

  /// Convenient helper to navigate to the Legal Document viewer
  static Future<void> open(
    BuildContext context, {
    required String slug,
    String? title,
    LegalDocument? document,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentScreen(
          slug: slug,
          initialTitle: title,
          initialDocument: document,
        ),
      ),
    );
  }

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  LegalDocument? _document;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialDocument != null) {
      _document = widget.initialDocument;
      _isLoading = false;
    } else {
      _fetchDocument();
    }
  }

  Future<void> _fetchDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final doc = await MetadataService.getLegalDocumentBySlug(widget.slug);
      if (mounted) {
        setState(() {
          _document = doc;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(raw);
      if (dt != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
      }
    } catch (_) {}
    return raw;
  }

  Future<void> _launchEmail(String email) async {
    final clean = email.replaceFirst('mailto:', '').trim();
    final uri = Uri(
      scheme: 'mailto',
      path: clean,
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open email application for $clean'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    }
  }

  Future<void> _launchWebUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }
    }
  }

  List<InlineSpan> _buildClickableSpans(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(
      r'(\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b)|(https?:\/\/[^\s<>"{}|\\^`]+)|(mailto:[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})',
      caseSensitive: false,
    );

    int lastIndex = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      final matchedStr = match.group(0)!;
      final isEmail = match.group(1) != null || match.group(3) != null;

      final displayStr = matchedStr.startsWith('mailto:') ? matchedStr.substring(7) : matchedStr;

      spans.add(
        TextSpan(
          text: displayStr,
          style: baseStyle.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (isEmail) {
                _launchEmail(matchedStr);
              } else {
                _launchWebUrl(matchedStr);
              }
            },
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }

  String _cleanHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#x2F;', '/');
  }

  @override
  Widget build(BuildContext context) {
    final fallbackTitle = widget.slug == 'privacy'
        ? 'Privacy Policy'
        : (widget.slug == 'terms' ? 'Terms of Service' : 'Legal Document');
    final title = _document?.title.isNotEmpty == true
        ? _document!.title
        : (widget.initialTitle ?? fallbackTitle);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading $title from server...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEE2E2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to Load $title',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetchDocument,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              'Retry',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchDocument,
                    color: AppColors.primaryBlue,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Document Info Header Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _document!.title.isNotEmpty
                                            ? _document!.title
                                            : fallbackTitle,
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    if (_document!.version.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFFBFDBFE),
                                          ),
                                        ),
                                        child: Text(
                                          'v${_document!.version}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (_document!.effectiveFrom.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Effective: ${_formatDate(_document!.effectiveFrom)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Document Body Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: _buildDocumentContent(
                              _document!.content,
                              htmlContent: _document!.contentHtml,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildDocumentContent(String rawContent, {String? htmlContent}) {
    // If HTML content is available, parse structured HTML tags first
    if (htmlContent != null && htmlContent.trim().isNotEmpty) {
      final widgets = _parseHtmlContent(htmlContent);
      if (widgets.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        );
      }
    }

    if (rawContent.trim().isEmpty) {
      return Text(
        'No content available for this document.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF94A3B8),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Split paragraphs by two newlines or by headings
    final paragraphs = rawContent.split(RegExp(r'\r?\n\r?\n'));
    final List<Widget> widgets = [];

    for (int i = 0; i < paragraphs.length; i++) {
      final p = paragraphs[i].trim();
      if (p.isEmpty) continue;

      // Check if this paragraph contains bullet points
      if (p.contains('\n- ') || p.contains('\n• ') || p.startsWith('- ') || p.startsWith('• ')) {
        final lines = p.split(RegExp(r'\r?\n'));
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('- ') || trimmedLine.startsWith('• ')) {
            final bulletText = trimmedLine.substring(2).trim();
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 8),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: _buildClickableSpans(
                            bulletText,
                            GoogleFonts.inter(
                              fontSize: 13.5,
                              height: 1.55,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (trimmedLine.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text.rich(
                  TextSpan(
                    children: _buildClickableSpans(
                      trimmedLine,
                      GoogleFonts.inter(
                        fontSize: 13.5,
                        height: 1.55,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
        widgets.add(const SizedBox(height: 10));
        continue;
      }

      // Check if paragraph looks like a short section header (< 50 chars, no terminal punctuation)
      final isHeading = p.length < 50 &&
          !p.endsWith('.') &&
          !p.endsWith(',') &&
          !p.endsWith(';') &&
          !p.contains('\n');

      if (isHeading) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 14, bottom: 8),
            child: Text.rich(
              TextSpan(
                children: _buildClickableSpans(
                  p,
                  GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text.rich(
              TextSpan(
                children: _buildClickableSpans(
                  p,
                  GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.6,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _parseHtmlContent(String html) {
    final widgets = <Widget>[];

    // Strip <head>, <style>, <script>
    String body = html
        .replaceAll(RegExp(r'<head[\s\S]*?<\/head>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[\s\S]*?<\/style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<script[\s\S]*?<\/script>', caseSensitive: false), '');

    // Match HTML blocks: headings, paragraphs, lists
    final blockRegex = RegExp(
      r'<(p|h[1-6]|li|div)([^>]*)>([\s\S]*?)<\/\1>',
      caseSensitive: false,
    );

    final matches = blockRegex.allMatches(body);

    for (final match in matches) {
      final tag = match.group(1)!.toLowerCase();
      final innerHtml = match.group(3)!.trim();

      if (innerHtml.isEmpty) continue;

      // Check if innerHtml has <strong>...</strong> as full heading or tag is h1-h6
      final isHeading = tag.startsWith('h') ||
          (innerHtml.startsWith('<strong') && innerHtml.endsWith('</strong>')) ||
          (innerHtml.startsWith('<b>') && innerHtml.endsWith('</b>'));

      // Clean HTML tags from inner text while preserving content
      String plainText = innerHtml
          .replaceAll(RegExp(r'<br\s*\/?>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'<[^>]*>'), '');
      plainText = _cleanHtmlEntities(plainText).trim();

      if (plainText.isEmpty) continue;

      if (tag == 'li') {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _buildClickableSpans(
                        plainText,
                        GoogleFonts.inter(
                          fontSize: 13.5,
                          height: 1.55,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (isHeading) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Text.rich(
              TextSpan(
                children: _buildClickableSpans(
                  plainText,
                  GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text.rich(
              TextSpan(
                children: _buildClickableSpans(
                  plainText,
                  GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.6,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
