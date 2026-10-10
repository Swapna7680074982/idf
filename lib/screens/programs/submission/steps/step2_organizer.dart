import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../widgets/custom_button.dart';

class Step2Organizer extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step2Organizer({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step2Organizer> createState() => _Step2OrganizerState();
}

class _Step2OrganizerState extends State<Step2Organizer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _entityNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String? _selectedOrgType;

  final List<String> _orgTypes = [
    'Hospital / Healthcare Facility',
    'NGO / Non-profit Organization',
    'Academic / Research Institution',
    'Government / Public Health Agency',
    'Corporate / Fitness Organization',
    'Community Association',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _entityNameController = TextEditingController(text: widget.model.organizingEntityName);
    _contactPersonController = TextEditingController(text: widget.model.contactPerson);
    _phoneController = TextEditingController(text: widget.model.phone);
    _emailController = TextEditingController(text: widget.model.email);
    _selectedOrgType = widget.model.organizationType.isNotEmpty
        ? widget.model.organizationType
        : null;
  }

  @override
  void dispose() {
    _entityNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.organizingEntityName = _entityNameController.text.trim();
      widget.model.organizationType = _selectedOrgType ?? '';
      widget.model.contactPerson = _contactPersonController.text.trim();
      widget.model.phone = _phoneController.text.trim();
      widget.model.email = _emailController.text.trim();
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
          // Organizing Entity Name
          _buildFieldLabel('Organizing Entity Name *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _entityNameController,
            decoration: const InputDecoration(
              hintText: 'e.g. IDF Africa Region',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter entity name' : null,
          ),
          const SizedBox(height: 16),

          // Organization Type
          _buildFieldLabel('Organization Type *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedOrgType,
            hint: Text(
              'Select organization type',
              style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
            items: _orgTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedOrgType = val);
            },
            validator: (val) =>
                val == null || val.isEmpty ? 'Please select organization type' : null,
          ),
          const SizedBox(height: 16),

          // Contact Person
          _buildFieldLabel('Contact Person *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _contactPersonController,
            decoration: const InputDecoration(
              hintText: 'Full name',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter contact person' : null,
          ),
          const SizedBox(height: 16),

          // Phone
          _buildFieldLabel('Phone *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+1 234 567 8900',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter phone number' : null,
          ),
          const SizedBox(height: 16),

          // Email
          _buildFieldLabel('Email *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'organizer@email.com',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter email';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

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
