import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/meta_models.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../services/metadata_service.dart';
import '../../../../widgets/custom_button.dart';

class Step3DateLocation extends StatefulWidget {
  final ProgramSubmissionModel model;
  final VoidCallback onContinue;

  const Step3DateLocation({
    super.key,
    required this.model,
    required this.onContinue,
  });

  @override
  State<Step3DateLocation> createState() => _Step3DateLocationState();
}

class _Step3DateLocationState extends State<Step3DateLocation> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _regionController;
  late TextEditingController _cityController;
  late TextEditingController _venueController;

  List<Country> _countries = [];
  Country? _selectedCountry;
  bool _isLoadingCountries = true;
  String? _countriesError;

  List<Region> _regions = [];
  Region? _selectedRegion;
  bool _isLoadingRegions = false;

  List<City> _cities = [];
  City? _selectedCity;
  bool _isLoadingCities = false;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.model.startDate;
    _endDate = widget.model.endDate;
    _startDateController = TextEditingController(
      text: _startDate != null ? _formatDate(_startDate!) : '',
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? _formatDate(_endDate!) : '',
    );
    _regionController = TextEditingController(text: widget.model.regionState);
    _cityController = TextEditingController(text: widget.model.city);
    _venueController = TextEditingController(text: widget.model.venueAddress);
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _countriesError = null;
    });

    try {
      // Fetch countries from backend API
      final countries = await MetadataService.getCountries();
      if (mounted) {
        setState(() {
          _countries = countries;
          _isLoadingCountries = false;

          // Match by country_id only if user had previously chosen one
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
            // Match region strictly by region_id (e.g. region_id == 6)
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
              widget.model.regionState = _selectedRegion!.name;
              widget.model.regionId = _selectedRegion!.id;
              _regionController.text = _selectedRegion!.name;
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
            // Match city strictly by city_id (e.g. city_id == 22)
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

            if (_selectedCity != null) {
              widget.model.city = _selectedCity!.name;
              widget.model.cityId = _selectedCity!.id;
              _cityController.text = _selectedCity!.name;
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
    _startDateController.dispose();
    _endDateController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text = _formatDate(picked);
          if (_endDate == null || _endDate!.isBefore(_startDate!)) {
            _endDate = picked;
            _endDateController.text = _formatDate(picked);
          }
        } else {
          _endDate = picked;
          _endDateController.text = _formatDate(picked);
        }
      });
    }
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.model.startDate = _startDate;
      widget.model.endDate = _endDate ?? _startDate;
      widget.model.country = _selectedCountry?.name ?? '';
      widget.model.countryId = _selectedCountry?.id;
      widget.model.regionState = _selectedRegion?.name ?? _regionController.text.trim();
      widget.model.regionId = _selectedRegion?.id;
      widget.model.city = _selectedCity?.name ?? _cityController.text.trim();
      widget.model.cityId = _selectedCity?.id;
      widget.model.venueAddress = _venueController.text.trim().isNotEmpty
          ? _venueController.text.trim()
          : 'To be announced';
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
          // Start Date
          _buildFieldLabel('Start Date *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _startDateController,
            readOnly: true,
            onTap: () => _pickDate(true),
            decoration: const InputDecoration(
              hintText: 'YYYY-MM-DD',
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
            ),
            validator: (val) => val == null || val.isEmpty ? 'Please select start date' : null,
          ),
          const SizedBox(height: 16),

          // End Date
          _buildFieldLabel('End Date (Optional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _endDateController,
            readOnly: true,
            onTap: () => _pickDate(false),
            decoration: const InputDecoration(
              hintText: 'YYYY-MM-DD (Defaults to start date)',
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 16),

          // Country (Backend API)
          _buildFieldLabel('Country *'),
          const SizedBox(height: 6),
          if (_isLoadingCountries)
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
          else if (_countriesError != null)
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
                      _countriesError!,
                      style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFB91C1C)),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadCountries,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<Country>(
              initialValue: _selectedCountry,
              hint: Text(
                'Select country',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _countries.map((country) {
                return DropdownMenuItem<Country>(
                  value: country,
                  child: Text(
                    country.name,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCountry = val;
                  if (val != null) {
                    _loadRegions(val.id);
                  }
                });
              },
              validator: (val) =>
                  val == null ? 'Please select country' : null,
            ),
          const SizedBox(height: 16),

          // Region / State
          _buildFieldLabel('Region / State'),
          const SizedBox(height: 6),
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
            DropdownButtonFormField<Region>(
              initialValue: _selectedRegion,
              hint: Text(
                'Select region / state',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _regions.map((region) {
                return DropdownMenuItem<Region>(
                  value: region,
                  child: Text(
                    region.name,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
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
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(
                hintText: 'e.g. Maharashtra, Nairobi County, Texas',
              ),
            ),
          const SizedBox(height: 16),

          // City
          _buildFieldLabel('City *'),
          const SizedBox(height: 6),
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
            DropdownButtonFormField<City>(
              initialValue: _selectedCity,
              hint: Text(
                'Select city',
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: _cities.map((city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(
                    city.name,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCity = val;
                  if (val != null) {
                    _cityController.text = val.name;
                  }
                });
              },
              validator: (val) =>
                  val == null && _cityController.text.trim().isEmpty ? 'Please select or enter city' : null,
            )
          else
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'e.g. Mumbai, Nairobi, London',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter city' : null,
            ),
          const SizedBox(height: 16),

          // Venue Address
          _buildFieldLabel('Venue Address (Optional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _venueController,
            decoration: const InputDecoration(
              hintText: 'Full venue address or online location',
            ),
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
