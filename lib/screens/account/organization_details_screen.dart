import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../core/theme.dart';

class OrganizationDetailsScreen extends StatefulWidget {
  const OrganizationDetailsScreen({super.key});

  @override
  State<OrganizationDetailsScreen> createState() =>
      _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _orgNameController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;

  late String _selectedOrgType;

  final List<String> _orgTypes = [
    'Institution',
    'College / University',
    'Hospital / Healthcare Facility',
    'Research Institute',
    'Non-Profit / NGO',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AppBloc>().state.user;
    _orgNameController = TextEditingController(
      text: user.organizationName.isNotEmpty
          ? user.organizationName
          : 'Lagos State University',
    );
    _selectedOrgType = _orgTypes.contains(user.organizationType)
        ? user.organizationType
        : _orgTypes.first;
    _countryController = TextEditingController(
      text: user.country.isNotEmpty ? user.country : 'Nigeria',
    );
    _stateController = TextEditingController(
      text: user.state.isNotEmpty ? user.state : 'Lagos State',
    );
    _cityController = TextEditingController(
      text: user.city.isNotEmpty ? user.city : 'Lagos',
    );
    _addressController = TextEditingController(
      text: user.address.isNotEmpty ? user.address : 'Street address',
    );
    _contactEmailController = TextEditingController(
      text: user.contactEmail.isNotEmpty ? user.contactEmail : 'contact@org.com',
    );
    _contactPhoneController = TextEditingController(
      text: user.contactPhone.isNotEmpty
          ? user.contactPhone
          : '+234 800 000 0000',
    );
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AppBloc>().add(
            UpdateUserProfileRequested(
              organizationName: _orgNameController.text.trim(),
              organizationType: _selectedOrgType,
              country: _countryController.text.trim(),
              state: _stateController.text.trim(),
              city: _cityController.text.trim(),
              address: _addressController.text.trim(),
              contactEmail: _contactEmailController.text.trim(),
              contactPhone: _contactPhoneController.text.trim(),
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Organization details updated successfully',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Organization Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Organization Name
                      _buildFieldLabel('Organization / Institution Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _orgNameController,
                        hintText: 'Organization / Institution Name',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Please enter organization name'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Organization Type (Dropdown)
                      _buildFieldLabel('Organization Type'),
                      const SizedBox(height: 8),
                      _buildDropdown(),
                      const SizedBox(height: 20),

                      // Country
                      _buildFieldLabel('Country'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _countryController,
                        hintText: 'Country',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Please enter country'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Region / State
                      _buildFieldLabel('Region / State'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _stateController,
                        hintText: 'Region / State',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Please enter region/state'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // City
                      _buildFieldLabel('City'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _cityController,
                        hintText: 'City',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Please enter city'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Address
                      _buildFieldLabel('Address'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _addressController,
                        hintText: 'Street address',
                      ),
                      const SizedBox(height: 20),

                      // Contact Email
                      _buildFieldLabel('Contact Email'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _contactEmailController,
                        hintText: 'contact@org.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Contact Phone
                      _buildFieldLabel('Contact Phone'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _contactPhoneController,
                        hintText: '+234 800 000 0000',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Save Changes Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF334155),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOrgType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF0F172A),
          ),
          items: _orgTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedOrgType = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 13.0,
          color: const Color(0xFFB0BAC9),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
