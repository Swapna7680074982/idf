import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../../core/capitalization_formatter.dart';
import '../../../../models/meta_models.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../services/api_config.dart';
import '../../../../services/files_service.dart';
import '../../../../services/metadata_service.dart';
import '../../../../widgets/custom_button.dart';

class Step1ProgramInfo extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step1ProgramInfo({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step1ProgramInfo> createState() => _Step1ProgramInfoState();
}

class _Step1ProgramInfoState extends State<Step1ProgramInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  List<ProgramTypeItem> _programTypes = [];
  ProgramTypeItem? _selectedProgramType;
  bool _isLoadingTypes = true;
  String? _typesError;

  final ImagePicker _picker = ImagePicker();
  bool _isUploadingBanner = false;
  bool _isPickingBanner = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.model.programName);
    _descriptionController = TextEditingController(
      text: widget.model.description.isNotEmpty
          ? widget.model.description
          : widget.model.programDescription,
    );
    _loadProgramTypes();
  }

  Future<void> _loadProgramTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _typesError = null;
    });

    try {
      final types = await MetadataService.getProgramTypes();
      if (mounted) {
        setState(() {
          _programTypes = types.where((t) => !t.name.toLowerCase().contains('conference')).toList();
          _isLoadingTypes = false;

          // Match previously selected type if user had previously chosen one
          if (widget.model.programTypeId != null) {
            final matches = _programTypes.where((t) => t.id == widget.model.programTypeId);
            if (matches.isNotEmpty) {
              _selectedProgramType = matches.first;
            }
          } else if (widget.model.programType.isNotEmpty) {
            final matches = _programTypes.where(
              (t) => t.name.toLowerCase() == widget.model.programType.toLowerCase(),
            );
            if (matches.isNotEmpty) {
              _selectedProgramType = matches.first;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTypes = false;
          _typesError = 'Failed to load program types: ${e.toString()}';
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant Step1ProgramInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model.programName != oldWidget.model.programName &&
        _nameController.text != widget.model.programName) {
      _nameController.text = widget.model.programName;
    }
    final newDesc = widget.model.description.isNotEmpty
        ? widget.model.description
        : widget.model.programDescription;
    if (newDesc != _descriptionController.text) {
      _descriptionController.text = newDesc;
    }
    if (widget.model.programTypeId != null &&
        widget.model.programTypeId != oldWidget.model.programTypeId &&
        _programTypes.isNotEmpty) {
      final matches = _programTypes.where((t) => t.id == widget.model.programTypeId);
      if (matches.isNotEmpty) {
        setState(() => _selectedProgramType = matches.first);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner(ImageSource source) async {
    if (_isPickingBanner || _isUploadingBanner) return;
    setState(() => _isPickingBanner = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          widget.model.bannerPath = file.path;
          widget.model.bannerFileName = file.name;
          _isUploadingBanner = true;
        });

        try {
          final uploaded = await FilesService.uploadFile(File(file.path));
          if (mounted) {
            setState(() {
              widget.model.bannerFileId = uploaded.id;
              widget.model.bannerUrl = uploaded.url.isNotEmpty ? uploaded.url : uploaded.storageUrl;
              _isUploadingBanner = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Banner image uploaded successfully.'),
                backgroundColor: Color(0xFF0284C7),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (_) {
          if (mounted) {
            setState(() => _isUploadingBanner = false);
            // Local path still retained for immediate preview and offline resilience
          }
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not access image. Please check permissions in settings.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open image picker. Please try again.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingBanner = false);
      }
    }
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
                'Select Program Banner',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload a high resolution banner or cover poster for your program',
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
                            const SizedBox(height: 3),
                            Text(
                              'Choose photo',
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
            ],
          ),
        ),
      ),
    );
  }

  void _removeBanner() {
    setState(() {
      widget.model.bannerPath = null;
      widget.model.bannerFileName = null;
      widget.model.bannerFileId = null;
      widget.model.bannerUrl = null;
    });
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.programName = _nameController.text.trim();
      widget.model.programType = _selectedProgramType?.name ?? '';
      widget.model.programTypeId = _selectedProgramType?.id;
      widget.model.description = _descriptionController.text.trim();
      widget.model.programDescription = widget.model.description;
      widget.onContinue();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all required fields to continue'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? localPath = (widget.model.bannerPath != null &&
            widget.model.bannerPath!.isNotEmpty &&
            !widget.model.bannerPath!.startsWith('http') &&
            !widget.model.bannerPath!.startsWith('/') &&
            File(widget.model.bannerPath!).existsSync())
        ? widget.model.bannerPath
        : (widget.model.bannerPath != null && File(widget.model.bannerPath!).existsSync()
            ? widget.model.bannerPath
            : null);

    final String? networkUrl = (widget.model.bannerUrl != null && widget.model.bannerUrl!.isNotEmpty)
        ? widget.model.bannerUrl
        : ((widget.model.bannerPath != null &&
                (widget.model.bannerPath!.startsWith('http') || widget.model.bannerPath!.startsWith('/')) &&
                !File(widget.model.bannerPath!).existsSync())
            ? widget.model.bannerPath
            : null);

    final hasBanner = (localPath != null && localPath.isNotEmpty) ||
        (networkUrl != null && networkUrl.isNotEmpty);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Name / Title
          _buildFieldLabel('Program Name / Title *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            inputFormatters: const [CapitalizeFirstLetterFormatter(words: true)],
            decoration: const InputDecoration(
              hintText: 'e.g. Global Walk for Diabetes 2026',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter program name';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Program Type (Backend API)
          _buildFieldLabel('Program Type *'),
          const SizedBox(height: 6),
          if (_isLoadingTypes)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading program types from server...',
                    style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else if (_typesError != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _typesError!,
                      style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFB91C1C)),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadProgramTypes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<ProgramTypeItem>(
              initialValue: _selectedProgramType,
              hint: Text(
                'Select program type',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _programTypes.map((type) {
                return DropdownMenuItem<ProgramTypeItem>(
                  value: type,
                  child: Text(
                    type.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedProgramType = val;
                });
              },
              validator: (val) =>
                  val == null ? 'Please select program type' : null,
            ),
          const SizedBox(height: 18),

          // Program Banner / Cover Image
          _buildFieldLabel('Program Banner (Cover Image)'),
          const SizedBox(height: 6),
          if (_isPickingBanner || _isUploadingBanner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isPickingBanner
                        ? 'Loading image from gallery...'
                        : 'Uploading banner image...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please wait while the image is being processed',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          else if (!hasBanner)
            InkWell(
              onTap: _showBannerPickerModal,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Upload Program Banner',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports JPG, PNG, WEBP (Recommended: 16:9 landscape)',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: (localPath != null && File(localPath).existsSync())
                            ? Image.file(
                                File(localPath),
                                fit: BoxFit.cover,
                              )
                            : (networkUrl != null && networkUrl.isNotEmpty)
                                ? Image.network(
                                    ApiConfig.resolveMediaUrl(networkUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF00377B),
                                      child: const Center(
                                        child: Icon(Icons.image, color: Colors.white, size: 40),
                                      ),
                                    ),
                                  )
                            : Container(
                                color: const Color(0xFF006097),
                                child: const Center(
                                  child: Icon(Icons.image, color: Colors.white, size: 40),
                                ),
                              ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flag_rounded, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'BANNER',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.model.bannerFileName ??
                                networkUrl?.split('/').last ??
                                localPath?.split(Platform.pathSeparator).last ??
                                'banner_image.png',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _showBannerPickerModal,
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Change'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                visualDensity: VisualDensity.compact,
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
          const SizedBox(height: 18),

          // Description
          _buildFieldLabel('Description *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: const [CapitalizeFirstLetterFormatter(words: false)],
            decoration: const InputDecoration(
              hintText: 'Describe the program and its physical activity goals...',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe the program';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Continue Button
          CustomButton(
            text: 'Continue',
            onPressed: _handleContinue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
