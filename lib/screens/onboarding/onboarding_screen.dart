
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../welcome_screen.dart';
import '../signup/signup_step1_account.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isAuthenticated;
  const OnboardingScreen({super.key, this.isAuthenticated = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding({bool toRegister = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
    } catch (_) {}

    if (!mounted) return;

    if (toRegister) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpStep1Screen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back button, Page tracker, Skip/Register button
            _buildTopBar(),

            // Page View with 5 slides
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildSlide1Hero(),
                  _buildSlide2About(),
                  _buildSlide3Principles(),
                  _buildSlide4Programmes(),
                  _buildSlide5Certification(),
                ],
              ),
            ),

            // Bottom Navigation: Indicator Dots & Action Buttons
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button on slides 2..5
          _currentPage > 0
              ? InkWell(
                  onTap: _prevPage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: Color(0xFF334155),
                    ),
                  ),
                )
              : const SizedBox(width: 36, height: 36),

          // Slide indicator chip (e.g. 1 of 5)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentPage + 1} of $_totalPages',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
          ),

          // Balanced spacer replacing top register button
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 1: HERO / BANNER (FULL SCREEN IMAGE)
  // ==========================================
  Widget _buildSlide1Hero() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/onboarding_hero.jpg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/activate_banner.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ==========================================
  // SLIDE 2: ABOUT THE INITIATIVE & TARGET AUDIENCE
  // ==========================================
  Widget _buildSlide2About() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22.0, 10.0, 22.0, 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Tag
          _buildSectionTag('ABOUT THE INITIATIVE'),
          const SizedBox(height: 10),

          // Title
          Text(
            'The global voice of the diabetes community, in motion',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            'The International Diabetes Federation (IDF) champions access to affordable, quality diabetes care and education worldwide. Through ACTIVATE, the IDF Physical Activity Working Group prioritises real-world, community-focused programs that create measurable improvements in physical activity levels across the world.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 22),

          // Subheader
          Text(
            'Who ACTIVATE is for',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // 4 Target Audience Cards
          _buildAudienceCard(
            icon: Icons.medical_services_outlined,
            iconColor: const Color(0xFF0284C7),
            bgColor: const Color(0xFFF0F9FF),
            title: 'Healthcare Professionals',
            subtitle: 'Medical practitioners and allied health care professionals.',
          ),
          const SizedBox(height: 8),
          _buildAudienceCard(
            icon: Icons.people_alt_outlined,
            iconColor: const Color(0xFF16A34A),
            bgColor: const Color(0xFFF0FDF4),
            title: 'Patients & Public',
            subtitle: 'Individuals affected by diabetes and the general population.',
          ),
          const SizedBox(height: 8),
          _buildAudienceCard(
            icon: Icons.domain_rounded,
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            title: 'Country-Specific Organisations',
            subtitle: 'Groups working in diabetes, physical activity, active transport and lifestyle medicine.',
          ),
          const SizedBox(height: 8),
          _buildAudienceCard(
            icon: Icons.policy_rounded,
            iconColor: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFF5F3FF),
            title: 'Policy Makers',
            subtitle: 'Local and national policy makers across sectors (multisectoral).',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAudienceCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 3: FOUR PILLARS - THE ACTIVATE PRINCIPLES
  // ==========================================
  Widget _buildSlide3Principles() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTag('FOUR PILLARS'),
          const SizedBox(height: 8),

          Text(
            'The ACTIVATE principles',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Four coordinated principles turn evidence and policy into movement on the ground.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          // 4 Pillars Cards
          _buildPillarCard(
            number: '01',
            numberColor: const Color(0xFF0284C7),
            title: 'Digital Hub',
            desc: 'A web-based platform hosting country-specific physical activity programs and leveraging digital media to promote movement worldwide.',
          ),
          const SizedBox(height: 10),
          _buildPillarCard(
            number: '02',
            numberColor: const Color(0xFF2563EB),
            title: 'Physical Activity Programs',
            desc: 'A bouquet of evidence-driven PA programs with a special focus on applicability in low- and middle-income countries (LMICs).',
          ),
          const SizedBox(height: 10),
          _buildPillarCard(
            number: '03',
            numberColor: const Color(0xFFD97706),
            title: 'IDF Certifications',
            desc: 'A scoring system recognising workplaces, community organisations, schools, colleges, universities and health facilities as \'IDF ACTIVE\'.',
          ),
          const SizedBox(height: 10),
          _buildPillarCard(
            number: '04',
            numberColor: const Color(0xFFEA580C),
            title: 'Training & Capacity Building',
            desc: 'Building a cadre of researchers and activists to advocate for and implement PA programs in their practice areas and settings.',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPillarCard({
    required String number,
    required Color numberColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: numberColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: numberColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 4: PROGRAMMES & WHO GAPPA ALIGNMENT
  // ==========================================
  Widget _buildSlide4Programmes() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTag('DIGITAL HUB · PROGRAMMES'),
          const SizedBox(height: 8),

          Text(
            'Shortlisted physical activity programmes',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'A curated library of evidence-informed programmes, each mapped to the WHO GAPPA strategic pillars and ready to adapt — with a special focus on low- and middle-income countries.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          // Alignment with WHO GAPPA Banner Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_outlined, color: Color(0xFF16A34A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALIGNMENT | WHO GAPPA',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Built on the WHO GAPPA strategic pillars (2018–2030)',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4 GAPPA Strategic Pillars Cards
          _buildGappaPillarCard(
            icon: Icons.groups_rounded,
            title: 'Active Societies',
            desc: 'Creating positive social norms and a paradigm shift that values physical activity for all ages and abilities.',
          ),
          const SizedBox(height: 8),
          _buildGappaPillarCard(
            icon: Icons.park_outlined,
            title: 'Active Environments',
            desc: 'Designing infrastructure and safe spaces — walking/cycling networks, parks — that facilitate active transport and recreation.',
          ),
          const SizedBox(height: 8),
          _buildGappaPillarCard(
            icon: Icons.fitness_center_rounded,
            title: 'Active People',
            desc: 'Increasing the provision of opportunities for sport, play and structured physical activity, so people move regularly.',
          ),
          const SizedBox(height: 8),
          _buildGappaPillarCard(
            icon: Icons.account_tree_outlined,
            title: 'Active Systems',
            desc: 'Strengthening governance, leadership, partnerships, and workforce capabilities to implement initiatives nationally and locally.',
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGappaPillarCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 5: IDF ACTIVE CERTIFICATION
  // ==========================================
  Widget _buildSlide5Certification() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTag('CERTIFICATION'),
          const SizedBox(height: 8),

          Text(
            'Get recognised as an IDF ACTIVE institution',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Any institution promoting physical activity within its premises can apply for \'IDF ACTIVE\' Certification, valid for two years. Applicants commit to creating an environment that encourages regular physical activity among their members, staff or students.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          // 3 Metric Highlights
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF0284C7),
                  title: 'Valid for 2 yrs',
                  desc: 'Renewable every 2 years',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.percent_rounded,
                  color: const Color(0xFF16A34A),
                  title: '50% Pass',
                  desc: 'To qualify for status',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  icon: Icons.category_outlined,
                  color: const Color(0xFF7C3AED),
                  title: '5 Categories',
                  desc: 'Tailored benchmarks',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Who can apply container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who can apply?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                _buildApplicantRow('Workplaces / worksites / offices / hospitals'),
                _buildApplicantRow('Community organisations and NGOs'),
                _buildApplicantRow('Schools'),
                _buildApplicantRow('Colleges and universities'),
                _buildApplicantRow('Smaller healthcare facilities / clinics'),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlue,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // ==========================================
  // BOTTOM BAR: INDICATORS & BUTTONS
  // ==========================================
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              final isCurrent = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isCurrent ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isCurrent ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Every slide has a direct button to Register/Welcome, plus Next
          Row(
            children: [
              // Direct Button to Welcome / Register
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _completeOnboarding(toRegister: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Register Now',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Next / Get Started Primary Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _currentPage == _totalPages - 1
                        ? () => _completeOnboarding(toRegister: false)
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
