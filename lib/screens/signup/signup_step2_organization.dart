import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/app_bloc.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'signup_step3_verify.dart';

class SignUpStep2Screen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const SignUpStep2Screen({
    super.key,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
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

  String? _selectedOrgType;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;

  @override
  void dispose() {
    _orgNameController.dispose();
    _addressController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpStep3Screen(
          fullName: widget.fullName,
          email: widget.email,
          phone: widget.phone,
          password: widget.password,
          organizationName: _orgNameController.text.trim(),
          organizationType: _selectedOrgType ?? '',
          country: _selectedCountry ?? '',
          state: _selectedState ?? '',
          city: _selectedCity ?? '',
          address: _addressController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppBloc>().state;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Organization / Institution Name',
                    hintText: 'World Health Centre',
                    controller: _orgNameController,
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownField(
                    label: 'Organization Type',
                    hintText: 'Select type...',
                    value: _selectedOrgType,
                    items: appState.organizationTypes,
                    onChanged: (val) {
                      setState(() {
                        _selectedOrgType = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownField(
                    label: 'Country',
                    hintText: 'Select Country',
                    value: _selectedCountry,
                    items: appState.countries,
                    onChanged: (val) {
                      setState(() {
                        _selectedCountry = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownField(
                    label: 'Region / State',
                    hintText: 'Select Region / State',
                    value: _selectedState,
                    items: appState.states,
                    onChanged: (val) {
                      setState(() {
                        _selectedState = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomDropdownField(
                    label: 'City',
                    hintText: 'Select City',
                    value: _selectedCity,
                    items: appState.cities,
                    onChanged: (val) {
                      setState(() {
                        _selectedCity = val;
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

                  PhoneInputField(
                    label: 'Contact Phone',
                    hintText: '0987654321',
                    controller: _contactPhoneController,
                  ),
                  const SizedBox(height: 28),

                  // Continue Button
                  PrimaryButton(
                    text: 'Continue',
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
