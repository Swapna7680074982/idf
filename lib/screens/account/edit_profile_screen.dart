import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../core/theme.dart';
import '../../services/account_service.dart';
import '../../services/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isSaving = false;
  String? _uploadedPhotoUrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppBloc>().state.user;
    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _loadLiveProfile();
  }

  Future<void> _loadLiveProfile() async {
    try {
      final overview = await AccountService.getAccountOverview();
      if (mounted) {
        setState(() {
          if (overview.fullName.isNotEmpty) {
            _nameController.text = overview.fullName;
          }
          if (overview.email.isNotEmpty) {
            _emailController.text = overview.email;
          }
          final fullPhone = '${overview.phoneCountryCode} ${overview.phoneNumber}'.trim();
          if (fullPhone.isNotEmpty) {
            _phoneController.text = fullPhone;
          }
          if (overview.profileImageUrl != null) {
            _uploadedPhotoUrl = overview.profileImageUrl;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        final rawPhone = _phoneController.text.trim();
        String countryCode = '+91';
        String phoneNum = rawPhone;
        if (rawPhone.startsWith('+')) {
          final parts = rawPhone.split(' ');
          if (parts.length > 1) {
            countryCode = parts.first;
            phoneNum = parts.sublist(1).join('');
          }
        }

        // Live API: PATCH /api/account/profile
        await AccountService.updateProfile(
          fullName: _nameController.text.trim(),
          phoneCountryCode: countryCode,
          phoneNumber: phoneNum,
        );

        if (mounted) {
          context.read<AppBloc>().add(
                UpdateUserProfileRequested(
                  fullName: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                ),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile updated successfully',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update: ${e.toString()}'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        // Live API: POST /api/account/profile/photo
        final file = File(picked.path);
        final newUrl = await AccountService.uploadProfilePhoto(file);

        if (mounted) {
          setState(() {
            if (newUrl != null && newUrl.isNotEmpty) {
              _uploadedPhotoUrl = newUrl;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile photo updated successfully',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              backgroundColor: AppColors.primaryBlue,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChangePhotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue),
                  title: Text(
                    'Take Photo',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primaryBlue),
                  title: Text(
                    'Choose from Gallery',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndUploadPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppBloc>().state.user;
    final displayName = user.fullName.isNotEmpty ? user.fullName : 'Dr. Sarah Osei';
    final initialLetter = displayName.trim().split(' ').last.isNotEmpty
        ? displayName.trim().split(' ').last.substring(0, 1).toUpperCase()
        : 'D';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Avatar & Change Photo
                      Center(
                        child: Builder(
                          builder: (context) {
                            final rawPhoto = _uploadedPhotoUrl;
                            final isLocalFile = rawPhoto != null && rawPhoto.isNotEmpty && File(rawPhoto).existsSync();
                            final resolvedUrl = ApiConfig.resolveImageUrl(rawPhoto);

                            ImageProvider? imageProvider;
                            if (isLocalFile) {
                              imageProvider = FileImage(File(rawPhoto));
                            } else if (resolvedUrl != null && resolvedUrl.isNotEmpty) {
                              imageProvider = NetworkImage(resolvedUrl);
                            }

                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 46,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  backgroundImage: imageProvider,
                                  child: imageProvider == null
                                      ? Text(
                                          initialLetter,
                                          style: GoogleFonts.inter(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: _showChangePhotoBottomSheet,
                                  child: Text(
                                    'Change Photo',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name
                      _buildFieldLabel('Full Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Address
                      _buildFieldLabel('Email Address'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!val.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Mobile Number
                      _buildFieldLabel('Mobile Number'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _phoneController,
                        hintText: 'Mobile Number',
                        keyboardType: TextInputType.phone,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Save Changes Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 13.0,
          color: const Color(0xFFB0BAC9),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
