import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasBanner = model.bannerPath != null && model.bannerPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review your submission before sending.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),

        // 1. Program Information Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.1),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Program Information',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => onEditStep(1),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Banner thumbnail if uploaded
              if (hasBanner) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: File(model.bannerPath!).existsSync()
                        ? Image.file(File(model.bannerPath!), fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFF006097),
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.white),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              _buildItemRow('Name', model.programName.isNotEmpty ? model.programName : '—'),
              _buildItemRow('Type', model.programType.isNotEmpty ? model.programType : '—'),
              _buildItemRow(
                'Banner',
                hasBanner
                    ? (model.bannerFileName ?? 'Uploaded')
                    : 'None attached',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Organizer Card
        _buildReviewSection(
          title: 'Organizer',
          onEdit: () => onEditStep(2),
          items: [
            _ReviewItem(
              'Entity',
              model.organizingEntityName.isNotEmpty ? model.organizingEntityName : '—',
            ),
            _ReviewItem(
              'Org Type',
              model.organizationType.isNotEmpty ? model.organizationType : '—',
            ),
            _ReviewItem(
              'Contact',
              model.contactPerson.isNotEmpty ? model.contactPerson : '—',
            ),
            _ReviewItem(
              'Email',
              model.email.isNotEmpty ? model.email : '—',
            ),
            _ReviewItem(
              'Phone',
              model.phone.isNotEmpty ? model.phone : '—',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Date & Location Card
        _buildReviewSection(
          title: 'Date & Location',
          onEdit: () => onEditStep(3),
          items: [
            _ReviewItem('Start Date', _formatDate(model.startDate)),
            _ReviewItem('End Date', _formatDate(model.endDate)),
            _ReviewItem('Country', model.country.isNotEmpty ? model.country : '—'),
            if (model.regionState.isNotEmpty) _ReviewItem('Region / State', model.regionState),
            _ReviewItem('City', model.city.isNotEmpty ? model.city : '—'),
            _ReviewItem('Venue', model.venueAddress.isNotEmpty ? model.venueAddress : '—'),
          ],
        ),
        // 4. Content & Agenda Card
        _buildReviewSection(
          title: 'Content & Agenda',
          onEdit: () => onEditStep(4),
          items: [
            _ReviewItem(
              'Description',
              model.programDescription.isNotEmpty
                  ? (model.programDescription.length > 80
                      ? '${model.programDescription.substring(0, 80)}...'
                      : model.programDescription)
                  : (model.description.isNotEmpty ? model.description : '—'),
            ),
            _ReviewItem(
              'Agenda',
              model.agendaItems.isNotEmpty
                  ? '${model.agendaItems.length} session(s) scheduled'
                  : (model.agenda.isNotEmpty ? model.agenda : 'None scheduled'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 5. Materials Card
        _buildReviewSection(
          title: 'Materials & Banner',
          onEdit: () => onEditStep(6),
          items: [
            _ReviewItem(
              'Program Banner',
              hasBanner ? (model.bannerFileName ?? 'Selected') : 'None',
            ),
            _ReviewItem(
              'Supporting Files',
              model.uploadedFileNames.isNotEmpty
                  ? '${model.uploadedFileNames.length} file(s)'
                  : 'None',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // AI Review Note
        Text(
          'Your program application will be reviewed by our AI system within 24 hours, followed by an IDF manual review.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),

        // Notice Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'After submission, you can track the status in Applications.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF0369A1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit Program Button
        CustomButton(
          text: 'Submit Program',
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required String title,
    required VoidCallback onEdit,
    required List<_ReviewItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.1),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => _buildItemRow(item.label, item.value)),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String label;
  final String value;
  _ReviewItem(this.label, this.value);
}
