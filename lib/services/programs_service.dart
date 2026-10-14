import '../models/program_api_models.dart';
import '../models/program_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class ProgramsService {
  /// GET /api/programs - Browse Public Programs
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

  /// POST /api/programs - Create / Submit Program Proposal
  static Future<Map<String, dynamic>> submitProgramProposal({
    required String title,
    required int programTypeId,
    required String organizerName,
    required String about,
    required String venue,
    required int countryId,
    required String cityText,
    required String countryText,
    required String startDate,
    required String endDate,
    required String contactPerson,
    required String contactPhone,
    required String contactEmail,
    List<Map<String, dynamic>> agenda = const [],
    List<int> supportingFileIds = const [],
    String? bannerImageUrl,
    String? coverImageUrl,
    int? bannerFileId,
    int? coverFileId,
    bool submit = true,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'program_type_id': programTypeId,
      'organizer_name': organizerName,
      'about': about,
      'venue': venue,
      'country_id': countryId,
      'city_text': cityText,
      'country_text': countryText,
      'start_date': startDate,
      'end_date': endDate,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'agenda': agenda,
      'supporting_file_ids': supportingFileIds,
      'submit': submit,
    };

    final effectiveBannerUrl = bannerImageUrl ?? coverImageUrl;
    if (effectiveBannerUrl != null && effectiveBannerUrl.trim().isNotEmpty) {
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

  /// GET /api/programs/:id - Get Program Detail
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

  /// PUT /api/programs/:id - Update Program (Draft / Changes Required)
  static Future<Map<String, dynamic>> updateProgramProposal(
    dynamic id, {
    required String title,
    required int programTypeId,
    required String organizerName,
    required String about,
    required String venue,
    required int countryId,
    required String cityText,
    required String countryText,
    required String startDate,
    required String endDate,
    required String contactPerson,
    required String contactPhone,
    required String contactEmail,
    List<Map<String, dynamic>> agenda = const [],
    List<int> supportingFileIds = const [],
    String? bannerImageUrl,
    String? coverImageUrl,
    int? bannerFileId,
    int? coverFileId,
    bool submit = true,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'program_type_id': programTypeId,
      'organizer_name': organizerName,
      'about': about,
      'venue': venue,
      'country_id': countryId,
      'city_text': cityText,
      'country_text': countryText,
      'start_date': startDate,
      'end_date': endDate,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'agenda': agenda,
      'supporting_file_ids': supportingFileIds,
      'submit': submit,
    };

    final effectiveBannerUrl = bannerImageUrl ?? coverImageUrl;
    if (effectiveBannerUrl != null && effectiveBannerUrl.trim().isNotEmpty) {
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
}


