import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/program_model.dart';
import '../../services/programs_service.dart';
import 'program_details_screen.dart';
import 'submission/submit_program_wizard_screen.dart';
import 'widgets/program_card.dart';
import 'widgets/program_filter_chips.dart';
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

  String _searchQuery = '';
  String _selectedFilter = 'All';
  ProgramTypeItem? _selectedProgramType;
  List<ProgramTypeItem> _programTypes = [];

  bool _isLoading = true;
  String? _errorMessage;
  List<ProgramModel> _apiPrograms = [];

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
      final res = await ProgramsService.getPrograms(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        typeId: _selectedProgramType?.id,
      );

      if (mounted) {
        setState(() {
          _apiPrograms = res.items
              .map((item) => ProgramModel.fromApiItem(item))
              .toList();
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      setState(() {
        _searchQuery = val.trim();
      });
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

  void _openProgramDetails(ProgramModel program) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgramDetailsScreen(program: program),
      ),
    ).then((_) => _fetchPrograms());
  }

  @override
  Widget build(BuildContext context) {
    var displayList = _apiPrograms;

    if (_selectedFilter == 'Upcoming') {
      displayList = displayList.where((p) => p.status == ProgramStatus.upcoming).toList();
    } else if (_selectedFilter == 'Ongoing') {
      displayList = displayList.where((p) => p.status == ProgramStatus.ongoing).toList();
    } else if (_selectedFilter == 'Completed') {
      displayList = displayList.where((p) => p.status == ProgramStatus.completed).toList();
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

            const SizedBox(height: 4),

            // Search Bar & Filter Chips
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
                  onChanged: _onSearchChanged,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search title, organizer, city...',
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

            // Filter Chips Bar
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 4.0, bottom: 8.0),
              child: ProgramFilterChips(
                programTypes: _programTypes,
                selectedFilter: _selectedFilter,
                selectedType: _selectedProgramType,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                onTypeSelected: (type) {
                  setState(() {
                    _selectedProgramType = type;
                  });
                  _fetchPrograms();
                },
              ),
            ),

            // Content Area (Loading / Error / Empty / List)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPrograms,
                      color: AppColors.primaryBlue,
                      child: displayList.isEmpty
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
                                          child: const Icon(
                                            Icons.event_note_outlined,
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
                                          _errorMessage != null
                                              ? 'Could not connect to server. Pull down to retry.'
                                              : 'Try searching with different keywords or reset filters.',
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
                              itemCount: displayList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final program = displayList[index];
                                return ProgramCard(
                                  program: program,
                                  onTap: () => _openProgramDetails(program),
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
