import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _uploadedFiles = List.from(widget.model.uploadedFileNames);
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
        Container(
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
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
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
                'PNG, JPG, PDF up to 10MB each',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // Browse Files Button
              OutlinedButton(
                onPressed: _addSampleFile,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryBlue, width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Browse Files',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
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
