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
        _buildReviewSection(
          title: 'Program Information',
          onEdit: () => onEditStep(1),
          items: [
            _ReviewItem('Name', model.programName.isNotEmpty ? model.programName : '—'),
            _ReviewItem('Type', model.programType.isNotEmpty ? model.programType : '—'),
          ],
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
              'Contact',
              model.contactPerson.isNotEmpty ? model.contactPerson : '—',
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Date & Location Card
        _buildReviewSection(
          title: 'Date & Location',
          onEdit: () => onEditStep(3),
          items: [
            _ReviewItem('Start', _formatDate(model.startDate)),
            _ReviewItem('City', model.city.isNotEmpty ? model.city : '—'),
          ],
        ),
        const SizedBox(height: 16),

        // AI Review Note
        Text(
          'Your program application will be reviewed by our AI system within 24 hours, followed by a manual review.',
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
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      item.value,
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
          }),
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
