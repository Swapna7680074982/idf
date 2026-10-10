import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step5Objectives extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step5Objectives({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step5Objectives> createState() => _Step5ObjectivesState();
}

class _Step5ObjectivesState extends State<Step5Objectives> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _participantsController;
  late TextEditingController _objectivesController;
  late String _selectedAudience;

  final List<String> _audiences = [
    'General Public & Youth',
    'Youth & Students',
    'Adults & Seniors',
    'Healthcare Professionals',
    'Workplace Employees',
    'People Living with Diabetes',
  ];

  @override
  void initState() {
    super.initState();
    _participantsController =
        TextEditingController(text: widget.model.expectedParticipants);
    _objectivesController = TextEditingController(text: widget.model.objectives);
    _selectedAudience = widget.model.targetAudience.isNotEmpty
        ? widget.model.targetAudience
        : _audiences.first;
  }

  @override
  void dispose() {
    _participantsController.dispose();
    _objectivesController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.targetAudience = _selectedAudience;
      widget.model.expectedParticipants = _participantsController.text.trim();
      widget.model.objectives = _objectivesController.text.trim();
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
          // Target Audience
          _buildFieldLabel('Target Audience *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _audiences.contains(_selectedAudience) ? _selectedAudience : _audiences.first,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
            items: _audiences.map((aud) {
              return DropdownMenuItem<String>(
                value: aud,
                child: Text(
                  aud,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedAudience = val);
              }
            },
          ),
          const SizedBox(height: 18),

          // Expected Participants
          _buildFieldLabel('Expected Participants *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _participantsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g. 500',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter expected number of participants' : null,
          ),
          const SizedBox(height: 18),

          // Key Objectives
          _buildFieldLabel('Key Objectives *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _objectivesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe the main health outcomes and activity goals...',
              alignLabelWithHint: true,
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please specify program objectives' : null,
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
