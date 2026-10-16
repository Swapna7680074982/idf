import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/date_time_utils.dart';
import '../../../core/theme.dart';
import '../../../models/program_model.dart';
import 'program_image_banner.dart';
import 'program_status_pill.dart';

class ProgramCard extends StatelessWidget {
  final ProgramModel program;
  final VoidCallback onTap;
  final bool isMyPrograms;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    this.isMyPrograms = false,
  });

  @override
  Widget build(BuildContext context) {
    final rev = (program.reviewStatus ?? '').toLowerCase();
    final isUnapproved = rev == 'submitted' || rev == 'draft' || rev == 'in_review';

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
              // 1. Program Banner (Clean, no overlay tags)
              ProgramImageBanner(
                program: program,
                height: 145,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),

              // 2. Card Content
              Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Status Pill (Left) & Category Text (Right) - Exactly matching screenshot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Status Pill
                        isMyPrograms
                            ? _buildMyProgramStatusPill(rev)
                            : ProgramStatusPill(
                                status: program.status,
                                fontSize: 11.5,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),

                        // Right: Category Text (e.g. Activity Drive, Conference)
                        Flexible(
                          child: Text(
                            program.category?.isNotEmpty == true
                                ? program.category!
                                : program.tag,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Row 2: Program Title
                    Text(
                      program.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Row 3: Organizer Subtitle
                    Text(
                      program.organizer.isNotEmpty ? program.organizer : 'IDF Africa Region',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row 4: Details Row: Location & Date (Matching screenshot)
                    Row(
                      children: [
                        if (program.location.isNotEmpty) ...[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              program.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            DateTimeUtils.formatCardDate(program.startDate, program.endDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Optional Audit & Details Link for My Programs in Review
                    if (isMyPrograms && isUnapproved) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (program.programNo != null && program.programNo!.isNotEmpty)
                            Text(
                              program.programNo!,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View audit & details',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 12,
                                color: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyProgramStatusPill(String rev) {
    final Color bg;
    final Color border;
    final Color text;
    final String label;

    final s = rev.trim().toLowerCase();
    switch (s) {
      case 'submitted':
        bg = const Color(0xFFE0F2FE);
        border = const Color(0xFFBAE6FD);
        text = const Color(0xFF0284C7);
        label = 'Submitted';
        break;
      case 'in_review':
      case 'in review':
      case 'manual_review':
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFB45309);
        label = 'In Review';
        break;
      case 'approved':
      case 'complete':
      case 'completed':
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF16A34A);
        label = 'Approved';
        break;
      case 'changes_required':
      case 'changes required':
        bg = const Color(0xFFFFEDD5);
        border = const Color(0xFFFDBA74);
        text = const Color(0xFFC2410C);
        label = 'Changes Required';
        break;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFCA5A5);
        text = const Color(0xFFDC2626);
        label = 'Rejected';
        break;
      case 'draft':
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFE2E8F0);
        text = const Color(0xFF64748B);
        label = 'Draft';
        break;
      case 'registered':
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF16A34A);
        label = 'Registered';
        break;
      default:
        if (s.contains('changes')) {
          bg = const Color(0xFFFFEDD5);
          border = const Color(0xFFFDBA74);
          text = const Color(0xFFC2410C);
          label = 'Changes Required';
        } else {
          bg = const Color(0xFFE0F2FE);
          border = const Color(0xFFBAE6FD);
          text = const Color(0xFF0284C7);
          label = rev.isNotEmpty ? (rev[0].toUpperCase() + rev.substring(1)) : 'Active';
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
