import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/program_model.dart';
import 'program_image_banner.dart';
import 'program_status_pill.dart';

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
              // Program Banner with top-right Event Status Pill & top-left Review/Organizer Pill
              Stack(
                children: [
                  ProgramImageBanner(
                    program: program,
                    height: 130,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ProgramStatusPill(status: program.status),
                  ),
                  if (program.isOrganizer || (program.reviewStatus != null && program.reviewStatus!.isNotEmpty && program.reviewStatus != 'approved'))
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: program.reviewStatus == 'submitted'
                              ? const Color(0xFFD97706)
                              : (program.reviewStatus == 'draft'
                                  ? const Color(0xFF64748B)
                                  : AppColors.primaryBlue),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(45),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              program.reviewStatus == 'submitted'
                                  ? Icons.schedule_rounded
                                  : (program.reviewStatus == 'draft'
                                      ? Icons.edit_note_rounded
                                      : Icons.person_rounded),
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              program.reviewStatus != null && program.reviewStatus!.isNotEmpty
                                  ? (program.reviewStatus == 'submitted'
                                      ? 'SUBMITTED'
                                      : (program.reviewStatus == 'draft' ? 'DRAFT' : program.reviewStatus!.toUpperCase()))
                                  : 'ORGANIZER',
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program Type / Category Badge & Registration Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (program.category ?? program.tag).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            if (program.programNo != null && program.programNo!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                                ),
                                child: Text(
                                  program.programNo!,
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (program.isRegistered)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF16A34A)),
                                const SizedBox(width: 3.5),
                                Text(
                                  'REGISTERED',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
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
                          (program.endDate.isNotEmpty && program.endDate != program.startDate)
                              ? '${program.startDate} - ${program.endDate}'
                              : program.startDate,
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
