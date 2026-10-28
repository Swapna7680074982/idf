import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/date_time_utils.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step7ReviewSubmit extends StatelessWidget {
  final ProgramSubmissionModel model;
  final Function(int) onEditStep;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const Step7ReviewSubmit({
    super.key,
    required this.model,
    required this.onEditStep,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateTimeUtils.formatDateOnly(dt);
  }

  @override
  Widget build(BuildContext context) {
    final hasBanner = model.bannerPath != null && model.bannerPath!.isNotEmpty;
    final String descriptionText = model.description.isNotEmpty
        ? model.description
        : (model.programDescription.isNotEmpty ? model.programDescription : '—');

    final String startDateStr = _formatDate(model.startDate);
    final String endDateStr = _formatDate(model.endDate ?? model.startDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle
        Text(
          'Please review all program details below before final submission.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),

        // Hero Preview Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner image or Branded Gradient
              if (hasBanner && File(model.bannerPath!).existsSync())
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(
                    File(model.bannerPath!),
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF00377B), Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          size: 90,
                          color: Colors.white.withAlpha(20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PROGRAM PROPOSAL',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              model.programName.isNotEmpty ? model.programName : 'Untitled Program',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Overview content details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            model.programName.isNotEmpty ? model.programName : 'Untitled Program',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            model.programType.isNotEmpty ? model.programType : 'Activity',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Quick metadata row: Dates & Location
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            startDateStr == endDateStr ? startDateStr : '$startDateStr – $endDateStr',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (model.city.isNotEmpty || model.country.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              [
                                if (model.city.isNotEmpty) model.city,
                                if (model.regionState.isNotEmpty) model.regionState,
                                if (model.country.isNotEmpty) model.country,
                              ].join(', '),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
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
        const SizedBox(height: 16),

        // 1. Program Information Card
        _buildSectionCard(
          title: 'Program Information',
          icon: Icons.info_outline_rounded,
          onEdit: () => onEditStep(1),
          children: [
            _buildReviewRow('Program Name', model.programName.isNotEmpty ? model.programName : '—'),
            _buildReviewRow('Program Type', model.programType.isNotEmpty ? model.programType : '—'),
            _buildReviewRow(
              'Banner (Cover)',
              hasBanner ? (model.bannerFileName ?? 'Attached') : 'None attached (Optional)',
            ),
            const SizedBox(height: 4),
            Text(
              'Description',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                descriptionText,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.4,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Organizing Entity & Contact Card
        _buildSectionCard(
          title: 'Organizer & Contact',
          icon: Icons.corporate_fare_rounded,
          onEdit: () => onEditStep(2),
          children: [
            _buildReviewRow(
              'Entity Name',
              model.organizingEntityName.isNotEmpty ? model.organizingEntityName : '—',
            ),
            _buildReviewRow(
              'Organization Type',
              model.organizationType.isNotEmpty ? model.organizationType : '—',
            ),
            _buildReviewRow(
              'Contact Person',
              model.contactPerson.isNotEmpty ? model.contactPerson : '—',
            ),
            _buildReviewRow(
              'Contact Phone',
              model.phone.isNotEmpty ? model.phone : '—',
            ),
            _buildReviewRow(
              'Contact Email',
              model.email.isNotEmpty ? model.email : '—',
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 3. Date & Location Card
        _buildSectionCard(
          title: 'Date & Location',
          icon: Icons.place_outlined,
          onEdit: () => onEditStep(3),
          children: [
            _buildReviewRow('Start Date', startDateStr),
            _buildReviewRow('End Date', endDateStr),
            _buildReviewRow('Country', model.country.isNotEmpty ? model.country : '—'),
            if (model.regionState.isNotEmpty) _buildReviewRow('Region / State', model.regionState),
            _buildReviewRow('City', model.city.isNotEmpty ? model.city : '—'),
            _buildReviewRow(
              'Venue',
              model.venueAddress.isNotEmpty ? model.venueAddress : 'To be announced',
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4. Agenda & Schedule Card (No '#' symbol!)
        _buildSectionCard(
          title: 'Agenda & Schedule',
          icon: Icons.schedule_rounded,
          onEdit: () => onEditStep(4),
          children: [
            if (model.agendaItems.isNotEmpty)
              ...model.agendaItems.asMap().entries.map((entry) {
                final index = entry.key;
                final session = entry.value;
                final isLast = index == model.agendaItems.length - 1;
                final time = (session['start_time'] ?? '').toString();
                final title = (session['title'] ?? '').toString();

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateTimeUtils.formatTime(time.isNotEmpty ? time : '09:00'),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Session ${index + 1}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              title.isNotEmpty ? title : 'General Activity',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Text(
                    'No specific breakout sessions scheduled',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 14),

        // 5. Registration Details Card
        _buildSectionCard(
          title: 'Registration Details',
          icon: Icons.how_to_reg_outlined,
          onEdit: () => onEditStep(5),
          children: [
            _buildReviewRow(
              'Instructions',
              model.registrationInstructions.isNotEmpty
                  ? model.registrationInstructions
                  : 'Open attendance / No prior registration required',
            ),
            _buildReviewRow(
              'Link',
              model.registrationLink.isNotEmpty ? model.registrationLink : 'None provided',
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 6. Materials Card
        _buildSectionCard(
          title: 'Supporting Materials',
          icon: Icons.attach_file_rounded,
          onEdit: () => onEditStep(6),
          children: [
            if (model.uploadedFileNames.isNotEmpty)
              ...model.uploadedFileNames.map((fileName) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      const Icon(Icons.description_outlined, size: 16, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
            else
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Text(
                    'No supporting materials attached (Optional)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Verification & Next Steps Notice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready for Official IDF Review',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Upon submitting, your proposal will undergo automated validation followed by IDF chapter evaluation. You can monitor status under Applications.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        height: 1.35,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // Submit Button
        CustomButton(
          text: 'Submit Program Proposal',
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 17, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 13, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
