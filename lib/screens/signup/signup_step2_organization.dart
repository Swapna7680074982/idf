import 'package:flutter/material.dart';
import '../../models/meta_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/metadata_service.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'signup_step3_verify.dart';

class SignUpStep2Screen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  const SignUpStep2Screen({
    super.key,
    this.fullName = '',
    this.email = '',
    this.phone = '',
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

  @override
  void initState() {
    super.initState();
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
    try {
      final regions = await MetadataService.getRegions(countryId);
      if (mounted) {
        setState(() {
          _regions = regions;
          _selectedRegion = regions.isNotEmpty ? regions.first : null;
          if (_selectedRegion != null) {
            _loadCities(_selectedRegion!.id);
          } else {
            _cities = [];
            _selectedCity = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCities(int regionId) async {
    debugPrint('🏙️ [SIGNUP STEP 2] Fetching cities for regionId: $regionId...');
    try {
      final cities = await MetadataService.getCities(regionId);
      debugPrint('🏙️ [SIGNUP STEP 2] Received ${cities.length} cities:');
      for (final c in cities) {
        debugPrint('   -> [City ID: ${c.id}] ${c.name}');
      }
      if (mounted) {
        setState(() {
          _cities = cities;
          _selectedCity = cities.isNotEmpty ? cities.first : null;
        });
      }
    } catch (e) {
      debugPrint('❌ [SIGNUP STEP 2] Error loading cities: $e');
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
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

    setState(() {
      _isLoading = true;
    });

    try {
      // API call: POST /api/auth/register/start
      final registerStartResult = await AuthService.registerStart(
        fullName: widget.fullName,
        email: widget.email,
        phoneCountryCode: _selectedCountry?.phoneCode ?? '+91',
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
        address: _addressController.text.trim(),
        contactPerson: _contactPersonController.text.trim().isNotEmpty
            ? _contactPersonController.text.trim()
            : widget.fullName,
        contactEmail: _contactEmailController.text.trim().isNotEmpty
            ? _contactEmailController.text.trim()
            : widget.email,
        contactPhoneCode: _selectedCountry?.phoneCode ?? '+91',
        contactPhone: _contactPhoneController.text.trim().isNotEmpty
            ? _contactPhoneController.text.trim()
            : widget.phone,
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
              state: _selectedRegion?.name ?? '',
              city: _selectedCity?.name ?? '',
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
                  CustomDropdownField(
                    label: 'Organization Type',
                    hintText: 'Select type...',
                    value: _selectedOrgType?.name,
                    items: _orgTypes.map((o) => o.name).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedOrgType = _orgTypes.firstWhere(
                          (o) => o.name == val,
                          orElse: () => _orgTypes.first,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Country
                  CustomDropdownField(
                    label: 'Country',
                    hintText: 'Select Country',
                    value: _selectedCountry?.name,
                    items: _countries.map((c) => c.name).toList(),
                    onChanged: (val) {
                      final country = _countries.firstWhere(
                        (c) => c.name == val,
                        orElse: () => _countries.first,
                      );
                      setState(() {
                        _selectedCountry = country;
                      });
                      _loadRegions(country.id);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Region / State
                  CustomDropdownField(
                    label: 'Region / State',
                    hintText: 'Select Region / State',
                    value: _selectedRegion?.name,
                    items: _regions.map((r) => r.name).toList(),
                    onChanged: (val) {
                      final region = _regions.firstWhere(
                        (r) => r.name == val,
                        orElse: () => _regions.first,
                      );
                      setState(() {
                        _selectedRegion = region;
                      });
                      _loadCities(region.id);
                    },
                  ),
                  const SizedBox(height: 16),

                  // City
                  CustomDropdownField(
                    label: 'City',
                    hintText: 'Select City',
                    value: _selectedCity?.name,
                    items: _cities.map((c) => c.name).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCity = _cities.firstWhere(
                          (c) => c.name == val,
                          orElse: () => _cities.first,
                        );
                      });
                    },
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

                  CustomTextField(
                    label: 'Contact Phone',
                    hintText: 'Enter contact phone',
                    keyboardType: TextInputType.phone,
                    controller: _contactPhoneController,
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
