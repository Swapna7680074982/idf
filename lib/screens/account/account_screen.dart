import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../bloc/app_state.dart';
import '../../core/theme.dart';
import '../welcome_screen.dart';
import 'change_password_screen.dart';
import 'contact_support_screen.dart';
import 'edit_profile_screen.dart';
import 'organization_details_screen.dart';

import '../../services/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/metadata_service.dart';
import '../../models/account_models.dart';
import '../../services/account_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  AccountOverviewResponse? _accountOverview;

  @override
  void initState() {
    super.initState();
    _loadAccountOverview();
  }

  Future<void> _loadAccountOverview() async {
    try {
      final overview = await AccountService.getAccountOverview();
      if (mounted) {
        setState(() {
          _accountOverview = overview;
        });

        if (overview.organization != null) {
          final org = overview.organization!;
          context.read<AppBloc>().add(
            UpdateUserProfileRequested(
              fullName: overview.fullName.isNotEmpty ? overview.fullName : null,
              organizationName: org.name.isNotEmpty ? org.name : null,
              organizationType: org.organizationType.isNotEmpty ? org.organizationType : null,
              country: (org.country != null && org.country!.isNotEmpty) ? org.country! : null,
              state: org.region?.isNotEmpty == true ? org.region! : null,
              city: org.city?.isNotEmpty == true ? org.city! : null,
              address: org.address?.isNotEmpty == true ? org.address! : null,
              contactEmail: org.contactEmail?.isNotEmpty == true ? org.contactEmail! : null,
              contactPhone: org.contactPhone?.isNotEmpty == true ? org.contactPhone! : null,
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _showLogoutDialog(BuildContext context) {
    bool logoutAll = false;
    bool isLoggingOut = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Badge
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFDC2626),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Log Out',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Are you sure you want to log out of your IDF account?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    height: 1.4,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout All Devices Checkbox
                InkWell(
                  onTap: () {
                    setDialogState(() => logoutAll = !logoutAll);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: logoutAll,
                            activeColor: const Color(0xFFDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setDialogState(() => logoutAll = val ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log out from all devices',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Action Buttons SIDE BY SIDE in a Row
                Row(
                  children: [
                    // 1. Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: isLoggingOut ? null : () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 2. Log Out Button (Side by side!)
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isLoggingOut
                              ? null
                              : () async {
                                  setDialogState(() => isLoggingOut = true);
                                  try {
                                    if (logoutAll) {
                                      await AuthService.logoutAll();
                                    } else {
                                      await AuthService.logout();
                                    }
                                  } catch (_) {}

                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    context.read<AppBloc>().add(LogoutRequested());
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                      (route) => false,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoggingOut
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Log Out',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
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
        final displayName = _accountOverview?.fullName.isNotEmpty == true
            ? _accountOverview!.fullName
            : user.fullName;
        final displayEmail = _accountOverview?.email.isNotEmpty == true
            ? _accountOverview!.email
            : user.email;
        final displayOrg = _accountOverview?.organization?.name.isNotEmpty == true
            ? _accountOverview!.organization!.name
            : user.organizationName;
        final avatarUrl = ApiConfig.resolveImageUrl(_accountOverview?.profileImageUrl);
        final initialLetter = displayName.trim().isNotEmpty
            ? displayName.trim().substring(0, 1).toUpperCase()
            : 'U';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: RefreshIndicator(
            onRefresh: _loadAccountOverview,
            color: AppColors.primaryBlue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                            // Circular avatar with image or initial
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
                              clipBehavior: Clip.antiAlias,
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) => Center(
                                        child: Text(
                                          initialLetter,
                                          style: GoogleFonts.inter(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
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
                            ).then((_) => _loadAccountOverview());
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
                            ).then((_) => _loadAccountOverview());
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
                          title: 'Change Password',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
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
                        onTap: () async {
                          String privacyContent =
                              'Your privacy and data security are our highest priorities. All organizational, patient, and program records are processed in compliance with global health data standards (GDPR, HIPAA, and IDF data protocols).\n\nIDF Active only shares verified certification details with authorized educational and governmental entities.';
                          try {
                            final docs = await MetadataService.getLegalDocuments();
                            final privacy = docs.firstWhere(
                              (d) => d.docType == 'privacy_policy',
                              orElse: () => docs.last,
                            );
                            if (privacy.content.isNotEmpty) {
                              privacyContent = privacy.content;
                            }
                          } catch (_) {}

                          if (context.mounted) {
                            _showInfoModal(
                              context,
                              title: 'Privacy Policy',
                              content: privacyContent,
                            );
                          }
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
                        onTap: () async {
                          String termsContent =
                              'By registering for the IDF Digital Hub, you agree to use this platform solely for legitimate physical activity program submissions and IDF ACTIVE certification applications...';
                          try {
                            final docs = await MetadataService.getLegalDocuments();
                            final terms = docs.firstWhere(
                              (d) => d.docType == 'terms_of_service',
                              orElse: () => docs.first,
                            );
                            if (terms.content.isNotEmpty) {
                              termsContent = terms.content;
                            }
                          } catch (_) {}

                          if (context.mounted) {
                            _showInfoModal(
                              context,
                              title: 'Terms of Service',
                              content: termsContent,
                            );
                          }
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
