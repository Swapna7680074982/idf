import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/meta_models.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../services/metadata_service.dart';
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

  List<OrganizationType> _orgTypes = [];
  OrganizationType? _selectedOrgType;
  bool _isLoadingTypes = true;
  String? _typesError;

  @override
  void initState() {
    super.initState();
    _entityNameController = TextEditingController(text: widget.model.organizingEntityName);
    _contactPersonController = TextEditingController(text: widget.model.contactPerson);
    final rawPhone = widget.model.phone.replaceAll(RegExp(r'\D'), '');
    final cleanPhone = rawPhone.length > 10 ? rawPhone.substring(rawPhone.length - 10) : rawPhone;
    _phoneController = TextEditingController(text: cleanPhone);
    _emailController = TextEditingController(text: widget.model.email);
    _loadOrgTypes();
  }

  Future<void> _loadOrgTypes() async {
    setState(() {
      _isLoadingTypes = true;
      _typesError = null;
    });

    try {
      final types = await MetadataService.getOrganizationTypes();
      if (mounted) {
        setState(() {
          _orgTypes = types;
          _isLoadingTypes = false;

          // Match by organization_type_id only if user had previously chosen one
          if (widget.model.organizationTypeId != null) {
            final matches = _orgTypes.where((t) => t.id == widget.model.organizationTypeId);
            if (matches.isNotEmpty) {
              _selectedOrgType = matches.first;
            }
          } else if (widget.model.organizationType.isNotEmpty) {
            final matches = _orgTypes.where(
              (t) => t.name.toLowerCase() == widget.model.organizationType.toLowerCase(),
            );
            if (matches.isNotEmpty) {
              _selectedOrgType = matches.first;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTypes = false;
          _typesError = 'Failed to load organization types: ${e.toString()}';
        });
      }
    }
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
      widget.model.organizationType = _selectedOrgType?.name ?? '';
      widget.model.organizationTypeId = _selectedOrgType?.id;
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
              hintText: 'e.g. World Health Centre / University Campus',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter entity name' : null,
          ),
          const SizedBox(height: 16),

          // Organization Type (Backend API)
          _buildFieldLabel('Organization Type *'),
          const SizedBox(height: 6),
          if (_isLoadingTypes)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Loading organization types from server...',
                    style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else if (_typesError != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _typesError!,
                      style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFB91C1C)),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadOrgTypes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<OrganizationType>(
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
                return DropdownMenuItem<OrganizationType>(
                  value: type,
                  child: Text(
                    type.name,
                    style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedOrgType = val);
              },
              validator: (val) =>
                  val == null ? 'Please select organization type' : null,
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

          // Phone (10 Digits)
          _buildFieldLabel('Phone (10 Digits) *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              hintText: '9876543210',
              prefixText: '+91 ',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter 10-digit phone number';
              }
              final clean = val.replaceAll(RegExp(r'\D'), '');
              if (clean.length != 10) {
                return 'Phone number must be exactly 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          _buildFieldLabel('Email *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'organizer@institution.org',
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
