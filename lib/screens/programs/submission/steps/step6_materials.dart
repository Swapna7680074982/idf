import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step6Materials extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step6Materials({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step6Materials> createState() => _Step6MaterialsState();
}

class _Step6MaterialsState extends State<Step6Materials> {
  late List<String> _uploadedFiles;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _uploadedFiles = List.from(widget.model.uploadedFileNames);
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          if (!_uploadedFiles.contains(file.name)) {
            _uploadedFiles.add(file.name);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera unavailable or permission denied.'
                  : 'Gallery unavailable or permission denied.',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoading = true);
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      if (files.isNotEmpty) {
        setState(() {
          for (final f in files) {
            if (!_uploadedFiles.contains(f.name)) {
              _uploadedFiles.add(f.name);
            }
          }
        });
      }
    } catch (e) {
      // Fallback to single image pick if multi-picker is not supported
      try {
        final XFile? single = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        if (single != null && !_uploadedFiles.contains(single.name)) {
          setState(() {
            _uploadedFiles.add(single.name);
          });
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not open gallery: $err',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addSampleFile() {
    setState(() {
      final sampleNames = [
        'program_banner.png',
        'event_schedule.pdf',
        'route_map.jpg',
        'safety_guidelines.pdf',
      ];
      final nextFile = sampleNames.firstWhere(
        (f) => !_uploadedFiles.contains(f),
        orElse: () => 'document_${_uploadedFiles.length + 1}.pdf',
      );
      _uploadedFiles.add(nextFile);
    });
  }

  void _showMediaPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Upload Material or Photo',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose Camera to take a photo or Gallery to select existing photos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    // Camera Option
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2FE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Camera',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Take photo',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Gallery Option
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          _pickFromGallery();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library_rounded,
                                  color: Color(0xFFD97706),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Gallery',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Choose photos',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addSampleFile();
                  },
                  icon: const Icon(Icons.attach_file_rounded, size: 16, color: Color(0xFF64748B)),
                  label: Text(
                    'Attach sample document (PDF / Map)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  void _handleContinue() {
    widget.model.uploadedFileNames = List.from(_uploadedFiles);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Dropzone Card
        InkWell(
          onTap: _showMediaPickerModal,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withAlpha(140),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                width: 1.2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cloud Upload Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : const Icon(
                          Icons.cloud_upload_outlined,
                          size: 26,
                          color: AppColors.primaryBlue,
                        ),
                ),
                const SizedBox(height: 14),

                // Title
                Text(
                  'Upload Images / Materials',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  'Tap here to open Camera or Gallery',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Browse Files Button
                OutlinedButton.icon(
                  onPressed: _showMediaPickerModal,
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                  label: Text(
                    'Browse Files',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Uploaded Files List or Placeholder Text
        if (_uploadedFiles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Text(
              'No files uploaded yet. Supporting materials are optional but recommended.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Text(
              'Uploaded Files (${_uploadedFiles.length})',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ..._uploadedFiles.asMap().entries.map((entry) {
            final idx = entry.key;
            final fileName = entry.value;
            final isPdf = fileName.endsWith('.pdf');

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                    color: isPdf ? Colors.redAccent : AppColors.primaryBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () => _removeFile(idx),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 32),

        // Continue Button
        CustomButton(
          text: 'Continue',
          onPressed: _handleContinue,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
