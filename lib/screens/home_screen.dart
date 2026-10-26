import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/app_bloc.dart';
import '../bloc/app_state.dart';
import '../core/date_time_utils.dart';
import '../core/theme.dart';
import '../models/program_model.dart';
import 'notifications/notifications_screen.dart';
import 'programs/program_details_screen.dart';
import 'programs/programs_screen.dart';
import 'programs/submission/submit_program_wizard_screen.dart';
import 'programs/widgets/program_status_pill.dart';
import 'certification/certification_tab_screen.dart';
import 'certification/certification_wizard_screen.dart';
import 'certification/certification_details_screen.dart';
import 'applications/certificate_view_screen.dart';
import 'applications/expired_certificate_details_screen.dart';
import 'applications/renewal/renewal_wizard_screen.dart';
import '../models/certification_model.dart';
import '../models/application_item_model.dart';
import '../models/home_models.dart';
import '../services/api_config.dart';
import '../services/home_service.dart';
import '../services/programs_service.dart';
import 'applications/my_applications_screen.dart';
import 'account/account_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  final int initialAppTabIndex;

  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialAppTabIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentTabIndex;
  late int _appTabIndex;
  DateTime? _lastBackPressTime;
  HomeSummaryResponse? _homeSummary;
  List<ProgramModel> _allPublicPrograms = [];

  // Refresh keys to force re-fetch when switching tabs from bottom navigation
  int _programsRefreshKey = 0;
  int _applicationsRefreshKey = 0;
  int _accountRefreshKey = 0;
  int _idfActiveRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
    _appTabIndex = widget.initialAppTabIndex;
    _fetchHomeData();
  }

  void _switchTab(int index, {int? appTabIndex}) {
    setState(() {
      _currentTabIndex = index;
      if (appTabIndex != null) {
        _appTabIndex = appTabIndex;
      }
      // Trigger instant data re-fetch for the targeted screen
      if (index == 0) {
        _fetchHomeData();
      } else if (index == 1) {
        _programsRefreshKey++;
      } else if (index == 2) {
        _idfActiveRefreshKey++;
        _fetchHomeData();
      } else if (index == 3) {
        _applicationsRefreshKey++;
      } else if (index == 4) {
        _accountRefreshKey++;
      }
    });
  }

  Future<void> _fetchHomeData() async {
    try {
      final summary = await HomeService.getHomeSummary();
      if (mounted) {
        setState(() {
          _homeSummary = summary;
        });
      }
    } catch (_) {}

    try {
      final progRes = await ProgramsService.getPrograms(status: 'all', limit: 10);

      // Fetch user's applications to reliably know which programs the user organized (exact same logic as details screen)
      final myOrganizedIds = <String>{};
      final myOrganizedNos = <String>{};
      final myOrganizedTitles = <String>{};
      try {
        final myApps = await ProgramsService.getMyApplications();
        final items = myApps['items'] is List ? myApps['items'] as List : [];
        for (final it in items) {
          if (it is Map) {
            final idStr = (it['id'] ?? '').toString();
            final pNo = (it['program_no'] ?? it['application_id'] ?? '').toString().trim();
            final titleStr = (it['title'] ?? it['program_name'] ?? '').toString().trim().toLowerCase();
            if (idStr.isNotEmpty) myOrganizedIds.add(idStr);
            if (pNo.isNotEmpty) myOrganizedNos.add(pNo);
            if (titleStr.isNotEmpty) myOrganizedTitles.add(titleStr);
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          // Home screen "Programs" section shows ALL community programs across platform
          // Filter to approved / published public programs only (exclude unapproved user proposals)
          _allPublicPrograms = progRes.items
              .where((p) {
                final rev = (p.reviewStatus ?? '').toLowerCase();
                return rev.isEmpty || rev == 'approved' || rev == 'completed';
              })
              .map((apiItem) {
                final prog = ProgramModel.fromApiItem(apiItem);
                final pId = prog.id.toString();
                final pNo = (prog.programNo ?? '').trim();
                final pTitle = prog.title.trim().toLowerCase();

                final isOrg = prog.isOrganizer ||
                    myOrganizedIds.contains(pId) ||
                    (pNo.isNotEmpty && myOrganizedNos.contains(pNo)) ||
                    (pTitle.isNotEmpty && myOrganizedTitles.contains(pTitle));

                return prog.copyWith(
                  isOrganizer: isOrg,
                  isRegistered: isOrg ? false : prog.isRegistered,
                );
              })
              .toList();
        });
      }
    } catch (_) {}
  }

  void _handlePopScope(bool didPop) {
    if (didPop) return;

    // If not on Home tab, navigate back to Home tab (WhatsApp behavior)
    if (_currentTabIndex != 0) {
      _switchTab(0);
      return;
    }

    // If on Home tab, check double tap to exit (WhatsApp behavior)
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 24, left: 60, right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
      return;
    }

    // Exit app
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _handlePopScope(didPop),
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              bottom: false,
              child: _buildActiveTab(state),
            ),
            bottomNavigationBar: _buildWhatsAppStyleNavigationBar(),
          );
        },
      ),
    );
  }

  Widget _buildActiveTab(AppState state) {
    switch (_currentTabIndex) {
      case 0:
        return _buildHomeDashboardTab(state);
      case 1:
        return ProgramsScreen(
          key: ValueKey('programs_tab_$_programsRefreshKey'),
          isTabMode: true,
        );
      case 2:
        return _buildIDFActiveTab(state);
      case 3:
        return _buildApplicationsTab(state);
      case 4:
        return AccountScreen(
          key: ValueKey('account_tab_$_accountRefreshKey'),
        );
      default:
        return _buildHomeDashboardTab(state);
    }
  }

  // -------------------------------------------------------------
  // WhatsApp Style Bottom Navigation Bar
  // -------------------------------------------------------------
  Widget _buildWhatsAppStyleNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWhatsAppNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildWhatsAppNavItem(
                index: 1,
                icon: Icons.event_note_outlined,
                activeIcon: Icons.event_note_rounded,
                label: 'Programs',
              ),
              _buildWhatsAppNavItem(
                index: 2,
                icon: Icons.star_outline_rounded,
                activeIcon: Icons.star_rounded,
                label: 'IDF Active',
              ),
              _buildWhatsAppNavItem(
                index: 3,
                icon: Icons.description_outlined,
                activeIcon: Icons.description_rounded,
                label: 'Applications',
              ),
              _buildWhatsAppNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentTabIndex == index;
    final activeColor = AppColors.primaryBlue;
    final inactiveColor = const Color(0xFF475569);

    return Expanded(
      child: InkWell(
        onTap: () => _switchTab(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryBlue.withAlpha(20),
        highlightColor: AppColors.primaryBlue.withAlpha(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE0F2FE)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Tab 1: Home Dashboard (Safe from overflows)
  // -------------------------------------------------------------
  Widget _buildHomeDashboardTab(AppState state) {
    final user = state.user;
    final displayName = _homeSummary?.userFullName.isNotEmpty == true
        ? _homeSummary!.userFullName
        : (user.fullName.isNotEmpty ? user.fullName : '');
    final unreadCount = _homeSummary?.unreadNotifications ?? 0;

    return RefreshIndicator(
      onRefresh: _fetchHomeData,
      color: AppColors.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF334155),
                        size: 26,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ).then((_) => _fetchHomeData());
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadCount',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9,
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
          const SizedBox(height: 12),

          // Hero Initiative Banner
          _buildHeroBanner(),
          const SizedBox(height: 20),

          // Quick Actions
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  emoji: '📋',
                  iconBg: const Color(0xFFFEF3C7),
                  title: 'Submit a Program',
                  subtitle: 'Share your PA initiative',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubmitProgramWizardScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  emoji: '🏅',
                  iconBg: const Color(0xFFE0F2FE),
                  title: 'Apply for IDF Active',
                  subtitle: 'Get certified today',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CertificationWizardScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // My Applications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Applications',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _switchTab(3, appTabIndex: 0);
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMyApplicationsCard(state),
          const SizedBox(height: 20),

          // Programs Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Programs',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _switchTab(1);
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgramsCarousel(state),
          const SizedBox(height: 20),

          // IDF Active Certification Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IDF Active Certification',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTabIndex = 2;
                  });
                },
                child: Text(
                  'View',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCertificationCard(user),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

  // -------------------------------------------------------------
  // Hero Banner Widget (Responsive)
  // -------------------------------------------------------------
  Widget _buildHeroBanner() {
    final card = _homeSummary?.idfActivateCard;
    final tag = card != null && card.tag.isNotEmpty
        ? card.tag
        : (card != null && card.badge.isNotEmpty ? card.badge : 'IDF ACTIVATE INITIATIVE');
    final title = card != null && card.title.isNotEmpty
        ? card.title
        : 'Promoting Physical Activity for a Healthier World';
    final desc = card != null && card.description.isNotEmpty
        ? card.description
        : (card != null && card.subtitle.isNotEmpty ? card.subtitle : 'Join the global movement to reduce diabetes through active living.');
    final btnText = card != null && card.buttonText.isNotEmpty
        ? card.buttonText
        : (card != null && card.actionText.isNotEmpty ? card.actionText : 'Learn More');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF006097),
            Color(0xFF017CC2),
            Color(0xFF017CC2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tag.isNotEmpty) ...[
                  Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withAlpha(210),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(225),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                InkWell(
                  onTap: () {
                    final url = card?.actionUrl ?? '';
                    if (url == '/programs' || url.contains('program')) {
                      _switchTab(1);
                    } else {
                      _switchTab(2);
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006097).withAlpha(180),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          btnText,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Quick Action Card (Auto-sized, no fixed overflow height)
  // -------------------------------------------------------------
  Widget _buildQuickActionCard({
    required String emoji,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // My Applications Card
  // -------------------------------------------------------------
  Widget _buildMyApplicationsCard(AppState state) {
    final progCount = _homeSummary?.programApplicationsCount ?? state.programApplicationsCount;
    final certCount = _homeSummary?.certificationApplicationsCount ?? state.certificationApplicationsCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              _switchTab(3, appTabIndex: 0);
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Text('📋', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Program Applications',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$progCount active submissions',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$progCount',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          InkWell(
            onTap: () {
              _switchTab(3, appTabIndex: 1);
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certification Applications',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$certCount active application',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$certCount',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Programs Carousel (Shows All Community Programs, Not My Programs)
  // -------------------------------------------------------------
  Widget _buildProgramsCarousel(AppState state) {
    // Show ALL approved community programs across the IDF platform (strictly public programs, not user's proposals)
    final List<ProgramModel> programsToDisplay = _allPublicPrograms;

    if (programsToDisplay.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.1),
        ),
        child: Column(
          children: [
            const Icon(Icons.event_available_outlined, size: 30, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              'No programs available',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Explore community initiatives across IDF',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: programsToDisplay.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final program = programsToDisplay[index];
          return _buildProgramCard(program: program);
        },
      ),
    );
  }

  Widget _buildProgramCard({required ProgramModel program}) {
    final colors = program.gradientColors.isNotEmpty
        ? program.gradientColors.map((c) => Color(c)).toList()
        : [const Color(0xFF006097), const Color(0xFF017CC2)];

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1.1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProgramDetailsScreen(program: program),
              ),
            ).then((_) => _fetchHomeData());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (ApiConfig.resolveImageUrl(program.imageUrl) != null)
                      Image.network(
                        ApiConfig.resolveImageUrl(program.imageUrl)!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 40,
                            color: Colors.white.withAlpha(160),
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 40,
                          color: Colors.white.withAlpha(160),
                        ),
                      ),
                    // Top-right status pill (Organizer / Registered if joined / Event timeline status)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: program.isOrganizer
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(40),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Organizer',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ((program.isRegistered && !program.isOrganizer)
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(40),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Registered',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ProgramStatusPill(status: program.status)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.category ?? program.tag,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      program.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            DateTimeUtils.formatDateRange(program.startDate, program.endDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            program.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // IDF Active Certification Card
  // -------------------------------------------------------------
  Widget _buildCertificationCard(UserModel user) {
    final cert = _homeSummary?.certification;

    if (cert == null) {
      return InkWell(
        onTap: () {
          setState(() {
            _currentTabIndex = 2; // Switch to IDF Active tab
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🏅', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IDF Active Certification',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Get your institution accredited today',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Apply Now',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final instName = cert.institutionName?.isNotEmpty == true
        ? cert.institutionName!
        : user.organizationName;
    final catName = cert.category?.isNotEmpty == true
        ? cert.category!
        : user.organizationType;
    final appNo = cert.applicationNo ?? (cert.applicationId != null ? 'APP-CERT-2026-${cert.applicationId!.toString().padLeft(4, '0')}' : '');
    final rawStatus = cert.displayStatus ?? 'Submitted';

    final item = CertificateApplicationItem(
      id: cert.applicationId?.toString() ?? '',
      institutionName: instName,
      institutionType: catName,
      certificateId: cert.certificateId != null ? cert.certificateId.toString() : '',
      applicationNo: appNo,
      issuedDate: '',
      expiresDate: cert.expiresOn ?? '',
      status: rawStatus,
      reviewStatus: rawStatus,
      displayStatus: rawStatus,
      score: '',
    );

    final isExpired = item.isExpiredOrRenewable;
    final isChangesRequired = item.status.toLowerCase() == 'changes required' ||
        item.status.toLowerCase() == 'changes_required';
    final isApproved = item.isApproved && item.certificateId.isNotEmpty;

    void openCert() {
      if (isExpired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RenewalWizardScreen(certificate: item),
          ),
        );
      } else if (isApproved) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificateViewScreen(certificate: item),
          ),
        );
      } else if (isChangesRequired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificationWizardScreen(
              applicationId: item.id.isNotEmpty ? item.id : item.applicationNo,
              initialModel:
                  CertificationApplicationModel.prefilledForCertificate(item),
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificationDetailsScreen(
              applicationId: item.id.isNotEmpty ? item.id : item.applicationNo,
              certificateItem: item,
            ),
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: openCert,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🏅', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.institutionName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildCertBadge(item.displayReviewStatus),
                        ],
                      ),
                      Text(
                        item.institutionType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isApproved
                            ? 'Certificate No: ${item.certificateId}'
                            : 'Application No: ${item.applicationNo.isNotEmpty ? item.applicationNo : (item.id.isNotEmpty ? item.id : 'APP-CERT-2026-0001')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isExpired
                                    ? 'Renew Certificate'
                                    : isChangesRequired
                                        ? 'Edit Application'
                                        : isApproved
                                            ? 'View Certificate'
                                            : 'View Details',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isChangesRequired
                                      ? const Color(0xFFDC2626)
                                      : isExpired
                                          ? const Color(0xFFEA580C)
                                          : AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: isChangesRequired
                                    ? const Color(0xFFDC2626)
                                    : isExpired
                                        ? const Color(0xFFEA580C)
                                        : AppColors.primaryBlue,
                              ),
                            ],
                          ),
                          if (isExpired || isChangesRequired || isApproved)
                            InkWell(
                              onTap: () {
                                if (isExpired) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ExpiredCertificateDetailsScreen(certificate: item),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CertificationDetailsScreen(
                                        applicationId: item.id.isNotEmpty ? item.id : item.applicationNo,
                                        certificateItem: item,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  isExpired ? 'View Details' : 'Auditor Notes',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);
    Color border = const Color(0xFFE2E8F0);

    final s = status.trim().toLowerCase();
    if (s == 'active' || s == 'approved' || s == 'completed' || s == 'certified') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      border = const Color(0xFF86EFAC);
    } else if (s.contains('manual') ||
        s.contains('review') ||
        s == 'pending' ||
        s == 'under_review' ||
        s == 'submitted' ||
        s == 'ai_audit') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
      border = const Color(0xFFFDE68A);
    } else if (s.contains('changes') || s == 'changes required') {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
      border = const Color(0xFFFDBA74);
    } else if (s == 'expired' || s == 'rejected' || s == 'cancelled') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      border = const Color(0xFFFCA5A5);
    }

    final displayLabel = (s == 'submitted' || s == 'ai_audit' || s == 'under_review' || s == 'manual_review')
        ? 'Manual Review'
        : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        displayLabel,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }


  // -------------------------------------------------------------
  // IDF Active Tab
  // -------------------------------------------------------------
  Widget _buildIDFActiveTab(AppState state) {
    return CertificationTabScreen(
      key: ValueKey('idf_active_$_idfActiveRefreshKey'),
      onRefresh: _fetchHomeData,
    );
  }

  // -------------------------------------------------------------
  // Applications Tab
  // -------------------------------------------------------------
  Widget _buildApplicationsTab(AppState state) {
    return MyApplicationsScreen(
      key: ValueKey('my_apps_${_appTabIndex}_$_applicationsRefreshKey'),
      initialTabIndex: _appTabIndex,
    );
  }
}
