import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/app_bloc.dart';
import '../../../bloc/app_event.dart';
import '../../../models/program_model.dart';
import '../../../models/program_submission_model.dart';
import '../widgets/step_progress_indicator.dart';
import 'steps/step1_program_info.dart';
import 'steps/step2_organizer.dart';
import 'steps/step3_date_location.dart';
import 'steps/step4_content.dart';
import 'steps/step5_objectives.dart';
import 'steps/step6_materials.dart';
import 'steps/step7_review_submit.dart';
import 'program_submitted_success_screen.dart';

class SubmitProgramWizardScreen extends StatefulWidget {
  const SubmitProgramWizardScreen({super.key});

  @override
  State<SubmitProgramWizardScreen> createState() => _SubmitProgramWizardScreenState();
}

class _SubmitProgramWizardScreenState extends State<SubmitProgramWizardScreen> {
  int _currentStep = 1;
  final int _totalSteps = 7;
  final ProgramSubmissionModel _submissionModel = ProgramSubmissionModel();
  bool _isSubmitting = false;

  final List<String> _stepTitles = [
    'Program Info',
    'Organizer',
    'Date & Location',
    'Content',
    'Objectives & Target',
    'Materials',
    'Review & Submit',
  ];

  void _nextStep() {
    if (_currentStep < _totalSteps) {
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
    if (step >= 1 && step <= _totalSteps) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  Future<void> _submitProgram() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    _submissionModel.referenceNumber =
        'APP-PRG-2025-0089';
    _submissionModel.submissionDate = DateTime.now();
    _submissionModel.status = 'AI Review';

    final String fullDesc = _submissionModel.programDescription.isNotEmpty
        ? _submissionModel.programDescription
        : _submissionModel.description;

    final newProgram = ProgramModel(
      id: _submissionModel.referenceNumber ?? 'APP-PRG-2025-0089',
      title: _submissionModel.programName.isNotEmpty
          ? _submissionModel.programName
          : 'Community Physical Activity Drive',
      tag: _submissionModel.programType.isNotEmpty
          ? _submissionModel.programType.toUpperCase()
          : 'CAMPAIGN',
      type: ProgramType.activityDrive,
      status: ProgramStatus.upcoming,
      organizer: _submissionModel.organizingEntityName.isNotEmpty
          ? _submissionModel.organizingEntityName
          : 'Lagos State University',
      organizationType: _submissionModel.organizationType.isNotEmpty
          ? _submissionModel.organizationType
          : 'Academic / Research Institution',
      venue: _submissionModel.venueAddress.isNotEmpty
          ? _submissionModel.venueAddress
          : '${_submissionModel.city}, ${_submissionModel.country}',
      location: _submissionModel.city.isNotEmpty
          ? '${_submissionModel.city}, ${_submissionModel.country}'
          : 'Lagos, Nigeria',
      country: _submissionModel.country.isNotEmpty
          ? _submissionModel.country
          : 'Nigeria',
      city: _submissionModel.city.isNotEmpty ? _submissionModel.city : 'Lagos',
      startDate: _submissionModel.startDate != null
          ? '${_submissionModel.startDate!.year}-${_submissionModel.startDate!.month.toString().padLeft(2, '0')}-${_submissionModel.startDate!.day.toString().padLeft(2, '0')}'
          : '2026-11-20',
      endDate: _submissionModel.endDate != null
          ? '${_submissionModel.endDate!.year}-${_submissionModel.endDate!.month.toString().padLeft(2, '0')}-${_submissionModel.endDate!.day.toString().padLeft(2, '0')}'
          : '2026-11-20',
      description: fullDesc.isNotEmpty
          ? fullDesc
          : 'Community activity initiative submitted for review.',
      agenda: const [
        ProgramAgendaItem(
          time: '09:00',
          title: 'Opening & Welcome',
          description: 'Official commencement of the activity drive.',
        ),
      ],
      contactInfo: ProgramContactInfo(
        contactPerson: _submissionModel.contactPerson.isNotEmpty
            ? _submissionModel.contactPerson
            : 'Dr. Sarah Osei',
        phone: _submissionModel.phone.isNotEmpty
            ? _submissionModel.phone
            : '+234 801 234 5678',
        email: _submissionModel.email.isNotEmpty
            ? _submissionModel.email
            : 'contact@institution.com',
      ),
      gradientColors: const [0xFF006097, 0xFF017CC2],
      category: _submissionModel.programType.isNotEmpty
          ? _submissionModel.programType
          : 'Activity Drive',
    );

    if (mounted) {
      context.read<AppBloc>().add(AddProgramRequested(newProgram));
      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProgramSubmittedSuccessScreen(
            submission: _submissionModel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar / Progress Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                ),
              ),
              child: StepProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepTitle: _stepTitles[_currentStep - 1],
                onBack: _previousStep,
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: _buildCurrentStepWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 1:
        return Step1ProgramInfo(
          model: _submissionModel,
          onContinue: _nextStep,
        );
      case 2:
        return Step2Organizer(
          model: _submissionModel,
          onContinue: _nextStep,
        );
      case 3:
        return Step3DateLocation(
          model: _submissionModel,
          onContinue: _nextStep,
        );
      case 4:
        return Step4Content(
          model: _submissionModel,
          onContinue: _nextStep,
        );
      case 5:
        return Step5Objectives(
          model: _submissionModel,
          onContinue: _nextStep,
        );
      case 6:
        return Step6Materials(
          model: _submissionModel,
          onContinue: _nextStep,
        );
      case 7:
        return Step7ReviewSubmit(
          model: _submissionModel,
          onEditStep: _jumpToStep,
          onSubmit: _submitProgram,
          isSubmitting: _isSubmitting,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
