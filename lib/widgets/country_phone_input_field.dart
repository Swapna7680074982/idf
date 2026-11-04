import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../data/countries_data.dart';
import '../models/meta_models.dart';

/// Searchable modal bottom sheet to pick a country and its dial code.
class CountryPhonePickerSheet extends StatefulWidget {
  final Country? selectedCountry;
  final ValueChanged<Country> onSelect;
  final List<Country>? countries;

  const CountryPhonePickerSheet({
    super.key,
    this.selectedCountry,
    required this.onSelect,
    this.countries,
  });

  static Future<Country?> show(
    BuildContext context, {
    Country? selectedCountry,
    List<Country>? countries,
  }) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CountryPhonePickerSheet(
        selectedCountry: selectedCountry,
        countries: countries,
        onSelect: (country) => Navigator.of(ctx).pop(country),
      ),
    );
  }

  @override
  State<CountryPhonePickerSheet> createState() => _CountryPhonePickerSheetState();
}

class _CountryPhonePickerSheetState extends State<CountryPhonePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<Country> _allList;
  List<Country> _filteredList = [];

  @override
  void initState() {
    super.initState();
    final base = widget.countries != null && widget.countries!.isNotEmpty
        ? widget.countries!
        : CountryData.currentCountries;
    final list = List<Country>.from(base);
    if (!list.any((c) => c.isoCode == 'OT' || c.name.toLowerCase() == 'other')) {
      list.add(CountryData.otherCountry);
    }
    _allList = list;
    _filteredList = _allList;
    _loadDynamicCountries();
  }

  Future<void> _loadDynamicCountries() async {
    try {
      final dynamicList = await CountryData.fetchDynamicCountries();
      if (mounted && dynamicList.isNotEmpty) {
        final list = List<Country>.from(dynamicList);
        if (!list.any((c) => c.isoCode == 'OT' || c.name.toLowerCase() == 'other')) {
          list.add(CountryData.otherCountry);
        }
        setState(() {
          _allList = list;
          _onSearch(_searchController.text);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final clean = query.trim().toLowerCase();
    setState(() {
      if (clean.isEmpty) {
        _filteredList = _allList;
      } else {
        _filteredList = _allList.where((country) {
          final nameMatch = country.name.toLowerCase().contains(clean);
          final isoMatch = country.isoCode.toLowerCase().contains(clean);
          final codeMatch = country.phoneCode
              .replaceAll('+', '')
              .toLowerCase()
              .contains(clean.replaceAll('+', ''));
          return nameMatch || isoMatch || codeMatch;
        }).toList();
      }
    });
  }

  Future<void> _handleSelectCountry(Country item) async {
    if (item.isoCode == 'OT') {
      final customCodeCtrl = TextEditingController(text: '+');
      final customCode = await showDialog<String>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Custom Dial Code',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter custom country dial code or skip to use default "+":',
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customCodeCtrl,
                keyboardType: TextInputType.phone,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\+]')),
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: InputDecoration(
                  hintText: '+123',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, '+'),
              child: Text('Skip (+)', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              onPressed: () {
                final text = customCodeCtrl.text.trim();
                final formatted = text.isEmpty ? '+' : (text.startsWith('+') ? text : '+$text');
                Navigator.pop(dialogCtx, formatted);
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      final chosenCode = customCode ?? '+';
      widget.onSelect(Country(
        id: 0,
        isoCode: 'OT',
        name: 'Other',
        phoneCode: chosenCode,
      ));
      return;
    }
    widget.onSelect(item);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.82;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Country & Dial Code',
                        style: GoogleFonts.inter(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Search by country name, ISO code, or dial code',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Search (e.g. India, +91, US, Kenya)...',
                  hintStyle: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Country List
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No countries found',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try a different country name or dial code',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: _filteredList.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredList[index];
                      final isSelected = widget.selectedCountry?.id == item.id ||
                          widget.selectedCountry?.phoneCode == item.phoneCode &&
                              widget.selectedCountry?.isoCode == item.isoCode;

                      return InkWell(
                        onTap: () => _handleSelectCountry(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: isSelected ? const Color(0xFFF0FDF4) : Colors.transparent,
                          child: Row(
                            children: [
                              // Flag Emoji
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  item.flagEmoji,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name + ISO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Dial Code badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.phoneCode,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ),

                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive International Phone Input Field with:
/// 1. Country code dropdown/bottom sheet selector with search
/// 2. Country name, ISO code, dial code and flag emoji display
/// 3. Digits-only input enforcement (digitsOnly formatter)
/// 4. Length and digit validation for all countries
class CountryPhoneInputField extends StatefulWidget {
  final String? label;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<Country>? onCountryChanged;
  final Country? initialCountry;
  final String? initialPhoneCode;
  final String? initialIsoCode;
  final List<Country>? countries;
  final bool isRequired;
  final bool enabled;
  final bool showHelperNearField;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const CountryPhoneInputField({
    super.key,
    this.label,
    this.hintText = 'Phone number',
    this.controller,
    this.onChanged,
    this.onCountryChanged,
    this.initialCountry,
    this.initialPhoneCode,
    this.initialIsoCode,
    this.countries,
    this.isRequired = true,
    this.enabled = true,
    this.showHelperNearField = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<CountryPhoneInputField> createState() => CountryPhoneInputFieldState();
}

class CountryPhoneInputFieldState extends State<CountryPhoneInputField> {
  late Country _selectedCountry;

  Country get selectedCountry => _selectedCountry;
  String get phoneCode => _selectedCountry.phoneCode;

  @override
  void initState() {
    super.initState();
    _initCountry();
    _loadDynamicCountries();
  }

  Future<void> _loadDynamicCountries() async {
    try {
      await CountryData.fetchDynamicCountries();
      if (mounted) {
        setState(() {
          if (widget.initialCountry == null &&
              widget.initialPhoneCode != null &&
              widget.initialPhoneCode!.isNotEmpty) {
            _selectedCountry = CountryData.findByPhoneCode(widget.initialPhoneCode);
          }
        });
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant CountryPhoneInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCountry != null && widget.initialCountry != _selectedCountry) {
      _selectedCountry = widget.initialCountry!;
    } else if (widget.initialPhoneCode != null &&
        widget.initialPhoneCode != oldWidget.initialPhoneCode) {
      _selectedCountry = CountryData.findByPhoneCode(widget.initialPhoneCode);
    }
  }

  void _initCountry() {
    if (widget.initialCountry != null) {
      _selectedCountry = widget.initialCountry!;
    } else if (widget.initialPhoneCode != null && widget.initialPhoneCode!.isNotEmpty) {
      _selectedCountry = CountryData.findByPhoneCode(widget.initialPhoneCode);
    } else if (widget.initialIsoCode != null && widget.initialIsoCode!.isNotEmpty) {
      _selectedCountry = CountryData.findByIsoCode(widget.initialIsoCode);
    } else {
      _selectedCountry = CountryData.defaultCountry;
    }
  }

  Future<void> _openPicker() async {
    if (!widget.enabled) return;
    final picked = await CountryPhonePickerSheet.show(
      context,
      selectedCountry: _selectedCountry,
      countries: widget.countries,
    );
    if (picked != null && mounted) {
      final newRule = CountryData.getPhoneRule(picked.isoCode);
      if (widget.controller != null && widget.controller!.text.length > newRule.maxLength) {
        widget.controller!.text = widget.controller!.text.substring(0, newRule.maxLength);
        widget.onChanged?.call(widget.controller!.text);
      }
      setState(() {
        _selectedCountry = picked;
      });
      widget.onCountryChanged?.call(picked);
    }
  }

  String? _validatePhone(String? value) {
    final fieldName = widget.label?.replaceAll('*', '').trim().toLowerCase() ?? 'phone number';
    final err = CountryData.validatePhoneNumber(
      country: _selectedCountry,
      phoneNumber: value,
      isRequired: widget.isRequired,
      fieldName: fieldName,
    );
    if (err != null) return err;

    if (widget.validator != null) {
      return widget.validator!(value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final rule = CountryData.getPhoneRule(_selectedCountry.isoCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '${_selectedCountry.isoCode == 'OT' ? 'Other' : _selectedCountry.name}: ${rule.lengthDescription}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
        ],
        FormField<String>(
          autovalidateMode: widget.autovalidateMode,
          validator: (v) => _validatePhone(widget.controller?.text ?? v),
          builder: (formState) {
            final hasError = formState.hasError;
            final currentText = widget.controller?.text ?? formState.value ?? '';
            final isLengthSatisfied = rule.isExact
                ? currentText.length == rule.minLength
                : (currentText.length >= rule.minLength && currentText.length <= rule.maxLength);

            // Dynamic hint text if generic or default
            String effectiveHint = widget.hintText;
            if (widget.hintText == 'Phone number' ||
                widget.hintText.toLowerCase().startsWith('enter phone') ||
                widget.hintText.toLowerCase().startsWith('enter contact') ||
                widget.hintText.toLowerCase().startsWith('enter mobile')) {
              effectiveHint = 'e.g. ${rule.example} (${rule.lengthDescription})';
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Dial Code Selector
                    InkWell(
                      onTap: _openPicker,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: widget.enabled ? Colors.white : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasError ? Colors.redAccent : AppColors.border,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedCountry.flagEmoji,
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCountry.phoneCode,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF64748B),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Phone Number Input Field (Digits only & country length cap)
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.enabled ? Colors.white : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasError
                                ? Colors.redAccent
                                : (isLengthSatisfied && currentText.isNotEmpty
                                    ? const Color(0xFF22C55E).withValues(alpha: 0.6)
                                    : AppColors.border),
                            width: 1.2,
                          ),
                        ),
                        child: TextFormField(
                          controller: widget.controller,
                          enabled: widget.enabled,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(rule.maxLength),
                          ],
                          onChanged: (val) {
                            formState.didChange(val);
                            widget.onChanged?.call(val);
                          },
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: effectiveHint,
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13.5,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            suffixIcon: (widget.controller?.text.isNotEmpty ?? false)
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 16, color: Color(0xFF94A3B8)),
                                    onPressed: () {
                                      widget.controller?.clear();
                                      formState.didChange('');
                                      widget.onChanged?.call('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Near Field Validation Error or Country Helper Information
                if (hasError) ...[
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.error_outline_rounded,
                              size: 13.5, color: Colors.redAccent),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            formState.errorText ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (widget.showHelperNearField) ...[
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_selectedCountry.name}: requires ${rule.lengthDescription}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (currentText.isNotEmpty)
                          Text(
                            rule.isExact
                                ? '${currentText.length}/${rule.minLength}'
                                : '${currentText.length} digits',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLengthSatisfied
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
