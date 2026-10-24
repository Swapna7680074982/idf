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

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file != null) {
        item.filePath = file.path;
        item.fileName = file.name;
        onUpdated();
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not access image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (file != null && file.path != null) {
        item.filePath = file.path;
        item.fileName = file.name;
        onUpdated();
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not access files: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
    final hasAttachment = item.fileName != null && item.fileName!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAttachment ? AppColors.primaryBlue.withAlpha(90) : const Color(0xFFE2E8F0),
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
          // Title + Required Badge
          Row(
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
              if (item.isRequired)
                Container(
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
            ],
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            item.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Attached File indicator
          if (hasAttachment) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _getAttachmentBgColor(item.fileName!),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getAttachmentBorderColor(item.fileName!)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getAttachmentIcon(item.fileName!),
                    size: 18,
                    color: _getAttachmentTextColor(item.fileName!),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.fileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getAttachmentTextColor(item.fileName!),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      item.filePath = null;
                      item.fileName = null;
                      onUpdated();
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Buttons: [ Take Photo ]  [ Gallery ]  [ PDF / Doc ]
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Photo',
                  onTap: () => _pickImage(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () => _pickImage(context, ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.description_outlined,
                  label: 'PDF / Doc',
                  onTap: () => _pickFile(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Accepted: Photos, PDF documents, Word files (.doc, .docx)',
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
