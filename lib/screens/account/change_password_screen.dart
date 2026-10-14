import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final currentPass = _currentPassController.text.trim();
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (currentPass.isEmpty) {
      _showToast('Please enter your current password', isError: true);
      return;
    }

    if (newPass.isEmpty) {
      _showToast('Please enter your new password', isError: true);
      return;
    }

    if (newPass.length < 8) {
      _showToast('New password must be at least 8 characters long', isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showToast('New passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.changePassword(
        currentPassword: currentPass,
        newPassword: newPass,
        confirmPassword: confirmPass,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showToast('Password updated successfully!', isError: false);
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast(e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showToast('Failed to update password. Please check your credentials.', isError: true);
      }
    }
  }

  void _showToast(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: isError ? Colors.redAccent : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Change Password',
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Secure Your Account',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Ensure your new password has a minimum of 8 characters with a mix of letters and numbers.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      color: const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 1. Current Password
                      _buildFieldLabel('Current Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _currentPassController,
                        hintText: 'Enter your current password',
                        isObscured: _obscureCurrent,
                        prefixIcon: Icons.lock_outline_rounded,
                        onToggleVisibility: () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                      ),
                      const SizedBox(height: 22),

                      // 2. New Password
                      _buildFieldLabel('New Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _newPassController,
                        hintText: 'Enter new password (min. 8 characters)',
                        isObscured: _obscureNew,
                        prefixIcon: Icons.key_rounded,
                        onToggleVisibility: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                      ),
                      const SizedBox(height: 8),

                      // Hint indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Minimum 8 characters',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 3. Confirm New Password
                      _buildFieldLabel('Confirm New Password'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _confirmPassController,
                        hintText: 'Re-enter your new password',
                        isObscured: _obscureConfirm,
                        prefixIcon: Icons.verified_user_outlined,
                        onToggleVisibility: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Update Password Button at the bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_reset_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Update Password',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscured,
    required IconData prefixIcon,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscured,
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
        prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF64748B)),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: isObscured ? const Color(0xFF94A3B8) : AppColors.primaryBlue,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
