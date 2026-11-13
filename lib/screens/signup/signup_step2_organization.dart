import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/meta_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/metadata_service.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/searchable_selection_sheet.dart';
import 'signup_step3_verify.dart';

import '../../data/countries_data.dart';

class SignUpStep2Screen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String phoneCountryCode;
  final String password;
  final String confirmPassword;

  const SignUpStep2Screen({
    super.key,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.phoneCountryCode = '+91',
    this.password = '',
    this.confirmPassword = '',
  });

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final _orgNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();

  List<OrganizationType> _orgTypes = [];
  List<Country> _countries = [];
  List<Region> _regions = [];
  List<City> _cities = [];

  OrganizationType? _selectedOrgType;
  Country? _selectedCountry;
  Region? _selectedRegion;
  City? _selectedCity;

  bool _isLoading = false;
  bool _isLoadingMetadata = true;
  bool _isLoadingRegions = false;
  bool _isLoadingCities = false;

  Country? _selectedContactCountry;

  @override
  void initState() {
    super.initState();
    _selectedContactCountry = CountryData.findByPhoneCode(widget.phoneCountryCode);
    _contactPersonController.text = widget.fullName;
    _contactEmailController.text = widget.email;
    _contactPhoneController.text = widget.phone;
    _loadInitialMetadata();
  }

  Future<void> _loadInitialMetadata() async {
    try {
      final types = await MetadataService.getOrganizationTypes();
      final countries = await MetadataService.getCountries();

      if (mounted) {
        setState(() {
          _orgTypes = types;
          _countries = countries;
          if (_orgTypes.isNotEmpty) _selectedOrgType = _orgTypes.first;
          if (_countries.isNotEmpty) {
            _selectedCountry = _countries.first;
            _loadRegions(_selectedCountry!.id);
          }
          _isLoadingMetadata = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMetadata = false;
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
      _regionController.clear();
      _cityController.clear();
    });

    try {
      final regions = await MetadataService.getRegions(countryId);
      if (mounted) {
        setState(() {
          _regions = regions;
          _isLoadingRegions = false;
          _selectedRegion = regions.isNotEmpty ? regions.first : null;
          if (_selectedRegion != null) {
            _regionController.text = _selectedRegion!.name;
            _loadCities(_selectedRegion!.id);
          } else {
            _cities = [];
            _selectedCity = null;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRegions = false);
      }
    }
  }

  Future<void> _loadCities(int regionId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _selectedCity = null;
      _cityController.clear();
    });

    try {
      final cities = await MetadataService.getCities(regionId);
      if (mounted) {
        setState(() {
          _cities = cities;
          _isLoadingCities = false;
          _selectedCity = cities.isNotEmpty ? cities.first : null;
          if (_selectedCity != null) {
            _cityController.text = _selectedCity!.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCities = false);
      }
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    final orgName = _orgNameController.text.trim();
    if (orgName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your organization name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedOrgType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an organization type'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a country'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final contactPhone = _contactPhoneController.text.trim();
    final contactPhoneError = CountryData.validatePhoneNumber(
      country: _selectedContactCountry ?? _selectedCountry,
      phoneNumber: contactPhone,
      isRequired: false,
      fieldName: 'contact phone',
    );
    if (contactPhoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(contactPhoneError),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final chosenState = _selectedRegion?.name ?? _regionController.text.trim();
    final chosenCity = _selectedCity?.name ?? _cityController.text.trim();

    if (chosenCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter your city'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API call: POST /api/auth/register/start
      final registerStartResult = await AuthService.registerStart(
        fullName: widget.fullName,
        email: widget.email,
        phoneCountryCode: widget.phoneCountryCode.isNotEmpty
            ? widget.phoneCountryCode
            : (_selectedCountry?.phoneCode ?? '+91'),
        phoneNumber: widget.phone,
        password: widget.password,
        confirmPassword: widget.confirmPassword.isNotEmpty
            ? widget.confirmPassword
            : widget.password,
        organizationName: orgName,
        organizationTypeId: _selectedOrgType?.id,
        countryId: _selectedCountry?.id,
        regionId: _selectedRegion?.id,
        cityId: _selectedCity?.id,
        state: chosenState,
        city: chosenCity,
        address: _addressController.text.trim(),
        contactPerson: _contactPersonController.text.trim().isNotEmpty
            ? _contactPersonController.text.trim()
            : widget.fullName,
        contactEmail: _contactEmailController.text.trim().isNotEmpty
            ? _contactEmailController.text.trim()
            : widget.email,
        contactPhoneCode: _selectedContactCountry?.phoneCode ??
            _selectedCountry?.phoneCode ??
            widget.phoneCountryCode,
        contactPhone: contactPhone.isNotEmpty ? contactPhone : widget.phone,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification code sent to ${registerStartResult.email}',
            ),
            backgroundColor: const Color(0xFF0284C7),
          ),
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SignUpStep3Screen(
              fullName: widget.fullName,
              email: widget.email,
              phone: widget.phone,
              password: widget.password,
              organizationName: orgName,
              organizationType: _selectedOrgType?.name ?? '',
              country: _selectedCountry?.name ?? '',
              state: chosenState,
              city: chosenCity,
              address: _addressController.text.trim(),
              codeLength: registerStartResult.verification.codeLength,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header
            const AuthHeader(
              title: 'Organization Details',
              subtitle: 'Tell us about your organization',
              currentStep: 2,
              totalSteps: 4,
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: _isLoadingMetadata
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  CustomTextField(
                    label: 'Organization / Institution Name',
                    hintText: 'World Health Centre',
                    controller: _orgNameController,
                  ),
                  const SizedBox(height: 16),

                  // Organization Type
                  SearchableDropdownField<OrganizationType>(
                    label: 'Organization Type',
                    value: _selectedOrgType,
                    hintText: 'Select type...',
                    sheetTitle: 'Select Organization Type',
                    items: _orgTypes,
                    itemLabel: (type) => type.name,
                    onChanged: (val) {
                      setState(() {
                        _selectedOrgType = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Country
                  if (_isLoadingMetadata)
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
                            'Loading countries from server...',
                            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else
                    SearchableDropdownField<Country>(
                      label: 'Country',
                      value: _selectedCountry,
                      hintText: 'Select Country',
                      sheetTitle: 'Select Country',
                      items: _countries,
                      itemLabel: (country) => country.name,
                      onChanged: (val) {
                        setState(() {
                          _selectedCountry = val;
                          if (val != null) {
                            _loadRegions(val.id);
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 16),

                  // Region / State
                  if (_isLoadingRegions)
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
                            'Loading regions...',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else if (_regions.isNotEmpty)
                    SearchableDropdownField<Region>(
                      label: 'Region / State',
                      value: _selectedRegion,
                      hintText: 'Select Region / State',
                      sheetTitle: 'Select Region / State',
                      items: _regions,
                      itemLabel: (region) => region.name,
                      onChanged: (val) {
                        setState(() {
                          _selectedRegion = val;
                          if (val != null) {
                            _regionController.text = val.name;
                            _loadCities(val.id);
                          }
                        });
                      },
                    )
                  else
                    CustomTextField(
                      label: 'Region / State',
                      hintText: 'e.g. Maharashtra, Nairobi County, Texas',
                      controller: _regionController,
                    ),
                  const SizedBox(height: 16),

                  // City
                  if (_isLoadingCities)
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
                            'Loading cities...',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    )
                  else if (_cities.isNotEmpty)
                    SearchableDropdownField<City>(
                      label: 'City',
                      value: _selectedCity,
                      hintText: 'Select City',
                      sheetTitle: 'Select City',
                      items: _cities,
                      itemLabel: (city) => city.name,
                      onChanged: (val) {
                        setState(() {
                          _selectedCity = val;
                          if (val != null) {
                            _cityController.text = val.name;
                          }
                        });
                      },
                    )
                  else
                    CustomTextField(
                      label: 'City',
                      hintText: 'Enter City',
                      controller: _cityController,
                    ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Address',
                    hintText: 'Street address',
                    controller: _addressController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Contact Person',
                    hintText: 'Full name',
                    controller: _contactPersonController,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Contact Email',
                    hintText: 'contact@org.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _contactEmailController,
                  ),
                  const SizedBox(height: 16),

                  CountryPhoneInputField(
                    label: 'Contact Phone',
                    hintText: 'Enter contact phone',
                    controller: _contactPhoneController,
                    initialCountry: _selectedContactCountry ?? _selectedCountry,
                    onCountryChanged: (c) {
                      setState(() {
                        _selectedContactCountry = c;
                      });
                    },
                  ),
                  const SizedBox(height: 28),

                  // Continue Button
                  PrimaryButton(
                    text: 'Continue',
                    isLoading: _isLoading,
                    onPressed: _onContinue,
                  ),
                  const SizedBox(height: 56),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
