import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';
import '../../../services/certification_service.dart';

class Step1InstitutionType extends StatefulWidget {
  final CertificationApplicationModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step1InstitutionType({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<Step1InstitutionType> createState() => _Step1InstitutionTypeState();
}

class _Step1InstitutionTypeState extends State<Step1InstitutionType> {
  late String _selectedId;
  List<InstitutionTypeInfo> _categories = [];
  bool _isLoading = true;
  bool _isFetchingConfig = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.model.institutionTypeId;
    _loadCategories();
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiCats = await CertificationService.getCategories(forceRefresh: forceRefresh);
      final mapped = apiCats.map((c) => InstitutionTypeInfo.fromCategory(c)).toList();

      if (mounted) {
        setState(() {
          _categories = mapped;
          _isLoading = false;

          // If current selection is invalid or empty, pick the first
          final exists = _categories.any((c) => c.id == _selectedId || (c.categoryId != null && c.categoryId == widget.model.categoryId));
          if (!exists && _categories.isNotEmpty) {
            _selectType(_categories.first);
          } else {
            // Re-apply current selection to sync scores/titles
            final current = _categories.firstWhere(
              (c) => c.id == _selectedId || (c.categoryId != null && c.categoryId == widget.model.categoryId),
              orElse: () => _categories.first,
            );
            _selectType(current);
          }
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

  void _selectType(InstitutionTypeInfo type) {
    setState(() {
      _selectedId = type.id;
      widget.model.institutionTypeId = type.id;
      if (type.categoryId != null) {
        widget.model.categoryId = type.categoryId;
      }
      widget.model.institutionTypeTitle = type.title.replaceAll('\n', ' ');
      widget.model.categoryMaxScore = type.maxPoints;
      widget.model.passScore = type.passScore ?? (type.maxPoints ~/ 2);
    });
  }

  Future<void> _handleContinue() async {
    if (_isFetchingConfig) return;
    if (_categories.isEmpty) return;

    final currentType = _categories.firstWhere(
      (c) => c.id == _selectedId,
      orElse: () => _categories.first,
    );

    final catId = currentType.categoryId ?? widget.model.categoryId ?? 1;

    setState(() {
      _isFetchingConfig = true;
    });

    try {
      final config = await CertificationService.getCategoryConfig(catId);
      widget.model.categoryConfig = config;
      widget.model.categoryId = config.category.id;
      widget.model.categoryMaxScore = config.category.maxScore;
      widget.model.passScore = config.category.passScore;
      widget.model.institutionTypeTitle = config.category.name;

      // Populate evidence requirements dynamically from API, preserving already attached/uploaded evidence
      if (config.evidenceRequirements.isNotEmpty) {
        final existingEvidence = List<EvidenceItem>.from(widget.model.evidenceItems);
        widget.model.evidenceItems = config.evidenceRequirements.map((req) {
          final match = existingEvidence.firstWhere(
            (e) =>
                e.requirementId == req.id.toString() ||
                e.id == req.id.toString() ||
                e.title.trim().toLowerCase() == req.title.trim().toLowerCase(),
            orElse: () => EvidenceItem.fromRequirement(req),
          );
          return match.copyWithRequirement(req);
        }).toList();
      } else {
        widget.model.evidenceItems = [];
      }

      if (mounted) {
        setState(() {
          _isFetchingConfig = false;
        });
        widget.onContinue();
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching category config: $e');
      if (mounted) {
        setState(() {
          _isFetchingConfig = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load category configuration: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Back Button
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Select Institution Type',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the category that best describes your institution',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                        strokeWidth: 2.5,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadCategories(forceRefresh: true),
                      color: AppColors.primaryBlue,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                        children: [
                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Color(0xFFDC2626), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF991B1B)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _loadCategories(forceRefresh: true),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ..._categories.map((type) {
                            final isSelected = _selectedId == type.id;
                            return _buildTypeCard(type, isSelected);
                          }),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Minimum 50% of category max score required for certification',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isFetchingConfig ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isFetchingConfig
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.2,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(InstitutionTypeInfo type, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryBlue.withAlpha(16)
                  : Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      type.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + Max points badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              type.title,
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Max Score: ${type.maxPoints}',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (type.passScore != null) ...[
                            Text(
                              'Pass score: ${type.passScore} pts',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '•',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${type.validityMonths ?? 24} months validity',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Selected',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
