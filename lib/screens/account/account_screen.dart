import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../bloc/app_state.dart';
import '../../core/theme.dart';
import '../reset_password_screens.dart';
import '../welcome_screen.dart';
import 'contact_support_screen.dart';
import 'edit_profile_screen.dart';
import 'organization_details_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your IDF account?',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final user = state.user;
        final displayName = user.fullName.isNotEmpty ? user.fullName : 'Dr. Sarah Osei';
        final displayEmail = user.email.isNotEmpty ? user.email : '123@xyz.com';
        final displayOrg = user.organizationName.isNotEmpty ? user.organizationName : 'Lagos State University';
        final initialLetter = displayName.trim().split(' ').last.isNotEmpty
            ? displayName.trim().split(' ').last.substring(0, 1).toUpperCase()
            : 'D';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Banner (Screen 46)
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF006097),
                        Color(0xFF017CC2),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Circular avatar with initial
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(50),
                              border: Border.all(
                                color: Colors.white.withAlpha(100),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initialLetter,
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  displayEmail,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withAlpha(220),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayOrg,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withAlpha(200),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content List
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: PROFILE & ORGANIZATION / INSTITUTION
                      _buildSectionHeader('PROFILE & ORGANIZATION / INSTITUTION'),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.person,
                          color: Color(0xFF0284C7),
                          size: 20,
                        ),
                        title: 'Personal Information',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.apartment_rounded,
                          color: Color(0xFF475569),
                          size: 20,
                        ),
                        title: 'Organization Details',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrganizationDetailsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section 2: SETTINGS
                      _buildSectionHeader('SETTINGS'),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                        title: 'Password / Security',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ResetPasswordStep1Screen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.shield_rounded,
                          color: Color(0xFFEA580C),
                          size: 20,
                        ),
                        title: 'Privacy',
                        onTap: () {
                          _showInfoModal(
                            context,
                            title: 'Privacy Policy',
                            content:
                                'Your privacy and data security are our highest priorities. All organizational, patient, and program records are processed in compliance with global health data standards (GDPR, HIPAA, and IDF data protocols).\n\nIDF Active only shares verified certification details with authorized educational and governmental entities.',
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        title: 'Terms of Service',
                        onTap: () {
                          _showInfoModal(
                            context,
                            title: 'Terms of Service',
                            content:
                                'By using the IDF platform, you agree to adhere to clinical guidelines, truthful accreditation reporting, and institutional ethics. Any misrepresentation in certification or program submissions may result in immediate suspension of certified status.',
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section 3: SUPPORT
                      _buildSectionHeader('SUPPORT'),
                      const SizedBox(height: 8),
                      _buildMenuItem(
                        iconWidget: const Icon(
                          Icons.phone_in_talk_rounded,
                          color: Color(0xFF334155),
                          size: 20,
                        ),
                        title: 'Contact Support',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ContactSupportScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Log Out Button (Red pill/rounded container)
                      InkWell(
                        onTap: () => _showLogoutDialog(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFECACA),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget iconWidget,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              iconWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
