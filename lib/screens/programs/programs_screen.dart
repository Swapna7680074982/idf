import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/application_item_model.dart';
import '../../models/program_api_models.dart';
import '../../models/program_model.dart';
import '../../services/api_config.dart';
import '../../services/programs_service.dart';
import '../applications/program_application_details_screen.dart';
import 'program_details_screen.dart';
import 'submission/submit_program_wizard_screen.dart';
import 'widgets/program_card.dart';
import '../../models/meta_models.dart';
import '../../services/metadata_service.dart';

class ProgramsScreen extends StatefulWidget {
  final bool isTabMode;

  const ProgramsScreen({
    super.key,
    this.isTabMode = true,
  });

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // 0: All Programs (Only approved/published), 1: My Programs (Submitted & Registered)
  int _selectedTab = 0;

  String _searchQuery = '';
  String _selectedFilter = 'All';
  ProgramTypeItem? _selectedProgramType;
  List<ProgramTypeItem> _programTypes = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Tab 0: Public approved programs
  List<ProgramModel> _allApprovedPrograms = [];
  // Tab 1: User's registered & submitted programs
  List<ProgramModel> _myPrograms = [];

  @override
  void initState() {
    super.initState();
    _fetchProgramTypes();
    _fetchPrograms();
  }

  Future<void> _fetchProgramTypes() async {
    try {
      final types = await MetadataService.getProgramTypes();
      if (mounted) {
        setState(() {
          _programTypes = types;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrograms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<ProgramModel> approvedList = [];
      final Set<String> approvedSeen = {};

      final List<ProgramModel> myList = [];
      final Set<String> mySeen = {};

      // 1. Fetch from /api/programs (Public Approved & Published)
      try {
        final res = await ProgramsService.getPrograms(
          search: _searchQuery.isNotEmpty ? _searchQuery : null,
          typeId: _selectedProgramType?.id,
        );
        for (final item in res.items) {
          final prog = ProgramModel.fromApiItem(item);
          final revStatus = (prog.reviewStatus ?? '').toLowerCase();
          // ONLY APPROVED programs belong in All Programs
          final isUnapproved = revStatus == 'submitted' || revStatus == 'draft' || revStatus == 'in_review';
          if (!isUnapproved) {
            if (approvedSeen.add(prog.id)) {
              approvedList.add(prog);
            }
          }
        }
      } catch (_) {}

      // 2. Fetch from /api/programs/registered (User's registered & user-created programs)
      ProgramsResponse? regRes;
      try {
        regRes = await ProgramsService.getRegisteredPrograms();
      } catch (_) {}

      // 3. Fetch from /api/applications/programs (User's program applications for My Programs tab)
      List hydratedItems = [];
      try {
        final appRes = await ProgramsService.getMyApplications();
        final rawItems = appRes['items'] is List ? appRes['items'] as List : [];

        // Hydrate applications in parallel so image banner, dates, city/country are fully populated
        hydratedItems = await Future.wait(
          rawItems.map((item) async {
            if (item is! Map<String, dynamic>) return item;
            final idStr = (item['id'] ?? '').toString();
            final matchingReg = regRes?.items.where((r) => r.id.toString() == idStr).firstOrNull;
            final matchingApp = approvedList.where((p) => p.id == idStr || (item['program_no'] != null && p.programNo == item['program_no'].toString())).firstOrNull;

            var bannerUrl = ApiConfig.extractBannerUrl(item);
            var startDate = item['start_date'];
            var endDate = item['end_date'];
            var city = item['city_text'] ?? item['city'];
            var country = item['country_text'] ?? item['country'];
            var organizer = item['organizer'] ?? item['organizer_name'];
            var venue = item['venue'];
            var description = item['description'] ?? item['about'];

            if (matchingReg != null) {
              bannerUrl ??= matchingReg.bannerImageUrl ?? matchingReg.coverImageUrl;
              startDate ??= matchingReg.startDate;
              endDate ??= matchingReg.endDate;
              city ??= matchingReg.cityText;
              country ??= matchingReg.countryText;
              organizer ??= matchingReg.organizerName;
            }
            if (matchingApp != null) {
              bannerUrl ??= matchingApp.imageUrl;
              startDate ??= matchingApp.startDate;
              endDate ??= matchingApp.endDate;
              city ??= matchingApp.city;
              country ??= matchingApp.country;
              organizer ??= matchingApp.organizer;
              venue ??= matchingApp.venue;
            }

            // If still missing image or date, fetch full application details
            if ((bannerUrl == null || bannerUrl.toString().trim().isEmpty) ||
                (startDate == null || startDate.toString().trim().isEmpty)) {
              try {
                final detail = await ProgramsService.getMyApplicationDetail(item['id']);
                final progInfo = detail['program_information'] is Map<String, dynamic>
                    ? detail['program_information'] as Map<String, dynamic>
                    : null;
                bannerUrl ??= ApiConfig.extractBannerUrl(progInfo) ?? ApiConfig.extractBannerUrl(detail);
                if (progInfo != null) {
                  startDate ??= progInfo['start_date'];
                  endDate ??= progInfo['end_date'];
                  city ??= progInfo['city'] ?? progInfo['city_text'];
                  country ??= progInfo['country'] ?? progInfo['country_text'];
                  organizer ??= progInfo['organizer'] ?? progInfo['organization_entity_name'];
                  venue ??= progInfo['venue'];
                  description ??= progInfo['description'] ?? progInfo['about'];
                }
              } catch (_) {}
            }

            return <String, dynamic>{
              ...item,
              'banner_image_url': bannerUrl,
              'start_date': startDate,
              'end_date': endDate,
              'city_text': city,
              'country_text': country,
              'organizer': organizer,
              'venue': venue,
              'description': description,
            };
          }),
        );

        for (final item in hydratedItems) {
          if (item is Map<String, dynamic>) {
            final idStr = (item['id'] ?? '').toString();
            final title = (item['title'] ?? item['program_name'] ?? '').toString();
            final progType = (item['program_type'] ?? '').toString();
            final statusStr = (item['display_status'] ?? item['review_status'] ?? item['status'] ?? 'Submitted').toString();

            if (idStr.isNotEmpty && mySeen.add(idStr)) {
              myList.add(ProgramModel(
                id: idStr,
                programNo: item['program_no']?.toString(),
                title: title,
                tag: progType.isNotEmpty ? progType.toUpperCase() : 'ACTIVITY DRIVE',
                type: ProgramType.activityDrive,
                status: ProgramStatus.upcoming,
                organizer: (item['organizer'] ?? 'You (Organizer)').toString(),
                organizationType: (item['organization_type'] ?? '').toString(),
                venue: (item['venue'] ?? '').toString(),
                location: [item['city_text'] ?? item['city'], item['country_text'] ?? item['country']]
                    .where((s) => s != null && s.toString().isNotEmpty)
                    .join(', '),
                country: (item['country_text'] ?? item['country'] ?? '').toString(),
                city: (item['city_text'] ?? item['city'] ?? '').toString(),
                startDate: (item['start_date'] ?? item['submitted_at'] ?? '').toString(),
                endDate: (item['end_date'] ?? item['submitted_at'] ?? '').toString(),
                description: (item['description'] ?? item['about'] ?? '').toString(),
                agenda: const [],
                materials: const [],
                contactInfo: ProgramContactInfo(
                  contactPerson: item['contact_person']?.toString() ?? '',
                  phone: item['phone']?.toString() ?? '',
                  email: item['email']?.toString() ?? '',
                ),
                isRegistered: false,
                isOrganizer: true,
                reviewStatus: statusStr.toLowerCase(),
                gradientColors: const [0xFF006097, 0xFF017CC2],
                category: progType,
                imageUrl: ApiConfig.resolveImageUrl(ApiConfig.extractBannerUrl(item)),
              ));
            }
          }
        }
      } catch (_) {}

      // 4. Update isOrganizer & isRegistered in approvedList from regRes and user's applications
      final Set<String> myAppIds = {};
      final Set<String> myAppNos = {};
      final Set<String> myAppTitles = {};
      for (final item in hydratedItems) {
        if (item is Map) {
          final idStr = (item['id'] ?? '').toString();
          final noStr = (item['program_no'] ?? item['application_id'] ?? '').toString().trim();
          final tStr = (item['title'] ?? item['program_name'] ?? '').toString().trim().toLowerCase();
          if (idStr.isNotEmpty) myAppIds.add(idStr);
          if (noStr.isNotEmpty) myAppNos.add(noStr);
          if (tStr.isNotEmpty) myAppTitles.add(tStr);
        }
      }

      if (regRes != null) {
        for (final item in regRes.items) {
          final prog = ProgramModel.fromApiItem(item);
          final existingIdx = approvedList.indexWhere((p) => p.id == prog.id);
          if (existingIdx != -1) {
            final isOrg = prog.isOrganizer || approvedList[existingIdx].isOrganizer;
            approvedList[existingIdx] = approvedList[existingIdx].copyWith(
              isOrganizer: isOrg,
              isRegistered: isOrg ? false : (prog.isRegistered || approvedList[existingIdx].isRegistered),
            );
          }
        }
      }

      for (int i = 0; i < approvedList.length; i++) {
        final prog = approvedList[i];
        final pId = prog.id.toString();
        final pNo = (prog.programNo ?? '').trim();
        final pTitle = prog.title.trim().toLowerCase();

        final isUserApp = myAppIds.contains(pId) ||
            (pNo.isNotEmpty && myAppNos.contains(pNo)) ||
            (pTitle.isNotEmpty && myAppTitles.contains(pTitle));

        if (isUserApp) {
          approvedList[i] = prog.copyWith(
            isOrganizer: true,
            isRegistered: false,
          );
        }
      }

      if (mounted) {
        setState(() {
          _allApprovedPrograms = approvedList;
          _myPrograms = myList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val.trim();
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _fetchPrograms();
    });
  }

  void _openSubmitProgramWizard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubmitProgramWizardScreen(),
      ),
    ).then((_) => _fetchPrograms());
  }

  void _openProgramItem(ProgramModel program) {
    final rev = (program.reviewStatus ?? '').toLowerCase();
    final isApplication = (_selectedTab == 1 && !program.isRegistered) ||
        (program.isOrganizer &&
            (rev == 'submitted' || rev == 'draft' || rev == 'in_review' || rev == 'in review'));

    if (isApplication) {
      // Open application details (GET /api/applications/programs/:id)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProgramApplicationDetailsScreen(
            item: ProgramApplicationItem.fromProgramModel(program),
          ),
        ),
      ).then((_) => _fetchPrograms());
    } else {
      // Open standard public program details screen (GET /api/programs/:id)
      Navigator.of(context).push<ProgramModel>(
        MaterialPageRoute(
          builder: (_) => ProgramDetailsScreen(program: program),
        ),
      ).then((updated) {
        if (updated != null && mounted) {
          setState(() {
            final idx = _allApprovedPrograms.indexWhere((p) => p.id == updated.id);
            if (idx != -1) {
              _allApprovedPrograms[idx] = updated;
            }
          });
        }
        _fetchPrograms();
      });
    }
  }

  Widget _buildFilterButton() {
    final hasActiveFilter = _selectedFilter != 'All' || _selectedProgramType != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openFilterBottomSheet,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: hasActiveFilter ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasActiveFilter ? AppColors.primaryBlue : AppColors.border,
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: hasActiveFilter
                    ? AppColors.primaryBlue.withAlpha(50)
                    : Colors.black.withAlpha(4),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: hasActiveFilter ? Colors.white : const Color(0xFF64748B),
              ),
              if (hasActiveFilter)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFACC15),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterBottomSheet() {
    String tempFilter = _selectedFilter;
    ProgramTypeItem? tempType = _selectedProgramType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasFilterSelected = tempFilter != 'All' || tempType != null;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top drag indicator
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header row: Title & Reset Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Programs',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (hasFilterSelected)
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempFilter = 'All';
                                tempType = null;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Event Status
                    Text(
                      'STATUS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['All', 'Upcoming', 'Ongoing', 'Completed'].map((status) {
                        final isSelected = tempFilter == status;
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              tempFilter = status;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Program Type
                    Text(
                      'PROGRAM TYPE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // "All Types" chip
                        InkWell(
                          onTap: () {
                            setModalState(() {
                              tempType = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: tempType == null ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: tempType == null ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              'All Types',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: tempType == null ? FontWeight.w700 : FontWeight.w500,
                                color: tempType == null ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                        // Dynamic types
                        ..._programTypes.map((type) {
                          final isSelected = tempType?.id == type.id;
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                tempType = type;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                type.name,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _selectedFilter = tempFilter;
                            _selectedProgramType = tempType;
                          });
                          _fetchPrograms();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current active list based on selected tab
    List<ProgramModel> activeList = _selectedTab == 0 ? _allApprovedPrograms : _myPrograms;

    // Apply status filter if on Tab 0 (All Programs)
    if (_selectedTab == 0) {
      if (_selectedFilter == 'Upcoming') {
        activeList = activeList.where((p) => p.status == ProgramStatus.upcoming).toList();
      } else if (_selectedFilter == 'Ongoing') {
        activeList = activeList.where((p) => p.status == ProgramStatus.ongoing).toList();
      } else if (_selectedFilter == 'Completed') {
        activeList = activeList.where((p) => p.status == ProgramStatus.completed).toList();
      }
    }

    // Filter by name (applies to both tabs so searching by name works reliably and instantly)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      activeList = activeList.where((p) {
        final title = p.title.toLowerCase();
        final cat = (p.category ?? '').toLowerCase();
        final tag = p.tag.toLowerCase();
        return title.contains(q) || cat.contains(q) || tag.contains(q);
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.isTabMode
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Title & "+ New" Button
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 14.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Programs',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  InkWell(
                    onTap: _openSubmitProgramWizard,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'New',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Segmented Tab (All Programs vs My Programs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_selectedTab != 0) {
                            setState(() {
                              _selectedTab = 0;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _selectedTab == 0
                                ? [
                              BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'All Programs',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                color: _selectedTab == 0 ? AppColors.textPrimary : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_selectedTab != 1) {
                            setState(() {
                              _selectedTab = 1;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _selectedTab == 1
                                ? [
                              BoxShadow(
                                color: Colors.black.withAlpha(12),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'My Programs',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                  color: _selectedTab == 1 ? AppColors.textPrimary : const Color(0xFF64748B),
                                ),
                              ),
                              if (_myPrograms.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? AppColors.primaryBlue : const Color(0xFF94A3B8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_myPrograms.length}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar & Filter Button in one row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search programs by name',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFFB0BAC9),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFFB0BAC9),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _fetchPrograms();
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedTab == 0) ...[
                    const SizedBox(width: 8),
                    _buildFilterButton(),
                  ],
                ],
              ),
            ),

            // Active Filter indicator pills (only on All Programs tab)
            if (_selectedTab == 0 && (_selectedFilter != 'All' || _selectedProgramType != null))
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 2.0, bottom: 6.0),
                child: Row(
                  children: [
                    if (_selectedFilter != 'All') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedFilter,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = 'All';
                                });
                                _fetchPrograms();
                              },
                              child: const Icon(Icons.close_rounded, size: 12, color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (_selectedProgramType != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedProgramType!.name,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedProgramType = null;
                                });
                                _fetchPrograms();
                              },
                              child: const Icon(Icons.close_rounded, size: 12, color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Content Area (Loading / Empty / List)
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
                  : RefreshIndicator(
                onRefresh: _fetchPrograms,
                color: AppColors.primaryBlue,
                child: activeList.isEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _selectedTab == 0
                                    ? Icons.event_note_outlined
                                    : Icons.workspace_premium_outlined,
                                size: 32,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _selectedTab == 0
                                  ? 'No approved programs found'
                                  : 'No submitted or registered programs yet',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage != null
                                  ? 'Could not connect to server. Pull down to retry.'
                                  : (_selectedTab == 0
                                  ? 'Try searching with different keywords or reset filters.'
                                  : 'Tap "+ New" above to submit a proposal or register for programs.'),
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
                    : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 6.0, bottom: 24.0),
                  itemCount: activeList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final program = activeList[index];
                    return ProgramCard(
                      program: program,
                      isMyPrograms: _selectedTab == 1,
                      onTap: () => _openProgramItem(program),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}