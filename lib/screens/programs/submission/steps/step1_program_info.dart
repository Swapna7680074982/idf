import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step1ProgramInfo extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step1ProgramInfo({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step1ProgramInfo> createState() => _Step1ProgramInfoState();
}

class _Step1ProgramInfoState extends State<Step1ProgramInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedType;

  final List<String> _programTypes = [
    'Activity Drive',
    'Campaign',
    'Conference',
    'Workshop',
    'Seminar',
    'Community Walk',
    'Marathon / Race',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.model.programName);
    _descriptionController = TextEditingController(text: widget.model.description);
    _selectedType = widget.model.programType.isNotEmpty
        ? widget.model.programType
        : _programTypes.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.programName = _nameController.text.trim();
      widget.model.programType = _selectedType;
      widget.model.description = _descriptionController.text.trim();
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
          // Program Name / Title
          _buildFieldLabel('Program Name / Title *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Global Walk for Diabetes 2025',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter program name';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Program Type
          _buildFieldLabel('Program Type *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _programTypes.contains(_selectedType) ? _selectedType : _programTypes.first,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
            items: _programTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedType = val;
                });
              }
            },
          ),
          const SizedBox(height: 18),

          // Description
          _buildFieldLabel('Description *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Describe the program and its physical activity goals...',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe the program';
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
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
