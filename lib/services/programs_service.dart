import 'dart:io';
import '../models/program_api_models.dart';
import '../models/program_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class ProgramsService {
  /// 1. POST /api/programs/banner - Upload Banner Image
  static Future<Map<String, dynamic>> uploadBannerImage(File file) async {
    final response = await ApiClient.multipartPost(
      ApiConfig.programBanner,
      file: file,
      fileField: 'banner',
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return data;
    }
    return <String, dynamic>{};
  }

  /// 2. POST /api/files - Upload Supporting Materials (PDFs / Flyers)
  static Future<Map<String, dynamic>> uploadSupportingMaterial(File file) async {
    final response = await ApiClient.multipartPost(
      ApiConfig.files,
      file: file,
      fileField: 'file',
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return data;
    }
    return <String, dynamic>{};
  }

  /// 6. GET /api/programs - Browse Public Programs (Header Token)
  static Future<ProgramsResponse> getPrograms({
    String? search,
    String? status,
    int? typeId,
    int? page,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status.trim().isNotEmpty && status.trim().toLowerCase() != 'all') {
      queryParams['status'] = status.trim();
    }
    if (typeId != null) {
      queryParams['type_id'] = typeId.toString();
    }
    if (page != null && page > 1) {
      queryParams['page'] = page.toString();
    }
    final effectiveLimit = limit > 50 ? 50 : (limit < 1 ? 20 : limit);
    queryParams['limit'] = effectiveLimit.toString();

    final response = await ApiClient.get(
      ApiConfig.programs,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return ProgramsResponse.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load programs list.',
      statusCode: 200,
    );
  }

  /// GET /api/programs/registered - Get Registered Programs (My Registrations)
  static Future<ProgramsResponse> getRegisteredPrograms({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await ApiClient.get(
      ApiConfig.programsRegistered,
      queryParams: queryParams,
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return ProgramsResponse.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load registered programs.',
      statusCode: 200,
    );
  }

  /// Direct POST /api/programs with exact JSON body
  static Future<ProgramSubmissionResponse> createProgramJson(Map<String, dynamic> body) async {
    final response = await ApiClient.post(
      ApiConfig.programs,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return ProgramSubmissionResponse.fromJson(response);
    }
    throw const ApiException(
      code: 'SUBMISSION_FAILED',
      message: 'Failed to submit program.',
      statusCode: 500,
    );
  }

  /// Direct POST /api/programs with ProgramCreateRequest model
  static Future<ProgramSubmissionResponse> createProgram(ProgramCreateRequest request) async {
    return createProgramJson(request.toJson());
  }

  /// 3. POST /api/programs - Create / Submit Program Proposal (Exact Match)
  static Future<ProgramSubmissionResponse> submitProgramProposal({
    required String title,
    required int programTypeId,
    required String organizerName,
    String? organizationType,
    required String about,
    required String venue,
    int? countryId,
    required String cityText,
    required String countryText,
    String? regionText,
    required String startDate,
    required String endDate,
    required String contactPerson,
    required String contactPhone,
    required String contactEmail,
    String? registrationLink,
    String? registrationInstructions,
    List<Map<String, dynamic>> agenda = const [],
    List<int> supportingFileIds = const [],
    List<Map<String, dynamic>> materials = const [],
    String? bannerImageUrl,
    String? coverImageUrl,
    int? bannerFileId,
    int? coverFileId,
    bool submit = true,
    String? customStatus,
  }) async {
    final effectiveStatus = customStatus ?? (submit ? 'submitted' : 'draft');
    final effectiveBanner = (bannerImageUrl != null && bannerImageUrl.trim().isNotEmpty)
        ? bannerImageUrl.trim()
        : ((coverImageUrl != null && coverImageUrl.trim().isNotEmpty)
            ? coverImageUrl.trim()
            : '');

    final body = <String, dynamic>{
      'program_name': title,
      'program_type_id': programTypeId,
      'banner': effectiveBanner,
      'description': about,
      'organization_entity_name': organizerName,
      if (organizationType != null && organizationType.isNotEmpty)
        'organization_type': organizationType,
      'contact_person': contactPerson,
      'phone': contactPhone,
      'email': contactEmail,
      'start_date': startDate,
      'end_date': endDate,
      'country': countryText,
      if (regionText != null && regionText.isNotEmpty) 'region': regionText,
      'city': cityText,
      'venue': venue,
      'program_agenda_schedule': agenda,
      'materials': materials,
      'registration_link': registrationLink ?? '',
      'registration_instructions': registrationInstructions ?? '',
      'status': effectiveStatus,
    };

    final response = await ApiClient.post(
      ApiConfig.programs,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return ProgramSubmissionResponse.fromJson(response);
    }
    throw const ApiException(
      code: 'SUBMISSION_FAILED',
      message: 'Failed to submit program.',
      statusCode: 500,
    );
  }

  /// 4. PUT /api/programs/:id - Edit a Program (Draft or Changes Required)
  static Future<Map<String, dynamic>> updateProgramProposal(
    dynamic id, {
    required String title,
    required int programTypeId,
    required String organizerName,
    String? organizationType,
    required String about,
    required String venue,
    required int countryId,
    required String cityText,
    required String countryText,
    String? regionText,
    required String startDate,
    required String endDate,
    required String contactPerson,
    required String contactPhone,
    required String contactEmail,
    String? registrationLink,
    String? registrationInstructions,
    List<Map<String, dynamic>> agenda = const [],
    List<int> supportingFileIds = const [],
    List<Map<String, dynamic>> materials = const [],
    String? bannerImageUrl,
    String? coverImageUrl,
    int? bannerFileId,
    int? coverFileId,
    bool submit = true,
    String? customStatus,
  }) async {
    final effectiveStatus = customStatus ?? (submit ? 'submitted' : 'draft');
    final effectiveBanner = (bannerImageUrl ?? coverImageUrl ?? '').trim();
    final effectiveMaterials = materials.isNotEmpty
        ? materials
        : (supportingFileIds.isNotEmpty ? supportingFileIds : <dynamic>[]);

    final body = <String, dynamic>{
      'program_name': title,
      'program_type_id': programTypeId,
      'banner': effectiveBanner,
      'description': about,
      'organization_entity_name': organizerName,
      if (organizationType != null && organizationType.isNotEmpty)
        'organization_type': organizationType,
      'contact_person': contactPerson,
      'phone': contactPhone,
      'email': contactEmail,
      'start_date': startDate,
      'end_date': endDate,
      'country': countryText,
      if (regionText != null && regionText.isNotEmpty) 'region': regionText,
      'city': cityText,
      'venue': venue,
      'program_agenda_schedule': agenda,
      'materials': effectiveMaterials,
      if (registrationLink != null && registrationLink.isNotEmpty)
        'registration_link': registrationLink,
      if (registrationInstructions != null && registrationInstructions.isNotEmpty)
        'registration_instructions': registrationInstructions,
      'status': effectiveStatus,

      // Compatibility aliases
      'title': title,
      'organizer_name': organizerName,
      'about': about,
      'program_description': about,
      'country_id': countryId,
      'country_text': countryText,
      'city_text': cityText,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'agenda': agenda,
      'supporting_file_ids': supportingFileIds,
      'submit': submit,
    };

    if (effectiveBanner.isNotEmpty) {
      body['banner_image_url'] = effectiveBanner;
      body['cover_image_url'] = effectiveBanner;
    }

    final effectiveBannerId = bannerFileId ?? coverFileId;
    if (effectiveBannerId != null) {
      body['banner_file_id'] = effectiveBannerId;
      body['cover_file_id'] = effectiveBannerId;
    }

    final response = await ApiClient.put(
      ApiConfig.programDetail(id),
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ApiException(
      code: 'UPDATE_FAILED',
      message: 'Failed to update program.',
      statusCode: 500,
    );
  }

  /// 5. GET /api/programs/:id - Program Detail Screen (Public & Creator View)
  static Future<ProgramModel> getProgramDetail(dynamic id) async {
    final response = await ApiClient.get(ApiConfig.programDetail(id));
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      final programMap = data['program'] is Map<String, dynamic>
          ? data['program'] as Map<String, dynamic>
          : data;
      return ProgramModel.fromDetailJson(programMap);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load program details.',
      statusCode: 200,
    );
  }

  /// POST /api/programs/:id/register - Register for Program
  static Future<Map<String, dynamic>> registerForProgram(dynamic id) async {
    final response = await ApiClient.post(
      ApiConfig.programRegister(id),
      body: {},
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ApiException(
      code: 'REGISTRATION_FAILED',
      message: 'Failed to register for program.',
      statusCode: 500,
    );
  }

  /// DELETE /api/programs/:id/register - Cancel Program Registration
  static Future<Map<String, dynamic>> cancelProgramRegistration(dynamic id) async {
    final response = await ApiClient.delete(
      ApiConfig.programRegister(id),
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    return <String, dynamic>{'success': true, 'message': 'Registration cancelled'};
  }

  /// 7. GET /api/applications/programs - My Applications List ("My Programs" Tab)
  static Future<Map<String, dynamic>> getMyApplications({
    String status = 'all',
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'status': status,
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await ApiClient.get(
      ApiConfig.applicationsPrograms,
      queryParams: queryParams,
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return data;
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load program applications list.',
      statusCode: 200,
    );
  }

  /// 8. GET /api/applications/programs/:id - My Application Details & Review Timeline
  static Future<Map<String, dynamic>> getMyApplicationDetail(dynamic id) async {
    final response = await ApiClient.get(ApiConfig.applicationProgramDetail(id));
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      final application = data['application'] is Map<String, dynamic>
          ? data['application'] as Map<String, dynamic>
          : data;
      return application;
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load application details.',
      statusCode: 200,
    );
  }

  /// 9. POST /api/programs/:id/ai-validation - Post AI Validation Result (Mobile -> Backend)
  static Future<Map<String, dynamic>> postAiValidationResult(
    dynamic programId, {
    String status = 'approved',
    List<Map<String, dynamic>>? checks,
  }) async {
    final effectiveChecks = checks ?? [
      {'check_type': 'content_review', 'status': 'approved', 'details': null},
      {'check_type': 'program_details_match', 'status': 'approved', 'details': null},
      {'check_type': 'supporting_materials', 'status': 'approved', 'details': null},
      {'check_type': 'overall', 'status': 'approved', 'details': null},
    ];

    final body = <String, dynamic>{
      'status': status,
      'checks': effectiveChecks,
      'ai_validation': effectiveChecks,
    };

    // Primary: POST /api/programs/:id/ai-validation
    try {
      final response = await ApiClient.post(
        ApiConfig.programAiValidation(programId),
        body: body,
      );
      if (response is Map<String, dynamic>) return response;
    } catch (_) {
      try {
        final putRes = await ApiClient.put(
          ApiConfig.programAiValidation(programId),
          body: body,
        );
        if (putRes is Map<String, dynamic>) return putRes;
      } catch (_) {
        try {
          final v1Res = await ApiClient.post(
            ApiConfig.programAiValidationV1(programId),
            body: body,
          );
          if (v1Res is Map<String, dynamic>) return v1Res;
        } catch (_) {}
      }
    }
    return <String, dynamic>{};
  }

  /// 10. POST /api/v1/programs/:id/review - Review Decision (Approve / Reject / Changes)
  static Future<Map<String, dynamic>> reviewProgram(
    dynamic programId, {
    required String outcome, // 'approved', 'changes_required', 'rejected'
    String comments = 'Approved for public listing.',
  }) async {
    final body = <String, dynamic>{
      'outcome': outcome,
      'comments': comments,
    };

    try {
      final response = await ApiClient.post(
        ApiConfig.programReviewV1(programId),
        body: body,
      );
      if (response is Map<String, dynamic>) return response;
    } catch (_) {
      try {
        final fallback = await ApiClient.post(
          ApiConfig.programReview(programId),
          body: body,
        );
        if (fallback is Map<String, dynamic>) return fallback;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }
}


