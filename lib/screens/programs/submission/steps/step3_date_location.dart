import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../models/program_submission_model.dart';
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
  String? _selectedCountry;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _countries = [
    'Nigeria',
    'Kenya',
    'India',
    'South Africa',
    'Ghana',
    'United States',
    'United Kingdom',
    'Belgium',
    'Thailand',
    'United Arab Emirates',
  ];

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
    _selectedCountry = widget.model.country.isNotEmpty ? widget.model.country : null;
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
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
            _endDateController.text = _formatDate(_endDate!);
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
      widget.model.endDate = _endDate;
      widget.model.country = _selectedCountry ?? '';
      widget.model.regionState = _regionController.text.trim();
      widget.model.city = _cityController.text.trim();
      widget.model.venueAddress = _venueController.text.trim();
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
          _buildFieldLabel('End Date *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _endDateController,
            readOnly: true,
            onTap: () => _pickDate(false),
            decoration: const InputDecoration(
              hintText: 'YYYY-MM-DD',
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
            ),
            validator: (val) => val == null || val.isEmpty ? 'Please select end date' : null,
          ),
          const SizedBox(height: 16),

          // Country
          _buildFieldLabel('Country *'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
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
              return DropdownMenuItem<String>(
                value: country,
                child: Text(
                  country,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => _selectedCountry = val);
            },
            validator: (val) =>
                val == null || val.isEmpty ? 'Please select country' : null,
          ),
          const SizedBox(height: 16),

          // Region / State
          _buildFieldLabel('Region / State'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regionController,
            decoration: const InputDecoration(
              hintText: 'e.g. Lagos State, Nairobi County',
            ),
          ),
          const SizedBox(height: 16),

          // City
          _buildFieldLabel('City *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              hintText: 'e.g. Lagos, Nairobi, Mumbai',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter city' : null,
          ),
          const SizedBox(height: 16),

          // Venue Address
          _buildFieldLabel('Venue Address *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _venueController,
            decoration: const InputDecoration(
              hintText: 'Full venue address',
            ),
            validator: (val) =>
                val == null || val.trim().isEmpty ? 'Please enter venue address' : null,
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
