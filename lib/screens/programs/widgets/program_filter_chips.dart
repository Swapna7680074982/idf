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
    final filters = ['All', 'Upcoming', 'Ongoing'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          ...filters.map((filter) {
            final isSelected = selectedFilter == filter && selectedType == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildChip(
                label: filter,
                isSelected: isSelected,
                onTap: () {
                  onTypeSelected(null);
                  onFilterSelected(filter);
                },
              ),
            );
          }),
          _buildTypeDropdownChip(context),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: hasSelectedType ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasSelectedType ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                typeLabel,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: hasSelectedType ? FontWeight.w600 : FontWeight.w500,
                  color: hasSelectedType ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                          child: const Text('Reset'),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                ...ProgramType.values.map((type) {
                  final isSelected = selectedType == type;
                  return ListTile(
                    title: Text(
                      _formatType(type),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.primaryBlue)
                        : null,
                    onTap: () {
                      onTypeSelected(type);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
