import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/date_time_utils.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/certification_model.dart';
import '../certification/certification_details_screen.dart';
import '../certification/certification_wizard_screen.dart';
import 'certificate_view_screen.dart';
import 'expired_certificate_details_screen.dart';
import 'program_application_details_screen.dart';
import '../../services/programs_service.dart';
import '../../services/certification_service.dart';

class MyApplicationsScreen extends StatefulWidget {
  final int initialTabIndex; // 0: Programs, 1: Certificates

  const MyApplicationsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late int _selectedTab; // 0: Programs, 1: Certificates

  // Program filters & search
  final TextEditingController _programSearchController = TextEditingController();
  String _programQuery = '';
  String _selectedProgramFilter = 'All';
  final List<String> _programFilters = [
    'All',
    'Submitted',
    'In Review',
    'Approved',
    'Changes Required',
    'Rejected',
    'Completed',
  ];

  // Certificate filters & search
  final TextEditingController _certSearchController = TextEditingController();
  String _certQuery = '';
  String _selectedCertFilter = 'All';
  final List<String> _certFilters = [
    'All',
    'Submitted',
    'Active',
    'Expired',
  ];

  List<ProgramApplicationItem> _programs = [];
  List<CertificateApplicationItem> _certificates = [];
  bool _isLoadingPrograms = false;
  bool _isLoadingCertificates = false;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
    _fetchMyProgramApplications();
    _fetchMyCertificateApplications();
  }

  Future<void> _fetchMyCertificateApplications() async {
    setState(() {
      _isLoadingCertificates = true;
    });

    try {
      final certs = await CertificationService.getMyCertificateApplications();
      if (mounted) {
        final items = certs
            .map((c) => CertificateApplicationItem.fromJson(c))
            .toList();
        items.sort((a, b) {
          final idA = int.tryParse(a.id) ?? 0;
          final idB = int.tryParse(b.id) ?? 0;
          return idB.compareTo(idA);
        });
        setState(() {
          _certificates = items;
          _isLoadingCertificates = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCertificates = false;
        });
      }
    }
  }

  Future<void> _fetchMyProgramApplications() async {
    setState(() {
      _isLoadingPrograms = true;
    });

    try {
      final List<ProgramApplicationItem> fetchedList = [];

      // Fetch exclusively from /api/applications/programs?status=all&page=1&limit=20
      try {
        final res = await ProgramsService.getMyApplications(status: 'all', page: 1, limit: 20);
        final items = res['items'] is List ? res['items'] as List : [];
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            fetchedList.add(ProgramApplicationItem.fromJson(item));
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _programs = fetchedList;
          _isLoadingPrograms = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingPrograms = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _programSearchController.dispose();
    _certSearchController.dispose();
    super.dispose();
  }

  List<ProgramApplicationItem> get _filteredPrograms {
    return _programs.where((item) {
      if (_programQuery.isNotEmpty) {
        final q = _programQuery.toLowerCase();
        final matchesTitle = item.programName.toLowerCase().contains(q);
        final matchesRef = item.referenceNumber.toLowerCase().contains(q);
        final matchesLoc = item.location.toLowerCase().contains(q);
        if (!matchesTitle && !matchesRef && !matchesLoc) return false;
      }
      if (_selectedProgramFilter != 'All') {
        if (item.status.toLowerCase() != _selectedProgramFilter.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<CertificateApplicationItem> get _filteredCertificates {
    return _certificates.where((item) {
      if (_certQuery.isNotEmpty) {
        final q = _certQuery.toLowerCase();
        final matchesName = item.institutionName.toLowerCase().contains(q);
        final matchesId = item.certificateId.toLowerCase().contains(q);
        if (!matchesName && !matchesId) return false;
      }
      if (_selectedCertFilter != 'All') {
        final filter = _selectedCertFilter.toLowerCase();
        final stat = item.status.toLowerCase();
        final rev = item.reviewStatus.toLowerCase();
        final disp = item.displayReviewStatus.toLowerCase();
        if (filter == 'submitted') {
          final isSub = stat == 'submitted' ||
              stat == 'under_review' ||
              rev == 'manual_review' ||
              rev == 'ai_audit' ||
              disp.contains('review') ||
              disp.contains('submitted');
          if (!isSub) return false;
        } else if (stat != filter && rev != filter && disp != filter) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 18, 10),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    'My Applications',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs: PROGRAMS | CERTIFICATES
            _buildTabSelector(),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildFilterChips(),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: _selectedTab == 0
                  ? _buildProgramsList()
                  : _buildCertificatesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(title: 'PROGRAMS', index: 0),
          ),
          Expanded(
            child: _buildTabItem(title: 'CERTIFICATES', index: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    final isSelected = _selectedTab == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              width: 2.2,
            ),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isPrograms = _selectedTab == 0;
    final hint = isPrograms ? 'Search Programs' : 'Search Certificates';
    final controller = isPrograms ? _programSearchController : _certSearchController;

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        onChanged: (val) {
          setState(() {
            if (isPrograms) {
              _programQuery = val;
            } else {
              _certQuery = val;
            }
          });
        },
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFB0BAC9)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFFB0BAC9)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () {
                    controller.clear();
                    setState(() {
                      if (isPrograms) {
                        _programQuery = '';
                      } else {
                        _certQuery = '';
                      }
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final isPrograms = _selectedTab == 0;
    final filters = isPrograms ? _programFilters : _certFilters;
    final selected = isPrograms ? _selectedProgramFilter : _selectedCertFilter;

    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: filters.map((f) {
          final isSelected = selected == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (isPrograms) {
                    _selectedProgramFilter = f;
                  } else {
                    _selectedCertFilter = f;
                  }
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
  }

  // 1. Programs Tab List (Screen 36)
  Widget _buildProgramsList() {
    if (_isLoadingPrograms) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    final items = _filteredPrograms;

    return RefreshIndicator(
      onRefresh: _fetchMyProgramApplications,
      color: AppColors.primaryBlue,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            size: 28,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No program applications found',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Submit a program proposal to track its review and approval status here.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildProgramCard(item);
              },
            ),
    );
  }

  Widget _buildProgramCard(ProgramApplicationItem item) {
    void openDetails() async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProgramApplicationDetailsScreen(item: item),
        ),
      );
      _fetchMyProgramApplications();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: openDetails,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Document icon, Title & Status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClipboardIcon(),
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
                                  item.programName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildProgramBadge(item.status),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.category} · ${item.referenceNumber}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Submitted: ${DateTimeUtils.formatDateTime(item.submittedDate)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          if (item.lastUpdatedDate.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Last Updated: ${DateTimeUtils.formatDateTime(item.lastUpdatedDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF16A34A)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'AI Validation Done',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Application',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClipboardIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F1F8),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('📋', style: TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _buildProgramBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF475569);
    Color border = const Color(0xFFE2E8F0);

    final s = status.trim().toLowerCase();
    if (s == 'approved' || s == 'complete' || s == 'completed') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      border = const Color(0xFF86EFAC);
    } else if (s == 'in review' || s == 'under review' || s == 'manual_review' || s == 'pending') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
      border = const Color(0xFFFDE68A);
    } else if (s == 'submitted') {
      bg = const Color(0xFFE0F2FE);
      text = const Color(0xFF0284C7);
      border = const Color(0xFFBAE6FD);
    } else if (s.contains('changes') || s == 'changes_required' || s == 'changes required') {
      bg = const Color(0xFFFFEDD5);
      text = const Color(0xFFC2410C);
      border = const Color(0xFFFDBA74);
    } else if (s == 'rejected' || s == 'cancelled' || s == 'canceled') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFDC2626);
      border = const Color(0xFFFCA5A5);
    }

    final displayLabel = (s == 'manual_review' || s == 'in_review')
        ? 'In Review'
        : (s == 'changes_required' ? 'Changes Required' : status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
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

  // 2. Certificates Tab List (Screen 38)
  Widget _buildCertificatesList() {
    if (_isLoadingCertificates && _certificates.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }

    final items = _filteredCertificates;

    return RefreshIndicator(
      onRefresh: _fetchMyCertificateApplications,
      color: AppColors.primaryBlue,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                Center(
                  child: Text(
                    'No certificates found.',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildCertificateCard(item);
              },
            ),
    );
  }

  Widget _buildCertificateCard(CertificateApplicationItem item) {
    final isExpired = item.status.toLowerCase() == 'expired';
    final isChangesRequired = item.status.toLowerCase() == 'changes required' ||
        item.status.toLowerCase() == 'changes_required';
    final isApproved = item.isApproved && item.certificateId.isNotEmpty;

    void openCert() {
      if (isApproved) {
        // Only if approved/certified with an issued certificate, show CertificateViewScreen!
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CertificateViewScreen(certificate: item),
          ),
        );
      } else if (isExpired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpiredCertificateDetailsScreen(certificate: item),
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
        // Submitted, In Review, AI Audit, etc. -> Show Application Details / Tracking screen!
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

    void openDetailsRedirect() {
      if (isExpired) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpiredCertificateDetailsScreen(certificate: item),
          ),
        );
      } else {
        // For Approved (Auditor Notes), Changes Required (Auditor Notes), or Under Review
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
      margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                                    : 'Application No: ${item.applicationNo.isNotEmpty ? item.applicationNo : item.id}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              if (item.issuedDate.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Issued: ${DateTimeUtils.formatDateTime(item.issuedDate)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                              if (item.expiresDate.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Expires: ${DateTimeUtils.formatDateTime(item.expiresDate)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
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
                                              : AppColors.primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 13,
                                        color: isChangesRequired
                                            ? const Color(0xFFDC2626)
                                            : AppColors.primaryBlue,
                                      ),
                                    ],
                                  ),
                                  if (isExpired || isChangesRequired || isApproved)
                                    InkWell(
                                      onTap: openDetailsRedirect,
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
}
