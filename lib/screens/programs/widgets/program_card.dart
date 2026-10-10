import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/program_model.dart';
import 'program_image_banner.dart';

class ProgramCard extends StatelessWidget {
  final ProgramModel program;
  final VoidCallback onTap;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = program.status == ProgramStatus.upcoming;
    final isOngoing = program.status == ProgramStatus.ongoing;

    final statusBg = isUpcoming
        ? const Color(0xFFE0F2FE)
        : isOngoing
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFF1F5F9);

    final statusText = isUpcoming
        ? const Color(0xFF017CC2)
        : isOngoing
            ? const Color(0xFF16A34A)
            : const Color(0xFF64748B);

    final statusLabel = isUpcoming
        ? 'Upcoming'
        : isOngoing
            ? 'Ongoing'
            : 'Completed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primaryBlue.withAlpha(15),
          highlightColor: AppColors.primaryBlue.withAlpha(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program Banner
              ProgramImageBanner(
                program: program,
                height: 125,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge & category tag row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: statusText,
                            ),
                          ),
                        ),
                        Text(
                          program.category ?? program.tag,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Program Title
                    Text(
                      program.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Organizer Subtitle
                    Text(
                      program.organizer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Details Row: Location & Date
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            program.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.startDate,
                          style: GoogleFonts.inter(
                            fontSize: 11,
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
        ),
      ),
    );
  }
}
