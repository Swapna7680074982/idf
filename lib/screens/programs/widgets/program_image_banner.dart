import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/program_model.dart';
import '../../../services/api_config.dart';
import 'program_status_pill.dart';

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

    final rawUrl = program.imageUrl;
    final hasImage = rawUrl != null && rawUrl.isNotEmpty;
    final isLocalFile = hasImage && File(rawUrl).existsSync();

    String effectiveUrl = rawUrl ?? '';
    if (hasImage && !isLocalFile && effectiveUrl.startsWith('/')) {
      effectiveUrl = '${ApiConfig.baseUrl}$effectiveUrl';
    }

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
          fit: StackFit.expand,
          children: [
            if (isLocalFile)
              Image.file(
                File(rawUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildArtisticBackground(colors),
              )
            else if (hasImage)
              Image.network(
                effectiveUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildArtisticBackground(colors),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFE2E8F0),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              )
            else
              _buildArtisticBackground(colors),

            // Floating Status Pill (for details screen hero banner)
            if (showFloatingStatus)
              Positioned(
                bottom: 14,
                left: 14,
                child: ProgramStatusPill(
                  status: program.status,
                  fontSize: 11.5,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisticBackground(List<Color> colors) {
    return Stack(
      children: [
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
      ],
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
