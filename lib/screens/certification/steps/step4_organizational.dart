import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/certification_model.dart';
import '../widgets/yes_no_selector.dart';

class Step4Organizational extends StatefulWidget {
  final CertificationApplicationModel model;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const Step4Organizational({
    super.key,
    required this.model,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<Step4Organizational> createState() => _Step4OrganizationalState();
}

class _Step4OrganizationalState extends State<Step4Organizational> {
  late TextEditingController _eventsCountController;

  @override
  void initState() {
    super.initState();
    _eventsCountController =
        TextEditingController(text: widget.model.sportsEventsCount);
  }

  @override
  void dispose() {
    _eventsCountController.dispose();
    super.dispose();
  }

  void _onNext(List<dynamic> dynamicQuestions) {
    if (dynamicQuestions.isNotEmpty) {
      final unanswered = dynamicQuestions.where((q) => widget.model.getQuestionBool(q.id) == null);
      if (unanswered.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please answer all questions before proceeding'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }
    widget.model.sportsEventsCount = _eventsCountController.text.trim();
    widget.onContinue();
  }

  Widget _buildHeader() {
    final sections = widget.model.categoryConfig?.sections;
    final totalSections = (sections != null && sections.isNotEmpty) ? sections.length : 4;
    final section = (sections != null && sections.length > 1) ? sections[1] : null;
    final sectionName = section?.name ?? 'Organizational / Policy';
    final sectionEmoji = section?.emoji ?? '📋';

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
            'QUESTIONNAIRE · SECTION 2 OF $totalSections',
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$sectionEmoji $sectionName',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          // Segmented Progress Indicator
          Row(
            children: List.generate(totalSections, (index) {
              final isCompleted = index <= 1;
              return Expanded(
                child: Container(
                  height: 4.0,
                  margin: EdgeInsets.only(right: index == totalSections - 1 ? 0 : 6),
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
    final sections = widget.model.categoryConfig?.sections;
    final section = (sections != null && sections.length > 1) ? sections[1] : null;
    final dynamicQuestions = section?.questions ?? [];

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
                  if (dynamicQuestions.isNotEmpty)
                    ...dynamicQuestions.map((q) {
                      final val = widget.model.getQuestionBool(q.id);
                      return YesNoSelector(
                        question: q.text,
                        value: val,
                        onChanged: (newVal) {
                          setState(() {
                            widget.model.setQuestionAnswer(q.id, newVal);
                          });
                        },
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: Text(
                          'No questions available in this section.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
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
                onPressed: () => _onNext(dynamicQuestions),
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
