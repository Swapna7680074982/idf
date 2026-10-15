import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../services/api_config.dart';
import '../../../../services/files_service.dart';
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
  bool _isUploadingDoc = false;
  bool _isUploadingBanner = false;

  @override
  void initState() {
    super.initState();
    _uploadedFiles = List.from(widget.model.uploadedFileNames);
  }

  Future<void> _pickBanner(ImageSource source) async {
    setState(() => _isUploadingBanner = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          widget.model.bannerPath = file.path;
          widget.model.bannerFileName = file.name;
        });

        try {
          final uploaded = await FilesService.uploadFile(File(file.path));
          if (mounted) {
            setState(() {
              widget.model.bannerFileId = uploaded.id;
              widget.model.bannerUrl = uploaded.url.isNotEmpty ? uploaded.url : uploaded.storageUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Banner uploaded to server successfully.'),
                backgroundColor: Color(0xFF0284C7),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (_) {
          // Local path preserved for display
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open image picker: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingBanner = false);
    }
  }

  void _removeBanner() {
    setState(() {
      widget.model.bannerPath = null;
      widget.model.bannerFileName = null;
      widget.model.bannerFileId = null;
      widget.model.bannerUrl = null;
    });
  }

  void _showBannerPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                'Upload Program Banner',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a wide landscape banner or hero image for your program',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickBanner(ImageSource.camera);
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickBanner(ImageSource.gallery);
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSupportingDocument(ImageSource source) async {
    setState(() => _isUploadingDoc = true);
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

        try {
          final uploaded = await FilesService.uploadFile(File(file.path));
          if (!widget.model.supportingFileIds.contains(uploaded.id)) {
            widget.model.supportingFileIds.add(uploaded.id);
          }
          final effectiveUrl = uploaded.url.isNotEmpty
              ? uploaded.url
              : (ApiConfig.resolveImageUrl(uploaded.storageUrl) ?? uploaded.storageUrl);
          widget.model.materials.add({
            'name': uploaded.originalName.isNotEmpty ? uploaded.originalName : file.name,
            'url': effectiveUrl,
            'mime_type': uploaded.mimeType.isNotEmpty ? uploaded.mimeType : 'application/pdf',
          });
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Picker error: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingDoc = false);
    }
  }

  Future<void> _pickMultiDocuments() async {
    setState(() => _isUploadingDoc = true);
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      if (files.isNotEmpty) {
        for (final f in files) {
          if (!_uploadedFiles.contains(f.name)) {
            setState(() {
              _uploadedFiles.add(f.name);
            });
          }
          try {
            final uploaded = await FilesService.uploadFile(File(f.path));
            if (!widget.model.supportingFileIds.contains(uploaded.id)) {
              widget.model.supportingFileIds.add(uploaded.id);
            }
            final effectiveUrl = uploaded.url.isNotEmpty
                ? uploaded.url
                : (ApiConfig.resolveImageUrl(uploaded.storageUrl) ?? uploaded.storageUrl);
            widget.model.materials.add({
              'name': uploaded.originalName.isNotEmpty ? uploaded.originalName : f.name,
              'url': effectiveUrl,
              'mime_type': uploaded.mimeType.isNotEmpty ? uploaded.mimeType : 'application/pdf',
            });
          } catch (_) {}
        }
      }
    } catch (e) {
      _pickSupportingDocument(ImageSource.gallery);
    } finally {
      if (mounted) setState(() => _isUploadingDoc = false);
    }
  }

  void _addSampleSupportingFile() {
    setState(() {
      final sampleNames = [
        'Screening_Schedule_2026.pdf',
        'event_brochure.pdf',
        'route_map_schedule.pdf',
        'safety_guidelines.pdf',
        'speaker_bios.pdf',
      ];
      final nextFile = sampleNames.firstWhere(
        (f) => !_uploadedFiles.contains(f),
        orElse: () => 'document_${_uploadedFiles.length + 1}.pdf',
      );
      _uploadedFiles.add(nextFile);
      widget.model.materials.add({
        'name': nextFile,
        'url': '${ApiConfig.baseUrl}/uploads/$nextFile',
        'mime_type': 'application/pdf',
      });
    });
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
      if (index < widget.model.supportingFileIds.length) {
        widget.model.supportingFileIds.removeAt(index);
      }
      if (index < widget.model.materials.length) {
        widget.model.materials.removeAt(index);
      }
    });
  }

  void _handleContinue() {
    widget.model.uploadedFileNames = List.from(_uploadedFiles);
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final hasBanner = widget.model.bannerPath != null && widget.model.bannerPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------------
        // 1. Program Banner Section
        // -------------------------------------------------------------
        Row(
          children: [
            const Icon(Icons.panorama_rounded, size: 18, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              'Program Banner / Cover Photo',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Add a wide promotional banner for your program card and details header',
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        if (!hasBanner)
          InkWell(
            onTap: _showBannerPickerModal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingBanner
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryBlue, size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload Program Banner',
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to choose image from Gallery or take with Camera',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: widget.model.bannerPath != null &&
                              File(widget.model.bannerPath!).existsSync()
                          ? Image.file(File(widget.model.bannerPath!), fit: BoxFit.cover)
                          : Container(
                              color: const Color(0xFF006097),
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.white, size: 42),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withAlpha(190),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PROGRAM BANNER',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    if (_isUploadingBanner)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black38,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.model.bannerFileName ?? 'program_banner.png',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.model.bannerFileId != null
                                  ? 'Uploaded (ID: ${widget.model.bannerFileId})'
                                  : 'Local ready',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: widget.model.bannerFileId != null
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF0284C7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _showBannerPickerModal,
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Change'),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                            onPressed: _removeBanner,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 28),

        // -------------------------------------------------------------
        // 2. Supporting Materials & Documents Section
        // -------------------------------------------------------------
        Row(
          children: [
            const Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            Text(
              'Supporting Materials & Documents',
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Upload brochures, flyers, schedules, safety guidelines or event PDFs (Max 10MB)',
          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: 12),

        // Upload Dropzone
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        'Upload Supporting Material',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickSupportingDocument(ImageSource.camera);
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
                                    Text('Camera', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                _pickMultiDocuments();
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
                                    Text('Files / Photos', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _addSampleSupportingFile();
                        },
                        icon: const Icon(Icons.attach_file_rounded, size: 16),
                        label: const Text('Add sample document (PDF / Brochure)'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: _isUploadingDoc
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined, color: Color(0xFF475569), size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add Documents or Photos',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, DOC, DOCX, JPG, PNG (Max 10MB)',
                  style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Uploaded Files List
        if (_uploadedFiles.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _uploadedFiles.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final fileName = _uploadedFiles[index];
              final isPdf = fileName.toLowerCase().endsWith('.pdf');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isPdf ? const Color(0xFFFEF2F2) : const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                        color: isPdf ? const Color(0xFFDC2626) : AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],

        const SizedBox(height: 24),

        // Continue Button
        CustomButton(
          text: 'Continue to Review',
          onPressed: _handleContinue,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
