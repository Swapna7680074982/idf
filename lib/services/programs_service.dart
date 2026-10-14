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

  /// 6. GET /api/programs - Browse Public Programs
  static Future<ProgramsResponse> getPrograms({
    String? search,
    String status = 'all',
    int? typeId,
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
    if (typeId != null) {
      queryParams['type_id'] = typeId.toString();
    }

    final response = await ApiClient.get(
      ApiConfig.programs,
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

  /// 3. POST /api/programs - Create / Submit Program Proposal (Supports all Field Aliases)
  static Future<Map<String, dynamic>> submitProgramProposal({
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
    String? bannerImageUrl,
    String? coverImageUrl,
    int? bannerFileId,
    int? coverFileId,
    bool submit = true,
    String? customStatus,
  }) async {
    final effectiveStatus = customStatus ?? (submit ? 'submitted' : 'draft');
    final body = <String, dynamic>{
      'program_name': title,
      'title': title,
      'program_type_id': programTypeId,
      'organization_entity_name': organizerName,
      'organizer_name': organizerName,
      if (organizationType != null && organizationType.isNotEmpty)
        'organization_type': organizationType,
      'description': about,
      'about': about,
      'program_description': about,
      'venue': venue,
      'country_id': countryId,
      'country': countryText,
      'country_text': countryText,
      if (regionText != null && regionText.isNotEmpty) 'region': regionText,
      'city': cityText,
      'city_text': cityText,
      'start_date': startDate,
      'end_date': endDate,
      'contact_person': contactPerson,
      'phone': contactPhone,
      'contact_phone': contactPhone,
      'email': contactEmail,
      'contact_email': contactEmail,
      'program_agenda_schedule': agenda,
      'agenda': agenda,
      'materials': supportingFileIds,
      'supporting_file_ids': supportingFileIds,
      if (registrationLink != null && registrationLink.isNotEmpty)
        'registration_link': registrationLink,
      if (registrationInstructions != null && registrationInstructions.isNotEmpty)
        'registration_instructions': registrationInstructions,
      'status': effectiveStatus,
      'submit': submit,
    };

    final effectiveBannerUrl = bannerImageUrl ?? coverImageUrl;
    if (effectiveBannerUrl != null && effectiveBannerUrl.trim().isNotEmpty) {
      body['banner'] = effectiveBannerUrl.trim();
      body['banner_image_url'] = effectiveBannerUrl.trim();
      body['cover_image_url'] = effectiveBannerUrl.trim();
    }

    final effectiveBannerId = bannerFileId ?? coverFileId;
    if (effectiveBannerId != null) {
      body['banner_file_id'] = effectiveBannerId;
      body['cover_file_id'] = effectiveBannerId;
    }

    final response = await ApiClient.post(
      ApiConfig.programs,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return response;
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
    String? bannerImageUrl,
    String? coverImageUrl,
    int? bannerFileId,
    int? coverFileId,
    bool submit = true,
    String? customStatus,
  }) async {
    final effectiveStatus = customStatus ?? (submit ? 'submitted' : 'draft');
    final body = <String, dynamic>{
      'program_name': title,
      'title': title,
      'program_type_id': programTypeId,
      'organization_entity_name': organizerName,
      'organizer_name': organizerName,
      if (organizationType != null && organizationType.isNotEmpty)
        'organization_type': organizationType,
      'description': about,
      'about': about,
      'program_description': about,
      'venue': venue,
      'country_id': countryId,
      'country': countryText,
      'country_text': countryText,
      if (regionText != null && regionText.isNotEmpty) 'region': regionText,
      'city': cityText,
      'city_text': cityText,
      'start_date': startDate,
      'end_date': endDate,
      'contact_person': contactPerson,
      'phone': contactPhone,
      'contact_phone': contactPhone,
      'email': contactEmail,
      'contact_email': contactEmail,
      'program_agenda_schedule': agenda,
      'agenda': agenda,
      'materials': supportingFileIds,
      'supporting_file_ids': supportingFileIds,
      if (registrationLink != null && registrationLink.isNotEmpty)
        'registration_link': registrationLink,
      if (registrationInstructions != null && registrationInstructions.isNotEmpty)
        'registration_instructions': registrationInstructions,
      'status': effectiveStatus,
      'submit': submit,
    };

    final effectiveBannerUrl = bannerImageUrl ?? coverImageUrl;
    if (effectiveBannerUrl != null && effectiveBannerUrl.trim().isNotEmpty) {
      body['banner'] = effectiveBannerUrl.trim();
      body['banner_image_url'] = effectiveBannerUrl.trim();
      body['cover_image_url'] = effectiveBannerUrl.trim();
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
    throw const ApiException(
      code: 'CANCELLATION_FAILED',
      message: 'Failed to cancel program registration.',
      statusCode: 500,
    );
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
}


