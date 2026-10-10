import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step4Content extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step4Content({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step4Content> createState() => _Step4ContentState();
}

class _Step4ContentState extends State<Step4Content> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _programDescController;
  late TextEditingController _agendaController;

  @override
  void initState() {
    super.initState();
    _programDescController =
        TextEditingController(text: widget.model.programDescription.isNotEmpty
            ? widget.model.programDescription
            : widget.model.description);
    _agendaController = TextEditingController(text: widget.model.agenda);
  }

  @override
  void dispose() {
    _programDescController.dispose();
    _agendaController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.programDescription = _programDescController.text.trim();
      widget.model.agenda = _agendaController.text.trim();
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
          // Program Description
          _buildFieldLabel('Program Description *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _programDescController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Detailed description of the program...',
              alignLabelWithHint: true,
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please provide detailed description' : null,
          ),
          const SizedBox(height: 18),

          // Agenda
          _buildFieldLabel('Agenda'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _agendaController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'List the program schedule',
              alignLabelWithHint: true,
            ),
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
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
