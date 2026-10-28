import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';

class Step9Confirmation extends StatefulWidget {
  final CertificationApplicationModel model;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final bool isSubmitting;

  const Step9Confirmation({
    super.key,
    required this.model,
    required this.onSubmit,
    required this.onBack,
    this.isSubmitting = false,
  });

  @override
  State<Step9Confirmation> createState() => _Step9ConfirmationState();
}

class _Step9ConfirmationState extends State<Step9Confirmation> {
  late bool _accepted;

  @override
  void initState() {
    super.initState();
    _accepted = widget.model.declarationAccepted;
  }

  Widget _buildHeader() {
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
          Text(
            'Confirmation',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Final step before submitting',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.35,
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                children: [
                  // Declaration Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9).withAlpha(120),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFFE2E8F0), width: 1.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'By submitting this application, I declare that:',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDeclarationBullet(
                            'All information provided is accurate and complete to the best of my knowledge.'),
                        _buildDeclarationBullet(
                            'All evidence submitted is authentic and has not been manipulated.'),
                        _buildDeclarationBullet(
                            'I am authorized to represent this institution in this application.'),
                        _buildDeclarationBullet(
                            'I understand that false information may result in rejection or withdrawal of certification.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Confirmation Checkbox Row
                  InkWell(
                    onTap: () {
                      setState(() {
                        _accepted = !_accepted;
                        widget.model.declarationAccepted = _accepted;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _accepted,
                              activeColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _accepted = val ?? false;
                                  widget.model.declarationAccepted = _accepted;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I confirm that the information and evidence provided in this application are accurate and complete.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF334155),
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
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
                onPressed: widget.isSubmitting
                    ? null
                    : () {
                        if (!_accepted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please accept the declaration to submit'),
                              backgroundColor: Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        widget.onSubmit();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: widget.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Application',
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

  Widget _buildDeclarationBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF64748B),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
