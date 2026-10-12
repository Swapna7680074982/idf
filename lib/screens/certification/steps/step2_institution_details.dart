import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';

class Step2InstitutionDetails extends StatefulWidget {
  final CertificationApplicationModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step2InstitutionDetails({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<Step2InstitutionDetails> createState() =>
      _Step2InstitutionDetailsState();
}

class _Step2InstitutionDetailsState extends State<Step2InstitutionDetails> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactPersonController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _roomsController;
  late TextEditingController _distanceController;

  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCity;
  String? _selectedParking;

  final List<String> _countries = [
    'Nigeria',
    'India',
    'Kenya',
    'Ghana',
    'South Africa',
    'United Kingdom',
    'United States',
  ];

  final List<String> _regions = [
    'Lagos',
    'Abuja (FCT)',
    'Oyo',
    'Rivers',
    'Kano',
    'Telangana',
    'Maharashtra',
    'Delhi',
  ];

  final List<String> _cities = [
    'Ojo',
    'Ikeja',
    'Lekki',
    'Yaba',
    'Hyderabad',
    'Mumbai',
    'Nairobi',
  ];

  final List<String> _parkingOptions = [
    'Ample Parking Available',
    'Limited Designated Parking',
    'Street Parking Only',
    'Bicycle & Pedestrian Only',
    'None',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.model.institutionName);
    _addressController = TextEditingController(text: widget.model.address);
    _contactPersonController =
        TextEditingController(text: widget.model.contactPerson);
    _phoneController =
        TextEditingController(text: widget.model.contactPhone);
    _emailController =
        TextEditingController(text: widget.model.contactEmail);
    _roomsController =
        TextEditingController(text: widget.model.numberOfRooms);
    _distanceController =
        TextEditingController(text: widget.model.distanceFromMainRoad);

    _selectedCountry = widget.model.country.isNotEmpty
        ? widget.model.country
        : null;
    _selectedRegion = widget.model.regionState.isNotEmpty
        ? widget.model.regionState
        : null;
    _selectedCity = widget.model.city.isNotEmpty
        ? widget.model.city
        : null;
    _selectedParking = widget.model.parkingAvailability.isNotEmpty
        ? widget.model.parkingAvailability
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _roomsController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? true) {
      widget.model.institutionName = _nameController.text.trim();
      widget.model.address = _addressController.text.trim();
      widget.model.country = _selectedCountry ?? '';
      widget.model.regionState = _selectedRegion ?? '';
      widget.model.city = _selectedCity ?? '';
      widget.model.contactPerson = _contactPersonController.text.trim();
      widget.model.contactPhone = _phoneController.text.trim();
      widget.model.contactEmail = _emailController.text.trim();
      widget.model.numberOfRooms = _roomsController.text.trim();
      widget.model.distanceFromMainRoad = _distanceController.text.trim();
      widget.model.parkingAvailability = _selectedParking ?? '';
      widget.onContinue();
    }
  }

  Widget _buildHeader() {
    final category = widget.model.institutionTypeTitle.isNotEmpty
        ? widget.model.institutionTypeTitle.replaceAll('🏢', '').trim().toUpperCase()
        : 'WORKPLACE / WORKSITE / OFFICE / HOSPITAL';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Back Button
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.apartment_rounded,
                size: 13,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Institution Details',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Institution Name *'),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Full official name',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter institution name' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Address *'),
                      _buildTextField(
                        controller: _addressController,
                        hintText: 'Street address',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter address' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Country *'),
                      _buildDropdown(
                        value: _selectedCountry,
                        hint: 'Select country...',
                        items: _countries,
                        onChanged: (val) =>
                            setState(() => _selectedCountry = val),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Region / State *'),
                      _buildDropdown(
                        value: _selectedRegion,
                        hint: 'Select Region / State',
                        items: _regions,
                        onChanged: (val) =>
                            setState(() => _selectedRegion = val),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('City *'),
                      _buildDropdown(
                        value: _selectedCity,
                        hint: 'Select City',
                        items: _cities,
                        onChanged: (val) => setState(() => _selectedCity = val),
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Contact Person *'),
                      _buildTextField(
                        controller: _contactPersonController,
                        hintText: 'Full Name',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter contact person' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Contact Email *'),
                      _buildTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'contact@institution.com',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter contact email' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Contact Phone *'),
                      _buildTextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        hintText: '+1 234 567 8900',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Please enter contact phone' : null,
                      ),
                      const SizedBox(height: 24),

                      // Workplace Details Section
                      Row(
                        children: [
                          const Icon(
                            Icons.business_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Workplace Details',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildFieldLabel('Number of Rooms'),
                      _buildTextField(
                        controller: _roomsController,
                        keyboardType: TextInputType.number,
                        hintText: 'e.g. 50',
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Distance from Main Road (km)'),
                      _buildTextField(
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        hintText: 'e.g. 0.5',
                      ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Parking Availability'),
                      _buildDropdown(
                        value: _selectedParking,
                        hint: 'Select...',
                        items: _parkingOptions,
                        onChanged: (val) =>
                            setState(() => _selectedParking = val),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Continue to Questionnaire',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
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
          color: const Color(0xFFB0BAC9), // Light gray hint
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
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
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      hint: Text(
        hint,
        style: GoogleFonts.inter(
          color: const Color(0xFFB0BAC9), // Light gray hint
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFFB0BAC9), // Light gray hint
          fontSize: 13.0,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF64748B)),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              color: const Color(0xFF0F172A),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
