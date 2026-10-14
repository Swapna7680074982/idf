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
import '../../../core/theme.dart';
import '../../../services/api_client.dart';
import '../../../services/programs_service.dart';

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

  @override
  void initState() {
    super.initState();
  }

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

    final String fullDesc = _submissionModel.programDescription.isNotEmpty
        ? _submissionModel.programDescription
        : _submissionModel.description;

    final String startDateStr = _submissionModel.startDate != null
        ? '${_submissionModel.startDate!.year}-${_submissionModel.startDate!.month.toString().padLeft(2, '0')}-${_submissionModel.startDate!.day.toString().padLeft(2, '0')}'
        : '2026-11-20';

    final String endDateStr = _submissionModel.endDate != null
        ? '${_submissionModel.endDate!.year}-${_submissionModel.endDate!.month.toString().padLeft(2, '0')}-${_submissionModel.endDate!.day.toString().padLeft(2, '0')}'
        : startDateStr;

    // Compile supporting file IDs (including banner file id if uploaded)
    final fileIds = <int>[..._submissionModel.supportingFileIds];
    if (_submissionModel.bannerFileId != null && !fileIds.contains(_submissionModel.bannerFileId)) {
      fileIds.add(_submissionModel.bannerFileId!);
    }

    try {
      final res = await ProgramsService.submitProgramProposal(
        title: _submissionModel.programName.isNotEmpty
            ? _submissionModel.programName
            : 'Community Physical Activity Drive',
        programTypeId: _submissionModel.programTypeId ?? 1,
        organizerName: _submissionModel.organizingEntityName.isNotEmpty
            ? _submissionModel.organizingEntityName
            : 'World Health Centre',
        about: fullDesc.isNotEmpty ? fullDesc : 'Physical activity initiative proposal.',
        venue: _submissionModel.venueAddress.isNotEmpty
            ? _submissionModel.venueAddress
            : (_submissionModel.city.isNotEmpty ? _submissionModel.city : 'Community Center'),
        countryId: _submissionModel.countryId ?? 1,
        cityText: _submissionModel.city.isNotEmpty ? _submissionModel.city : 'Mumbai',
        countryText: _submissionModel.country.isNotEmpty ? _submissionModel.country : 'India',
        startDate: startDateStr,
        endDate: endDateStr,
        contactPerson: _submissionModel.contactPerson.isNotEmpty
            ? _submissionModel.contactPerson
            : 'Dr. Jane Smith',
        contactPhone: _submissionModel.phone.isNotEmpty
            ? _submissionModel.phone
            : '+91 9876543210',
        contactEmail: _submissionModel.email.isNotEmpty
            ? _submissionModel.email
            : 'contact@institution.org',
        agenda: _submissionModel.agendaItems.isNotEmpty
            ? _submissionModel.agendaItems
                .where((item) => (item['title'] ?? '').toString().trim().isNotEmpty)
                .map((item) => {
                      'start_time': (item['start_time'] ?? '').toString().trim().isNotEmpty
                          ? item['start_time']!.toString().trim()
                          : '09:00',
                      'title': item['title']!.toString().trim(),
                    })
                .toList()
            : (_submissionModel.agenda.trim().isNotEmpty
                ? _submissionModel.agenda
                    .split('\n')
                    .where((line) => line.trim().isNotEmpty)
                    .map((line) {
                      final trimmed = line.trim();
                      final match = RegExp(r'^(\d{1,2}:\d{2})\s*[-:]?\s*(.*)$').firstMatch(trimmed);
                      if (match != null) {
                        return {
                          'start_time': match.group(1)!,
                          'title': match.group(2)!.isNotEmpty ? match.group(2)! : match.group(1)!,
                        };
                      }
                      return {
                        'start_time': '09:00',
                        'title': trimmed,
                      };
                    }).toList()
                : <Map<String, dynamic>>[]),
        supportingFileIds: fileIds,
        bannerImageUrl: _submissionModel.bannerUrl,
        coverImageUrl: _submissionModel.bannerUrl,
        bannerFileId: _submissionModel.bannerFileId,
        coverFileId: _submissionModel.bannerFileId,
        submit: true,
      );

      final programData = res['data'] is Map<String, dynamic>
          ? res['data']['program'] as Map<String, dynamic>?
          : (res['program'] as Map<String, dynamic>?);
      _submissionModel.referenceNumber = programData?['program_no']?.toString() ?? 'PRG-${DateTime.now().year}-00001';
      _submissionModel.status = programData?['review_status']?.toString() ?? 'submitted';
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.displayMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit program: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    _submissionModel.submissionDate = DateTime.now();

    final newProgram = ProgramModel(
      id: _submissionModel.referenceNumber ?? 'APP-PRG-2026-0089',
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
          : 'World Health Centre',
      organizationType: _submissionModel.organizationType.isNotEmpty
          ? _submissionModel.organizationType
          : 'Institution',
      venue: _submissionModel.venueAddress.isNotEmpty
          ? _submissionModel.venueAddress
          : '${_submissionModel.city}, ${_submissionModel.country}',
      location: _submissionModel.city.isNotEmpty
          ? '${_submissionModel.city}, ${_submissionModel.country}'
          : 'Mumbai, India',
      country: _submissionModel.country.isNotEmpty
          ? _submissionModel.country
          : 'India',
      city: _submissionModel.city.isNotEmpty ? _submissionModel.city : 'Mumbai',
      startDate: startDateStr,
      endDate: endDateStr,
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
            : 'Dr. Jane Smith',
        phone: _submissionModel.phone.isNotEmpty
            ? _submissionModel.phone
            : '+91 9876543210',
        email: _submissionModel.email.isNotEmpty
            ? _submissionModel.email
            : 'contact@institution.org',
      ),
      gradientColors: const [0xFF006097, 0xFF017CC2],
      imageUrl: _submissionModel.bannerUrl ?? _submissionModel.bannerPath,
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
