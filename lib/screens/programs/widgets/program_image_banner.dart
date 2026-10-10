import 'package:flutter/material.dart';
import '../../../models/program_model.dart';

class ProgramImageBanner extends StatelessWidget {
  final ProgramModel program;
  final double height;
  final BorderRadius? borderRadius;
  final bool showFloatingStatus;

  const ProgramImageBanner({
    super.key,
    required this.program,
    this.height = 140,
    this.borderRadius,
    this.showFloatingStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = program.gradientColors.isNotEmpty
        ? program.gradientColors.map((c) => Color(c)).toList()
        : [const Color(0xFF006097), const Color(0xFF017CC2)];

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            // Background artistic elements
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(25),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(15),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: 10,
              child: Icon(
                _getCategoryIcon(program.type),
                size: 70,
                color: Colors.white.withAlpha(40),
              ),
            ),
            Center(
              child: Icon(
                _getCategoryIcon(program.type),
                size: 46,
                color: Colors.white.withAlpha(200),
              ),
            ),
            // Floating Status Pill (for details screen hero banner)
            if (showFloatingStatus)
              Positioned(
                bottom: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    program.status == ProgramStatus.upcoming
                        ? 'Upcoming'
                        : program.status == ProgramStatus.ongoing
                            ? 'Ongoing'
                            : 'Completed',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF017CC2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ProgramType type) {
    switch (type) {
      case ProgramType.activityDrive:
      case ProgramType.marathon:
        return Icons.directions_run_rounded;
      case ProgramType.campaign:
        return Icons.directions_bike_rounded;
      case ProgramType.conference:
        return Icons.groups_rounded;
      case ProgramType.workshop:
      case ProgramType.seminar:
        return Icons.menu_book_rounded;
      case ProgramType.communityWalk:
        return Icons.directions_walk_rounded;
    }
  }
}
