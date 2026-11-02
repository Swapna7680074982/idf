import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';

class EvidenceUploadTile extends StatelessWidget {
  final EvidenceItem item;
  final VoidCallback onUpdated;

  const EvidenceUploadTile({
    super.key,
    required this.item,
    required this.onUpdated,
  });

  Future<void> _pickCamera(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file != null) {
        item.addAttachment(
          filePath: file.path,
          fileName: file.name,
        );
        onUpdated();
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not access camera: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickGallery(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final List<XFile> files = await picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (files.isNotEmpty) {
        for (final file in files) {
          item.addAttachment(
            filePath: file.path,
            fileName: file.name,
          );
        }
        onUpdated();
      }
    } catch (e) {
      // Fallback to single image pick
      try {
        final picker = ImagePicker();
        final XFile? file = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85,
        );
        if (file != null) {
          item.addAttachment(filePath: file.path, fileName: file.name);
          onUpdated();
        }
      } catch (err) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not access gallery: $err'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickFiles(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (files.isNotEmpty) {
        for (final file in files) {
          if (file.path != null) {
            item.addAttachment(
              filePath: file.path,
              fileName: file.name,
            );
          }
        }
        onUpdated();
      }
    } catch (e) {
      try {
        final PlatformFile? single = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        );
        if (single != null && single.path != null) {
          item.addAttachment(filePath: single.path, fileName: single.name);
          onUpdated();
        }
      } catch (err) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Could not access files: $err'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  IconData _getAttachmentIcon(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_rounded;
    }
    return Icons.image_rounded;
  }

  Color _getAttachmentTextColor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return const Color(0xFFDC2626);
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return const Color(0xFF2563EB);
    }
    return const Color(0xFF15803D);
  }

  Color _getAttachmentBgColor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return const Color(0xFFFEF2F2);
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return const Color(0xFFEFF6FF);
    }
    return const Color(0xFFF0FDF4);
  }

  Color _getAttachmentBorderColor(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return const Color(0xFFFECACA);
    } else if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return const Color(0xFFBFDBFE);
    }
    return const Color(0xFFBBF7D0);
  }

  @override
  Widget build(BuildContext context) {
    final attachments = item.attachments;
    final hasAttachments = attachments.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAttachments ? AppColors.primaryBlue.withAlpha(90) : const Color(0xFFE2E8F0),
          width: 1.1,
        ),
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
          // Title + Badges (Required, GPS, Attachments count)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.isRequired)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Required',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              if (hasAttachments)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${attachments.length} ${attachments.length == 1 ? 'file' : 'files'}',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),

          // Description
          if (item.description.isNotEmpty)
            Text(
              item.description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),

          if (item.requiresGps) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 13, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text(
                  'GPS metadata verified for physical amenities',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),

          // List of Attached Documents
          if (hasAttachments) ...[
            ...attachments.asMap().entries.map((entry) {
              final index = entry.key;
              final att = entry.value;
              final name = (att.fileName != null && att.fileName!.isNotEmpty)
                  ? att.fileName!
                  : ((att.fileUrl != null && att.fileUrl!.isNotEmpty)
                      ? att.fileUrl!.split('/').last
                      : 'Attachment ${index + 1}');

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _getAttachmentBgColor(name),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _getAttachmentBorderColor(name)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getAttachmentIcon(name),
                      size: 18,
                      color: _getAttachmentTextColor(name),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getAttachmentTextColor(name),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        item.removeAttachmentAt(index);
                        onUpdated();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
          ],

          // Action Buttons: [ + Photo ]  [ + Gallery ]  [ + PDF / Doc ]
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () => _pickCamera(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickGallery(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.description_outlined,
                  label: 'Files',
                  onTap: () => _pickFiles(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Upload multiple photos, PDFs, or Word documents (.doc, .docx)',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDBEAFE), width: 1.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
