import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';
import '../../../models/meta_models.dart';
import '../../../services/metadata_service.dart';

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
  late TextEditingController _regionTextController;
  late TextEditingController _cityTextController;

  Country? _selectedCountry;
  Region? _selectedRegion;
  City? _selectedCity;

  List<Country> _countries = [];
  List<Region> _regions = [];
  List<City> _cities = [];

  bool _isLoadingCountries = false;
  bool _isLoadingRegions = false;
  bool _isLoadingCities = false;
  String? _countriesError;

  final Map<String, TextEditingController> _dynamicControllers = {};
  final Map<String, String?> _dynamicSelects = {};

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
    _regionTextController =
        TextEditingController(text: widget.model.regionState);
    _cityTextController =
        TextEditingController(text: widget.model.city);

    _loadCountries();

    // Initialize dynamic fields from category config
    final dynamicFields = widget.model.categoryConfig?.detailFields ?? [];
    for (final field in dynamicFields) {
      final existingVal = widget.model.detailFieldValues[field.fieldKey]?.toString();
      if (field.inputType == 'select') {
        _dynamicSelects[field.fieldKey] = existingVal != null && field.options.contains(existingVal)
            ? existingVal
            : null;
      } else {
        _dynamicControllers[field.fieldKey] = TextEditingController(
          text: existingVal ?? '',
        );
      }
    }
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _countriesError = null;
    });

    try {
      final countries = await MetadataService.getCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
          _isLoadingCountries = false;

          if (widget.model.countryId != null) {
            final matches = _countries.where((c) => c.id == widget.model.countryId);
            if (matches.isNotEmpty) {
              _selectedCountry = matches.first;
            }
          } else if (widget.model.country.isNotEmpty) {
            final matches = _countries.where(
              (c) => c.name.toLowerCase() == widget.model.country.toLowerCase(),
            );
            if (matches.isNotEmpty) {
              _selectedCountry = matches.first;
            }
          }

          if (_selectedCountry != null) {
            _loadRegions(_selectedCountry!.id);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCountries = false;
          _countriesError = 'Failed to load countries: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadRegions(int countryId) async {
    setState(() {
      _isLoadingRegions = true;
      _regions = [];
      _selectedRegion = null;
      _cities = [];
      _selectedCity = null;
    });

    try {
      final regions = await MetadataService.getRegions(countryId);
      if (mounted) {
        setState(() {
          _regions = regions;
          _isLoadingRegions = false;
          if (_regions.isNotEmpty) {
            if (widget.model.regionId != null) {
              final matches = _regions.where((r) => r.id == widget.model.regionId);
              if (matches.isNotEmpty) {
                _selectedRegion = matches.first;
              }
            }
            if (_selectedRegion == null && widget.model.regionState.isNotEmpty) {
              final matches = _regions.where(
                (r) => r.name.toLowerCase() == widget.model.regionState.toLowerCase(),
              );
              if (matches.isNotEmpty) {
                _selectedRegion = matches.first;
              }
            }

            if (_selectedRegion != null) {
              _loadCities(_selectedRegion!.id);
            }
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRegions = false);
    }
  }

  Future<void> _loadCities(int regionId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
    });

    try {
      final cities = await MetadataService.getCities(regionId);
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
          if (_cities.isNotEmpty) {
            if (widget.model.cityId != null) {
              final matches = _cities.where((c) => c.id == widget.model.cityId);
              if (matches.isNotEmpty) {
                _selectedCity = matches.first;
              }
            }
            if (_selectedCity == null && widget.model.city.isNotEmpty) {
              final matches = _cities.where(
                (c) => c.name.toLowerCase() == widget.model.city.toLowerCase(),
              );
              if (matches.isNotEmpty) {
                _selectedCity = matches.first;
              }
            }
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCities = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _regionTextController.dispose();
    _cityTextController.dispose();
    for (final ctrl in _dynamicControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a country'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final regionName = _selectedRegion?.name ?? _regionTextController.text.trim();
    if (regionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter region / state'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final cityName = _selectedCity?.name ?? _cityTextController.text.trim();
    if (cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter city'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? true) {
      widget.model.institutionName = _nameController.text.trim();
      widget.model.address = _addressController.text.trim();
      widget.model.country = _selectedCountry?.name ?? '';
      widget.model.countryId = _selectedCountry?.id;
      widget.model.regionState = regionName;
      widget.model.regionId = _selectedRegion?.id;
      widget.model.city = cityName;
      widget.model.cityId = _selectedCity?.id;
      widget.model.contactPerson = _contactPersonController.text.trim();
      widget.model.contactPhone = _phoneController.text.trim();
      widget.model.contactEmail = _emailController.text.trim();

      // Save dynamic fields
      final dynamicFields = widget.model.categoryConfig?.detailFields ?? [];
      for (final field in dynamicFields) {
        if (field.inputType == 'select') {
          widget.model.detailFieldValues[field.fieldKey] = _dynamicSelects[field.fieldKey];
        } else {
          final val = _dynamicControllers[field.fieldKey]?.text.trim();
          widget.model.detailFieldValues[field.fieldKey] = val;
        }
      }

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
                      if (_isLoadingCountries)
                        _buildLoadingBox('Loading countries...')
                      else if (_countriesError != null)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _countriesError!,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
                              ),
                            ),
                            TextButton(
                              onPressed: _loadCountries,
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<Country>(
                          initialValue: _selectedCountry,
                          hint: Text(
                            'Select country...',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB0BAC9),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          decoration: InputDecoration(
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
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          items: _countries.map((c) {
                            return DropdownMenuItem<Country>(
                              value: c,
                              child: Text(
                                c.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCountry = val;
                              _selectedRegion = null;
                              _selectedCity = null;
                              _regionTextController.clear();
                              _cityTextController.clear();
                              if (val != null) {
                                _loadRegions(val.id);
                              }
                            });
                          },
                          validator: (val) =>
                              val == null ? 'Please select a country' : null,
                        ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('Region / State *'),
                      if (_isLoadingRegions)
                        _buildLoadingBox('Loading regions...')
                      else if (_regions.isNotEmpty)
                        DropdownButtonFormField<Region>(
                          key: ValueKey('region_${_selectedCountry?.id}_${_selectedRegion?.id}'),
                          initialValue: _selectedRegion,
                          hint: Text(
                            'Select Region / State',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB0BAC9),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          decoration: InputDecoration(
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
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          items: _regions.map((r) {
                            return DropdownMenuItem<Region>(
                              value: r,
                              child: Text(
                                r.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedRegion = val;
                              _selectedCity = null;
                              _cityTextController.clear();
                              if (val != null) {
                                _regionTextController.text = val.name;
                                _loadCities(val.id);
                              }
                            });
                          },
                          validator: (val) =>
                              val == null && _regionTextController.text.trim().isEmpty
                                  ? 'Please select region / state'
                                  : null,
                        )
                      else
                        _buildTextField(
                          controller: _regionTextController,
                          hintText: 'Enter Region / State',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter region / state'
                              : null,
                        ),
                      const SizedBox(height: 16),

                      _buildFieldLabel('City *'),
                      if (_isLoadingCities)
                        _buildLoadingBox('Loading cities...')
                      else if (_cities.isNotEmpty)
                        DropdownButtonFormField<City>(
                          key: ValueKey('city_${_selectedRegion?.id}_${_selectedCity?.id}'),
                          initialValue: _selectedCity,
                          hint: Text(
                            'Select City',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB0BAC9),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          decoration: InputDecoration(
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
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                          ),
                          items: _cities.map((city) {
                            return DropdownMenuItem<City>(
                              value: city,
                              child: Text(
                                city.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCity = val;
                              if (val != null) {
                                _cityTextController.text = val.name;
                              }
                            });
                          },
                          validator: (val) =>
                              val == null && _cityTextController.text.trim().isEmpty
                                  ? 'Please select city'
                                  : null,
                        )
                      else
                        _buildTextField(
                          controller: _cityTextController,
                          hintText: 'Enter City',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please enter city'
                              : null,
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

                      // Category Specific Details Section
                      _buildCategorySpecificFields(),
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

  Widget _buildLoadingBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
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

  Widget _buildCategorySpecificFields() {
    final dynamicFields = widget.model.categoryConfig?.detailFields ?? [];

    if (dynamicFields.isNotEmpty) {
      final groupLabel = dynamicFields.first.groupLabel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 8),
              Text(
                groupLabel,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...dynamicFields.map((field) {
            final labelText = '${field.label}${field.isRequired ? ' *' : ''}';
            final hintText = field.placeholder ??
                (field.unit != null ? 'e.g. 100 (${field.unit})' : 'Enter ${field.label.toLowerCase()}');

            Widget inputWidget;

            if (field.inputType == 'select') {
              inputWidget = _buildDropdown(
                value: _dynamicSelects[field.fieldKey],
                hint: field.placeholder ?? 'Select...',
                items: field.options,
                onChanged: (val) {
                  setState(() {
                    _dynamicSelects[field.fieldKey] = val;
                  });
                },
              );
            } else if (field.inputType == 'number') {
              final ctrl = _dynamicControllers[field.fieldKey]!;
              inputWidget = _buildTextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                hintText: hintText,
                validator: field.isRequired
                    ? (v) => v == null || v.trim().isEmpty ? 'Please enter ${field.label.toLowerCase()}' : null
                    : null,
              );
            } else if (field.inputType == 'decimal') {
              final ctrl = _dynamicControllers[field.fieldKey]!;
              inputWidget = _buildTextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: hintText,
                validator: field.isRequired
                    ? (v) => v == null || v.trim().isEmpty ? 'Please enter ${field.label.toLowerCase()}' : null
                    : null,
              );
            } else {
              final ctrl = _dynamicControllers[field.fieldKey]!;
              inputWidget = _buildTextField(
                controller: ctrl,
                hintText: hintText,
                validator: field.isRequired
                    ? (v) => v == null || v.trim().isEmpty ? 'Please enter ${field.label.toLowerCase()}' : null
                    : null,
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(labelText),
                  inputWidget,
                ],
              ),
            );
          }),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
