import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/date_time_utils.dart';
import '../../../../core/theme.dart';
import '../../../../core/capitalization_formatter.dart';
import '../../../../models/meta_models.dart';
import '../../../../models/program_submission_model.dart';
import '../../../../services/metadata_service.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/searchable_selection_sheet.dart';

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
  late TextEditingController _pincodeController;
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
    _pincodeController = TextEditingController(text: widget.model.pincode);
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
          if (widget.model.countryId != null && widget.model.countryId! > 0) {
            final matches = _countries.where((c) => c.id == widget.model.countryId);
            if (matches.isNotEmpty) {
              _selectedCountry = matches.first;
            }
          }
          if (_selectedCountry == null && widget.model.country.trim().isNotEmpty) {
            final target = widget.model.country.trim().toLowerCase();
            final matches = _countries.where(
              (c) => c.name.trim().toLowerCase() == target,
            );
            if (matches.isNotEmpty) {
              _selectedCountry = matches.first;
            }
          }
          if (_selectedCountry == null && widget.model.country.trim().isNotEmpty) {
            final target = widget.model.country.trim().toLowerCase();
            final matches = _countries.where(
              (c) => c.name.trim().toLowerCase().contains(target) || target.contains(c.name.trim().toLowerCase()),
            );
            if (matches.isNotEmpty) {
              _selectedCountry = matches.first;
            }
          }
          if (_selectedCountry == null && widget.model.country.trim().isNotEmpty) {
            final customCountry = Country(
              id: widget.model.countryId != null && widget.model.countryId! > 0
                  ? widget.model.countryId!
                  : -1,
              isoCode: '',
              name: widget.model.country.trim(),
              phoneCode: '',
            );
            _countries.insert(0, customCountry);
            _selectedCountry = customCountry;
          }

          if (_selectedCountry != null) {
            widget.model.country = _selectedCountry!.name;
            if (_selectedCountry!.id > 0) {
              widget.model.countryId = _selectedCountry!.id;
              _loadRegions(_selectedCountry!.id);
            }
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
            // Match region strictly by region_id
            if (widget.model.regionId != null && widget.model.regionId! > 0) {
              final matches = _regions.where((r) => r.id == widget.model.regionId);
              if (matches.isNotEmpty) {
                _selectedRegion = matches.first;
              }
            }
            if (_selectedRegion == null && widget.model.regionState.trim().isNotEmpty) {
              final target = widget.model.regionState.trim().toLowerCase();
              final matches = _regions.where(
                (r) => r.name.trim().toLowerCase() == target,
              );
              if (matches.isNotEmpty) {
                _selectedRegion = matches.first;
              }
            }
            if (_selectedRegion == null && widget.model.regionState.trim().isNotEmpty) {
              final target = widget.model.regionState.trim().toLowerCase();
              final matches = _regions.where((r) {
                final rName = r.name.trim().toLowerCase();
                return rName.contains(target) || target.contains(rName);
              });
              if (matches.isNotEmpty) {
                _selectedRegion = matches.first;
              }
            }
            if (_selectedRegion == null && widget.model.regionState.trim().isNotEmpty) {
              final customRegion = Region(
                id: widget.model.regionId != null && widget.model.regionId! > 0
                    ? widget.model.regionId!
                    : -1,
                name: widget.model.regionState.trim(),
              );
              _regions.insert(0, customRegion);
              _selectedRegion = customRegion;
            }

            if (_selectedRegion != null) {
              widget.model.regionState = _selectedRegion!.name;
              _regionController.text = _selectedRegion!.name;
              if (_selectedRegion!.id > 0) {
                widget.model.regionId = _selectedRegion!.id;
                _loadCities(_selectedRegion!.id);
              }
            }
          } else {
            if (widget.model.regionState.trim().isNotEmpty) {
              _regionController.text = widget.model.regionState.trim();
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRegions = false;
          if (widget.model.regionState.trim().isNotEmpty) {
            _regionController.text = widget.model.regionState.trim();
          }
        });
      }
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
            // Match city strictly by city_id
            if (widget.model.cityId != null && widget.model.cityId! > 0) {
              final matches = _cities.where((c) => c.id == widget.model.cityId);
              if (matches.isNotEmpty) {
                _selectedCity = matches.first;
              }
            }
            if (_selectedCity == null && widget.model.city.trim().isNotEmpty) {
              final target = widget.model.city.trim().toLowerCase();
              final matches = _cities.where(
                (c) => c.name.trim().toLowerCase() == target,
              );
              if (matches.isNotEmpty) {
                _selectedCity = matches.first;
              }
            }
            if (_selectedCity == null && widget.model.city.trim().isNotEmpty) {
              final target = widget.model.city.trim().toLowerCase();
              final matches = _cities.where((c) {
                final cName = c.name.trim().toLowerCase();
                return cName.contains(target) || target.contains(cName);
              });
              if (matches.isNotEmpty) {
                _selectedCity = matches.first;
              }
            }
            if (_selectedCity == null && widget.model.city.trim().isNotEmpty) {
              final customCity = City(
                id: widget.model.cityId != null && widget.model.cityId! > 0
                    ? widget.model.cityId!
                    : -1,
                name: widget.model.city.trim(),
                pincode: widget.model.pincode.isNotEmpty ? widget.model.pincode : null,
              );
              _cities.insert(0, customCity);
              _selectedCity = customCity;
            }

            if (_selectedCity != null) {
              widget.model.city = _selectedCity!.name;
              _cityController.text = _selectedCity!.name;
              if (_selectedCity!.id > 0) {
                widget.model.cityId = _selectedCity!.id;
              }
            }
          } else {
            if (widget.model.city.trim().isNotEmpty) {
              _cityController.text = widget.model.city.trim();
            }
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
          if (widget.model.city.trim().isNotEmpty) {
            _cityController.text = widget.model.city.trim();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    return DateTimeUtils.formatDateOnly(dt);
  }

  Future<void> _pickDate(bool isStart) async {
    if (!isStart && _startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date first'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime initialDate;
    final DateTime firstDate;

    if (isStart) {
      // Based on current date, hide/disable all previous past dates
      firstDate = today;
      initialDate = (_startDate != null && !_startDate!.isBefore(today))
          ? _startDate!
          : today;
    } else {
      // Disables all dates before selected start date (and before today)
      final minDate = (_startDate != null && !_startDate!.isBefore(today))
          ? _startDate!
          : today;
      firstDate = minDate;
      initialDate = (_endDate != null && !_endDate!.isBefore(firstDate))
          ? _endDate!
          : firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      selectableDayPredicate: (DateTime day) {
        final dayOnly = DateTime(day.year, day.month, day.day);
        return !dayOnly.isBefore(firstDate);
      },
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
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
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
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_startDate!.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be in the past. Please select today or a future date.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an end date'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date cannot be before start date'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a country'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      widget.model.startDate = _startDate;
      widget.model.endDate = _endDate;
      widget.model.country = _selectedCountry?.name ?? '';
      widget.model.countryId = _selectedCountry?.id;
      widget.model.regionState = _selectedRegion?.name ?? _regionController.text.trim();
      widget.model.regionId = _selectedRegion?.id;
      widget.model.city = _selectedCity?.name ?? _cityController.text.trim();
      widget.model.cityId = _selectedCity?.id;
      widget.model.pincode = _pincodeController.text.trim();
      widget.model.venueAddress = _venueController.text.trim().isNotEmpty
          ? _venueController.text.trim()
          : 'To be announced';
      widget.onContinue();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all required dates and location fields'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              hintText: 'DD MMM YYYY',
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please select start date';
              }
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              if (_startDate != null && _startDate!.isBefore(today)) {
                return 'Start date cannot be in the past';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // End Date (Mandatory, dates before Start Date are disabled)
          _buildFieldLabel('End Date *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _endDateController,
            readOnly: true,
            onTap: () => _pickDate(false),
            decoration: const InputDecoration(
              hintText: 'DD MMM YYYY',
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please select end date';
              }
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              if (_endDate != null && _endDate!.isBefore(today)) {
                return 'End date cannot be in the past';
              }
              if (_startDate != null && _endDate != null && _endDate!.isBefore(_startDate!)) {
                return 'End date cannot be before start date';
              }
              return null;
            },
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
            SearchableDropdownField<Country>(
              value: _selectedCountry,
              hintText: 'Select country',
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
            SearchableDropdownField<Region>(
              key: ValueKey('region_${_selectedCountry?.id}_${_selectedRegion?.id}_${_selectedRegion?.name}'),
              value: _selectedRegion,
              hintText: 'Select region / state',
              sheetTitle: 'Select Region / State',
              items: _regions,
              itemLabel: (region) => region.name,
              onChanged: (val) {
                setState(() {
                  _selectedRegion = val;
                  if (val != null) {
                    widget.model.regionState = val.name;
                    widget.model.regionId = val.id > 0 ? val.id : null;
                    _regionController.text = val.name;
                    if (val.id > 0) {
                      _loadCities(val.id);
                    } else {
                      _cities = [];
                    }
                  } else {
                    widget.model.regionState = '';
                    widget.model.regionId = null;
                  }
                });
              },
            )
          else
            TextFormField(
              controller: _regionController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              inputFormatters: const [CapitalizeFirstLetterFormatter(words: true)],
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
            SearchableDropdownField<City>(
              key: ValueKey('city_${_selectedRegion?.id}_${_selectedCity?.id}_${_selectedCity?.name}'),
              value: _selectedCity,
              hintText: 'Select city',
              sheetTitle: 'Select City',
              items: _cities,
              itemLabel: (city) => city.name,
              onChanged: (val) {
                setState(() {
                  _selectedCity = val;
                  if (val != null) {
                    widget.model.city = val.name;
                    widget.model.cityId = val.id > 0 ? val.id : null;
                    _cityController.text = val.name;
                    if (val.pincode != null && val.pincode!.isNotEmpty) {
                      _pincodeController.text = val.pincode!;
                      widget.model.pincode = val.pincode!;
                    }
                  } else {
                    widget.model.city = '';
                    widget.model.cityId = null;
                  }
                });
              },
              validator: (val) =>
                  val == null && _cityController.text.trim().isEmpty ? 'Please select or enter city' : null,
            )
          else
            TextFormField(
              controller: _cityController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              inputFormatters: const [CapitalizeFirstLetterFormatter(words: true)],
              decoration: const InputDecoration(
                hintText: 'e.g. Mumbai, Nairobi, London',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter city' : null,
            ),
          const SizedBox(height: 16),

          // Pincode / Postal Code
          _buildFieldLabel('Pincode / Postal Code *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _pincodeController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: 'e.g. 400001 or W1A 1AA',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter pincode / postal code' : null,
          ),
          const SizedBox(height: 16),

          // Venue Address
          _buildFieldLabel('Venue Address (Optional)'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _venueController,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: const [CapitalizeFirstLetterFormatter(words: false)],
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
