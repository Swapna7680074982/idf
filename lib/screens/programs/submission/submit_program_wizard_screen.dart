import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/app_bloc.dart';
import '../../../bloc/app_event.dart';
import '../../../models/program_model.dart';
import '../../../models/application_item_model.dart';
import '../../../models/program_submission_model.dart';
import '../widgets/step_progress_indicator.dart';
import 'steps/step1_program_info.dart';
import 'steps/step2_organizer.dart';
import 'steps/step3_date_location.dart';
import 'steps/step4_content.dart';
import 'steps/step5_registration.dart';
import 'steps/step6_materials.dart';
import 'steps/step7_review_submit.dart';
import 'program_submitted_success_screen.dart';
import '../../../services/api_config.dart';
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
    'Agenda & Schedule',
    'Registration Details',
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

    // Compile materials list (name, url, mime_type)
    final materialsList = <Map<String, dynamic>>[..._submissionModel.materials];
    if (materialsList.isEmpty && _submissionModel.uploadedFileNames.isNotEmpty) {
      for (final fName in _submissionModel.uploadedFileNames) {
        materialsList.add({
          'name': fName,
          'url': '${ApiConfig.baseUrl}/uploads/$fName',
          'mime_type': fName.endsWith('.pdf') ? 'application/pdf' : 'image/jpeg',
        });
      }
    }
    final agendaPayload = _submissionModel.agendaItems.isNotEmpty
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
            : <Map<String, dynamic>>[]);

    try {
      final res = await ProgramsService.submitProgramProposal(
        title: _submissionModel.programName,
        programTypeId: _submissionModel.programTypeId ?? 1,
        organizerName: _submissionModel.organizingEntityName,
        organizationType: _submissionModel.organizationType,
        about: fullDesc,
        venue: _submissionModel.venueAddress,
        countryId: _submissionModel.countryId ?? 1,
        cityText: _submissionModel.city,
        countryText: _submissionModel.country,
        regionText: _submissionModel.regionState,
        startDate: startDateStr,
        endDate: endDateStr,
        contactPerson: _submissionModel.contactPerson,
        contactPhone: _submissionModel.phone,
        contactEmail: _submissionModel.email,
        registrationInstructions: _submissionModel.registrationInstructions.trim().isNotEmpty
            ? _submissionModel.registrationInstructions.trim()
            : null,
        registrationLink: _submissionModel.registrationLink.trim().isNotEmpty
            ? _submissionModel.registrationLink.trim()
            : null,
        agenda: agendaPayload,
        supportingFileIds: fileIds,
        materials: materialsList,
        bannerImageUrl: _submissionModel.bannerUrl,
        coverImageUrl: _submissionModel.bannerUrl,
        bannerFileId: _submissionModel.bannerFileId,
        coverFileId: _submissionModel.bannerFileId,
        submit: true,
      );

      final programObj = res.program;
      final programId = (programObj != null && programObj.id > 0)
          ? programObj.id.toString()
          : (res['data']?['program']?['id']?.toString() ??
              res['data']?['id']?.toString() ??
              '');
      _submissionModel.referenceNumber = (programObj?.programNo.isNotEmpty ?? false)
          ? programObj!.programNo
          : (res['data']?['program']?['program_no']?.toString() ??
              (programId.isNotEmpty ? programId : ''));
      _submissionModel.status = (programObj?.reviewStatus.isNotEmpty ?? false)
          ? programObj!.reviewStatus
          : (res['data']?['program']?['review_status']?.toString() ??
              res['data']?['program']?['status']?.toString() ??
              'submitted');

      _submissionModel.submissionDate = DateTime.now();

      // Automatically post AI Validation Result (Mobile -> Backend)
      // Transitions program status to "In Review" (manual_review)
      if (programId.isNotEmpty) {
        try {
          final aiRes = await ProgramsService.postAiValidationResult(
            programId,
            status: 'approved',
          );
          final displayStatus = aiRes['data']?['display_status']?.toString();
          if (displayStatus != null && displayStatus.isNotEmpty) {
            _submissionModel.status = displayStatus;
          } else {
            _submissionModel.status = 'In Review';
          }
        } catch (_) {
          _submissionModel.status = 'In Review';
        }
      }

      final loc = [_submissionModel.city, _submissionModel.country]
          .where((s) => s.trim().isNotEmpty)
          .join(', ');

      final newProgram = ProgramModel(
        id: programId,
        programNo: _submissionModel.referenceNumber,
        title: _submissionModel.programName,
        tag: _submissionModel.programType.isNotEmpty
            ? _submissionModel.programType.toUpperCase()
            : 'PROGRAM',
        type: ProgramType.activityDrive,
        status: ProgramStatus.upcoming,
        organizer: _submissionModel.organizingEntityName.isNotEmpty
            ? _submissionModel.organizingEntityName
            : 'You (Organizer)',
        organizationType: _submissionModel.organizationType,
        venue: _submissionModel.venueAddress,
        location: loc,
        country: _submissionModel.country,
        city: _submissionModel.city,
        startDate: startDateStr,
        endDate: endDateStr,
        description: fullDesc,
        agenda: _submissionModel.agendaItems.isNotEmpty
            ? _submissionModel.agendaItems.map((item) => ProgramAgendaItem(
                time: item['start_time'] ?? '',
                title: item['title'] ?? '',
              )).toList()
            : const [],
        materials: materialsList.map((m) => ProgramMaterialItem.fromJson(m)).toList(),
        contactInfo: ProgramContactInfo(
          contactPerson: _submissionModel.contactPerson,
          phone: _submissionModel.phone,
          email: _submissionModel.email,
        ),
        gradientColors: const [0xFF006097, 0xFF017CC2],
        imageUrl: _submissionModel.bannerUrl ?? _submissionModel.bannerPath,
        category: _submissionModel.programType,
        registrationInstructions: _submissionModel.registrationInstructions.trim().isNotEmpty
            ? _submissionModel.registrationInstructions.trim()
            : null,
        registrationLink: _submissionModel.registrationLink.trim().isNotEmpty
            ? _submissionModel.registrationLink.trim()
            : null,
        reviewStatus: _submissionModel.status,
        isOrganizer: true,
      );

      if (mounted) {
        context.read<AppBloc>().add(AddProgramRequested(newProgram));
        setState(() {
          _isSubmitting = false;
        });

        final appItem = ProgramApplicationItem.fromProgramModel(newProgram);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProgramSubmittedSuccessScreen(
              submission: _submissionModel,
              applicationItem: appItem,
              programModel: newProgram,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit program: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
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
        return Step5Registration(
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
