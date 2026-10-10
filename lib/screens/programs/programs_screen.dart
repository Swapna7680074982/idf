import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/program_model.dart';
import 'program_details_screen.dart';
import 'submission/submit_program_wizard_screen.dart';
import 'widgets/program_card.dart';
import 'widgets/program_filter_chips.dart';

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
  String _searchQuery = '';
  String _selectedFilter = 'All';
  ProgramType? _selectedType;

  late List<ProgramModel> _allPrograms;

  @override
  void initState() {
    super.initState();
    _allPrograms = ProgramModel.samplePrograms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProgramModel> get _filteredPrograms {
    return _allPrograms.where((prog) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = prog.title.toLowerCase().contains(q);
        final matchesOrganizer = prog.organizer.toLowerCase().contains(q);
        final matchesLocation = prog.location.toLowerCase().contains(q);
        final matchesTag = prog.tag.toLowerCase().contains(q);
        if (!matchesTitle && !matchesOrganizer && !matchesLocation && !matchesTag) {
          return false;
        }
      }

      // 2. Tab Filter (All, Upcoming, Ongoing)
      if (_selectedType == null) {
        if (_selectedFilter == 'Upcoming' && prog.status != ProgramStatus.upcoming) {
          return false;
        }
        if (_selectedFilter == 'Ongoing' && prog.status != ProgramStatus.ongoing) {
          return false;
        }
      } else {
        // 3. Type Filter
        if (prog.type != _selectedType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openSubmitProgramWizard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SubmitProgramWizardScreen(),
      ),
    );
  }

  void _openProgramDetails(ProgramModel program) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgramDetailsScreen(program: program),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredPrograms;

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
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 14.0, bottom: 10.0),
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
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
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search programs, organizer, location...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
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

            // Filter Chips Bar
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0, bottom: 12.0),
              child: ProgramFilterChips(
                selectedFilter: _selectedFilter,
                selectedType: _selectedType,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                onTypeSelected: (type) {
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
            ),

            // Programs List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 32,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No programs found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try searching with different keywords or reset filters',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 4.0, bottom: 24.0),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final program = filteredList[index];
                        return ProgramCard(
                          program: program,
                          onTap: () => _openProgramDetails(program),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
