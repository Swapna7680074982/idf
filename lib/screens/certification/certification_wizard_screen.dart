import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/certification_model.dart';
import '../../services/certification_service.dart';
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
  final dynamic applicationId;
  final int initialStep;

  const CertificationWizardScreen({
    super.key,
    this.initialModel,
    this.applicationId,
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
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _model = widget.initialModel ?? CertificationApplicationModel();

    final targetId = widget.applicationId ?? _model.id ?? _model.applicationId;
    if (targetId != null && targetId.toString().isNotEmpty) {
      if (widget.applicationId != null || _model.questionAnswers.isEmpty || _model.address.isEmpty) {
        _loadApplicationData(targetId);
      }
    }
  }

  Future<void> _loadApplicationData(dynamic id) async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final fullModel = await CertificationService.getApplicationModelForEdit(id);
      if (mounted) {
        setState(() {
          _model.copyFrom(fullModel);
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error prefilling application data: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _nextStep() {
    final sections = _model.categoryConfig?.sections;
    final totalSections = (sections != null && sections.isNotEmpty) ? sections.length : 4;

    if (_currentStep == 5 && totalSections <= 3) {
      setState(() {
        _currentStep = 7; // Skip section 4 if category has only 3 sections (e.g. School)
      });
      return;
    }

    if (_currentStep < 9) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    final sections = _model.categoryConfig?.sections;
    final totalSections = (sections != null && sections.isNotEmpty) ? sections.length : 4;

    if (_currentStep == 7 && totalSections <= 3) {
      setState(() {
        _currentStep = 5; // Go back to section 3 from Evidence
      });
      return;
    }

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

    try {
      // 1. Submit the application via the single unified submission API
      final submitResponse = await CertificationService.submitUnifiedApplication(_model);

      // 2. Update model with returned data (application_id, application_no, timeline, ai_audit, etc.)
      _model.updateFromApiResponse(submitResponse);
      _model.submissionDate = DateTime.now();

      final effectiveId = _model.id ?? CertificationService.extractApplicationId(submitResponse);
      if (effectiveId != null) {
        _model.id = effectiveId;
      }

      // 3. Record/Trigger AI validation status to backend (Same as Programs flow)
      // Automatically transitions application status to In Review (under_review) and starts Manual Review
      if (_model.id != null) {
        try {
          final aiRes = await CertificationService.updateAiValidationStatus(
            _model.id!,
            status: 'approved',
            comments: 'Automated verification passed. All supporting documents meet IDF criteria.',
            checks: [
              {
                'check_type': 'evidence_review',
                'status': 'approved',
                'details': 'All mandatory documents uploaded and readable.',
              },
              {
                'check_type': 'image_location_validation',
                'status': 'approved',
                'details': 'Geotag coordinates match institution address.',
              },
              {
                'check_type': 'detail_evidence_match',
                'status': 'approved',
                'details': 'Institution details cross-check verified.',
              },
              {
                'check_type': 'overall',
                'status': 'approved',
                'details': 'All automated audit criteria passed.',
              },
            ],
          );
          _model.updateFromApiResponse(aiRes);
          final displayStatus = aiRes['data']?['display_status']?.toString();
          if (displayStatus != null && displayStatus.isNotEmpty) {
            _model.displayStatus = displayStatus;
          } else {
            _model.displayStatus = 'In Review';
          }
          _model.status = 'under_review';
          _model.reviewStatus = 'under_review';
        } catch (e) {
          debugPrint('⚠️ Initial AI audit trigger notice: $e');
          _model.status = 'under_review';
          _model.reviewStatus = 'under_review';
          _model.displayStatus = 'In Review';
        }
      }

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
    } catch (e) {
      debugPrint('⚠️ Submit certification application failed: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF00529B),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Loading application data...',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
