import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/app_bloc.dart';
import '../../bloc/app_event.dart';
import '../../core/theme.dart';
import '../../models/meta_models.dart';
import '../../services/account_service.dart';
import '../../services/metadata_service.dart';

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
  late TextEditingController _contactPersonController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;

  late String _selectedOrgType;
  int? _selectedOrgTypeId;
  int? _countryId;
  int? _regionId;
  int? _cityId;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _orgTypes = [
    'Institution',
    'College / University',
    'Hospital / Healthcare Facility',
    'Research Institute',
    'Non-Profit / NGO',
    'Other',
  ];
  final List<OrganizationType> _backendOrgTypesList = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AppBloc>().state.user;
    _orgNameController = TextEditingController(text: user.organizationName);
    _selectedOrgType = _orgTypes.contains(user.organizationType)
        ? user.organizationType
        : _orgTypes.first;
    _selectedOrgTypeId = user.organizationTypeId;
    _countryId = user.countryId;
    _regionId = user.regionId;
    _cityId = user.cityId;

    _countryController = TextEditingController(text: user.country);
    _stateController = TextEditingController(
      text: user.state.isNotEmpty ? user.state : '',
    );
    _cityController = TextEditingController(
      text: user.city.isNotEmpty ? user.city : '',
    );
    _addressController = TextEditingController(
      text: user.address.isNotEmpty ? user.address : '',
    );
    _contactPersonController = TextEditingController(
      text: user.fullName.isNotEmpty ? user.fullName : '',
    );
    _contactEmailController = TextEditingController(
      text: user.contactEmail.isNotEmpty ? user.contactEmail : '',
    );
    _contactPhoneController = TextEditingController(
      text: user.contactPhone.isNotEmpty ? user.contactPhone : '',
    );

    _fetchOrganizationDetails();
  }

  Future<void> _fetchOrganizationDetails() async {
    try {
      final org = await AccountService.getOrganizationDetails();

      String resolvedOrgName = org.name.isNotEmpty ? org.name : _orgNameController.text;
      String resolvedCountry = org.country.isNotEmpty ? org.country : _countryController.text;
      String resolvedRegion = (org.region != null && org.region!.isNotEmpty)
          ? org.region!
          : _stateController.text;
      String resolvedCity = (org.city != null && org.city!.isNotEmpty)
          ? org.city!
          : _cityController.text;
      String resolvedOrgType = org.organizationType.isNotEmpty
          ? org.organizationType
          : _selectedOrgType;

      int? effectiveOrgTypeId = org.organizationTypeId ?? _selectedOrgTypeId;
      int? effectiveCountryId = org.countryId ?? _countryId;
      int? effectiveRegionId = org.regionId ?? _regionId;
      int? effectiveCityId = org.cityId ?? _cityId;

      // 1. Fetch backend dynamic Organization Types
      try {
        final backendOrgTypes = await MetadataService.getOrganizationTypes();
        _backendOrgTypesList.clear();
        _backendOrgTypesList.addAll(backendOrgTypes);

        for (final t in backendOrgTypes) {
          if (!_orgTypes.contains(t.name)) {
            _orgTypes.add(t.name);
          }
        }
        if (effectiveOrgTypeId != null) {
          final matched = backendOrgTypes.where((t) => t.id == effectiveOrgTypeId).firstOrNull;
          if (matched != null) {
            resolvedOrgType = matched.name;
          }
        } else if (resolvedOrgType.isNotEmpty) {
          final matched = backendOrgTypes.where((t) => t.name.toLowerCase() == resolvedOrgType.toLowerCase()).firstOrNull;
          if (matched != null) {
            effectiveOrgTypeId = matched.id;
          }
        }
      } catch (_) {}

      // 2. Resolve Country Name / ID
      if (effectiveCountryId != null && resolvedCountry.isEmpty) {
        try {
          final countries = await MetadataService.getCountries();
          final matched = countries.where((c) => c.id == effectiveCountryId).firstOrNull;
          if (matched != null) {
            resolvedCountry = matched.name;
          }
        } catch (_) {}
      } else if (resolvedCountry.isNotEmpty && effectiveCountryId == null) {
        try {
          final countries = await MetadataService.getCountries();
          final matched = countries.where((c) => c.name.toLowerCase() == resolvedCountry.toLowerCase()).firstOrNull;
          if (matched != null) {
            effectiveCountryId = matched.id;
          }
        } catch (_) {}
      }

      // 3. Resolve Region/State Name from region_id if region string is missing
      if (resolvedRegion.isEmpty && effectiveRegionId != null) {
        try {
          final regions = await MetadataService.getRegions(effectiveCountryId ?? 1);
          final matched = regions.where((r) => r.id == effectiveRegionId).firstOrNull;
          if (matched != null) {
            resolvedRegion = matched.name;
          }
        } catch (_) {}
      }

      // 4. Resolve City Name from city_id if city string is missing
      if (resolvedCity.isEmpty && effectiveRegionId != null && effectiveCityId != null) {
        try {
          final cities = await MetadataService.getCities(effectiveRegionId);
          final matched = cities.where((c) => c.id == effectiveCityId).firstOrNull;
          if (matched != null) {
            resolvedCity = matched.name;
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _selectedOrgTypeId = effectiveOrgTypeId;
          _countryId = effectiveCountryId;
          _regionId = effectiveRegionId;
          _cityId = effectiveCityId;

          if (resolvedOrgName.isNotEmpty) _orgNameController.text = resolvedOrgName;
          if (resolvedCountry.isNotEmpty) _countryController.text = resolvedCountry;
          if (resolvedRegion.isNotEmpty) _stateController.text = resolvedRegion;
          if (resolvedCity.isNotEmpty) _cityController.text = resolvedCity;
          if (org.address.isNotEmpty) _addressController.text = org.address;
          if (org.contactPerson.isNotEmpty) _contactPersonController.text = org.contactPerson;
          if (org.contactEmail.isNotEmpty) _contactEmailController.text = org.contactEmail;
          if (org.contactPhone.isNotEmpty) _contactPhoneController.text = org.contactPhone;

          if (resolvedOrgType.isNotEmpty) {
            if (!_orgTypes.contains(resolvedOrgType)) {
              _orgTypes.add(resolvedOrgType);
            }
            _selectedOrgType = resolvedOrgType;
          }
          _isLoading = false;
        });

        // Also synchronize AppBloc user state so cached state/city are updated
        context.read<AppBloc>().add(
          UpdateUserProfileRequested(
            organizationName: resolvedOrgName,
            organizationType: _selectedOrgType,
            country: resolvedCountry,
            state: resolvedRegion,
            city: resolvedCity,
            address: org.address.isNotEmpty ? org.address : _addressController.text,
            contactEmail: org.contactEmail.isNotEmpty ? org.contactEmail : _contactEmailController.text,
            contactPhone: org.contactPhone.isNotEmpty ? org.contactPhone : _contactPhoneController.text,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      final orgName = _orgNameController.text.trim();
      final address = _addressController.text.trim();
      final contactPerson = _contactPersonController.text.trim();
      final contactEmail = _contactEmailController.text.trim();
      final contactPhone = _contactPhoneController.text.trim();

      // Resolve orgTypeId if null
      int? orgTypeId = _selectedOrgTypeId;
      if (orgTypeId == null && _backendOrgTypesList.isNotEmpty) {
        final match = _backendOrgTypesList
            .where((t) => t.name.toLowerCase() == _selectedOrgType.toLowerCase())
            .firstOrNull;
        if (match != null) {
          orgTypeId = match.id;
        }
      }

      try {
        await AccountService.updateOrganizationDetails(
          name: orgName.isNotEmpty ? orgName : null,
          address: address.isNotEmpty ? address : null,
          contactPerson: contactPerson.isNotEmpty ? contactPerson : null,
          contactEmail: contactEmail.isNotEmpty ? contactEmail : null,
          contactPhone: contactPhone.isNotEmpty ? contactPhone : null,
          organizationTypeId: orgTypeId,
          countryId: _countryId,
          regionId: _regionId,
          cityId: _cityId,
        );

        if (mounted) {
          context.read<AppBloc>().add(
                UpdateUserProfileRequested(
                  organizationName: orgName,
                  organizationType: _selectedOrgType,
                  country: _countryController.text.trim(),
                  state: _stateController.text.trim(),
                  city: _cityController.text.trim(),
                  address: address,
                  contactEmail: contactEmail,
                  contactPhone: contactPhone,
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

          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update organization details: $e',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : Column(
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
                      ),
                      const SizedBox(height: 20),

                      // City
                      _buildFieldLabel('City'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _cityController,
                        hintText: 'City',
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

                      // Contact Person
                      _buildFieldLabel('Contact Person'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _contactPersonController,
                        hintText: 'Full name of contact person',
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
                        hintText: '+91 9876543210',
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
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
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
                final match = _backendOrgTypesList
                    .where((t) => t.name.toLowerCase() == newValue.toLowerCase())
                    .firstOrNull;
                if (match != null) {
                  _selectedOrgTypeId = match.id;
                }
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
