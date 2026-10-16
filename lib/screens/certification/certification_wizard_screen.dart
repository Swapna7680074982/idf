import 'package:flutter/material.dart';
import '../../models/certification_model.dart';
import 'certification_submitted_screen.dart';
import 'steps/step1_institution_type.dart';
import 'steps/step2_institution_details.dart';
import 'steps/step3_infrastructure.dart';
import 'steps/step4_organizational.dart';
import 'steps/step5_individual.dart';
import 'steps/step6_scalability.dart';
import 'steps/step7_evidence.dart';
import 'steps/step8_review.dart';
import 'steps/step9_confirmation.dart';

class CertificationWizardScreen extends StatefulWidget {
  final CertificationApplicationModel? initialModel;
  final int initialStep;

  const CertificationWizardScreen({
    super.key,
    this.initialModel,
    this.initialStep = 1,
  });

  @override
  State<CertificationWizardScreen> createState() =>
      _CertificationWizardScreenState();
}

class _CertificationWizardScreenState extends State<CertificationWizardScreen> {
  int _currentStep = 1;
  late final CertificationApplicationModel _model;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _model = widget.initialModel ?? CertificationApplicationModel();
  }

  void _nextStep() {
    if (_currentStep < 9) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _jumpToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    _model.submissionDate = DateTime.now();
    _model.status = 'AI Audit';

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CertificationSubmittedScreen(
            application: _model,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 1:
        return Step1InstitutionType(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return Step2InstitutionDetails(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 3:
        return Step3Infrastructure(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 4:
        return Step4Organizational(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 5:
        return Step5Individual(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 6:
        return Step6Scalability(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 7:
        return Step7Evidence(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 8:
        return Step8Review(
          model: _model,
          onContinue: _nextStep,
          onBack: _previousStep,
          onEditDetails: () => _jumpToStep(2),
          onJumpToStep: _jumpToStep,
        );
      case 9:
        return Step9Confirmation(
          model: _model,
          onSubmit: _submitApplication,
          onBack: _previousStep,
          isSubmitting: _isSubmitting,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
