import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';
import '../widgets/yes_no_selector.dart';

class Step3Infrastructure extends StatefulWidget {
  final CertificationApplicationModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step3Infrastructure({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<Step3Infrastructure> createState() => _Step3InfrastructureState();
}

class _Step3InfrastructureState extends State<Step3Infrastructure> {
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
            'QUESTIONNAIRE · SECTION 1 OF 4',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '🏗️ Infrastructure / Amenities',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          // 4-Bar Segmented Progress Indicator
          Row(
            children: List.generate(4, (index) {
              final isCompleted = index == 0;
              return Expanded(
                child: Container(
                  height: 4.0,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primaryBlue
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
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
                  YesNoSelector(
                    question:
                        'Does the institution have a safe/equitable exercise area accessible to all?',
                    value: widget.model.hasSafeExerciseArea,
                    onChanged: (val) =>
                        setState(() => widget.model.hasSafeExerciseArea = val),
                  ),
                  YesNoSelector(
                    question:
                        'Are standing desks or adjustable workstations available?',
                    value: widget.model.hasStandingDesks,
                    onChanged: (val) =>
                        setState(() => widget.model.hasStandingDesks = val),
                  ),
                  YesNoSelector(
                    question:
                        'Is there a dedicated walking trail or path on premises?',
                    value: widget.model.hasDedicatedWalkingTrail,
                    onChanged: (val) => setState(
                        () => widget.model.hasDedicatedWalkingTrail = val),
                  ),
                  YesNoSelector(
                    question:
                        'Are cycle stands / bicycle parking facilities available?',
                    value: widget.model.hasCycleStands,
                    onChanged: (val) =>
                        setState(() => widget.model.hasCycleStands = val),
                  ),
                  YesNoSelector(
                    question:
                        'Is there PA promotion signage (e.g. stair use posters) displayed?',
                    value: widget.model.hasPaPromotionSignage,
                    onChanged: (val) => setState(
                        () => widget.model.hasPaPromotionSignage = val),
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
                onPressed: widget.onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Next',
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
}
