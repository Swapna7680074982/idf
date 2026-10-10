import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/program_model.dart';

class ProgramFilterChips extends StatelessWidget {
  final String selectedFilter; // 'All', 'Upcoming', 'Ongoing'
  final ProgramType? selectedType;
  final ValueChanged<String> onFilterSelected;
  final ValueChanged<ProgramType?> onTypeSelected;

  const ProgramFilterChips({
    super.key,
    required this.selectedFilter,
    required this.selectedType,
    required this.onFilterSelected,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildChip(
            label: 'All',
            isSelected: selectedFilter == 'All' && selectedType == null,
            onTap: () {
              onTypeSelected(null);
              onFilterSelected('All');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChip(
            label: 'Upcoming',
            isSelected: selectedFilter == 'Upcoming' && selectedType == null,
            onTap: () {
              onTypeSelected(null);
              onFilterSelected('Upcoming');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChip(
            label: 'Ongoing',
            isSelected: selectedFilter == 'Ongoing' && selectedType == null,
            onTap: () {
              onTypeSelected(null);
              onFilterSelected('Ongoing');
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeDropdownChip(context),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7.5),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeDropdownChip(BuildContext context) {
    final hasSelectedType = selectedType != null;
    final typeLabel = hasSelectedType
        ? _formatType(selectedType!)
        : 'Type ▾';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTypeSelectionModal(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7.5),
          decoration: BoxDecoration(
            color: hasSelectedType ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelectedType ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Text(
            typeLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: hasSelectedType ? FontWeight.w600 : FontWeight.w500,
              color: hasSelectedType ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  String _formatType(ProgramType type) {
    switch (type) {
      case ProgramType.activityDrive:
        return 'Activity Drive';
      case ProgramType.campaign:
        return 'Campaign';
      case ProgramType.conference:
        return 'Conference';
      case ProgramType.workshop:
        return 'Workshop';
      case ProgramType.seminar:
        return 'Seminar';
      case ProgramType.communityWalk:
        return 'Community Walk';
      case ProgramType.marathon:
        return 'Marathon';
    }
  }

  void _showTypeSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                // Drag handle
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Program Type',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (selectedType != null)
                        TextButton(
                          onPressed: () {
                            onTypeSelected(null);
                            Navigator.pop(ctx);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                            textStyle: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ProgramType.values.map((type) {
                        final isSelected = selectedType == type;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2.0),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF0F9FF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(
                              _formatType(type),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20)
                                : null,
                            onTap: () {
                              onTypeSelected(type);
                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
