import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step5Registration extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step5Registration({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step5Registration> createState() => _Step5RegistrationState();
}

class _Step5RegistrationState extends State<Step5Registration> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _instructionsController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _instructionsController =
        TextEditingController(text: widget.model.registrationInstructions);
    _linkController =
        TextEditingController(text: widget.model.registrationLink);
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.registrationInstructions =
          _instructionsController.text.trim();
      String link = _linkController.text.trim();
      if (link.isNotEmpty && !link.startsWith('http://') && !link.startsWith('https://')) {
        link = 'https://$link';
      }
      widget.model.registrationLink = link;
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Registration Instructions
          _buildFieldLabel('Registration Instructions (Optional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _instructionsController,
            maxLines: 4,
            minLines: 3,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'How can participants register? (e.g. Free walk-in, RSVP via link)',
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),

          // Registration Link
          _buildFieldLabel('Registration Link (Optional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _linkController,
            keyboardType: TextInputType.url,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'https://idf.org/register or idf.org/register',
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                final text = val.trim();
                if (!text.startsWith('http://') && !text.startsWith('https://')) {
                  if (!text.contains('.')) {
                    return 'Please enter a valid website link';
                  }
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Continue Button
          CustomButton(
            text: 'Continue',
            onPressed: _handleContinue,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }
}
