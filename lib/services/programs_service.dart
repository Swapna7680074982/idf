import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/program_api_models.dart';
import '../models/program_model.dart';
import '../models/program_submission_model.dart';
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
    final effectiveLimit = limit > 50 ? 50 : (limit < 1 ? 20 : limit);
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': effectiveLimit.toString(),
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
    String? pincode,
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
      if (pincode != null && pincode.trim().isNotEmpty) ...{
        'pincode': pincode.trim(),
        'postal_code': pincode.trim(),
        'zip_code': pincode.trim(),
      },
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
    String? pincode,
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
      if (pincode != null && pincode.trim().isNotEmpty) ...{
        'pincode': pincode.trim(),
        'postal_code': pincode.trim(),
        'zip_code': pincode.trim(),
      },
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

  /// GET /api/programs/:id/attendees - Registered Participants of Program (Organizer only)
  static Future<ProgramAttendeesData?> getProgramAttendees(
    dynamic id, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await ApiClient.get(
        ApiConfig.programAttendees(id),
        queryParams: queryParams,
      );

      if (response is Map<String, dynamic>) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        return ProgramAttendeesData.fromJson(data);
      }
      return null;
    } on ApiException catch (e) {
      // 403 Forbidden: "You can only view registered users for programs you organized"
      if (e.statusCode == 403 || e.code == 'FORBIDDEN') {
        return null;
      }
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// 7. GET /api/applications/programs - My Applications List ("My Programs" Tab)
  static Future<Map<String, dynamic>> getMyApplications({
    String status = 'all',
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final effectiveLimit = limit > 50 ? 50 : (limit < 1 ? 20 : limit);
    final queryParams = <String, String>{
      'status': status,
      'page': page.toString(),
      'limit': effectiveLimit.toString(),
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
      if (data['application'] is Map<String, dynamic>) {
        return <String, dynamic>{
          ...data,
          ...(data['application'] as Map<String, dynamic>),
        };
      }
      return data;
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load application details.',
      statusCode: 200,
    );
  }

  /// Fetches application and program detail to build a fully prefilled ProgramSubmissionModel ready for wizard edit & resubmit
  static Future<ProgramSubmissionModel> getProgramModelForEdit(dynamic id) async {
    Map<String, dynamic>? appDetail;
    ProgramModel? programModel;

    // 1. Try GET /api/applications/programs/:id
    try {
      appDetail = await getMyApplicationDetail(id);
    } catch (e) {
      debugPrint('getMyApplicationDetail($id) error: $e');
    }

    // 2. Try GET /api/programs/:id
    try {
      programModel = await getProgramDetail(id);
    } catch (e) {
      debugPrint('getProgramDetail($id) error: $e');
    }

    // 3. If appDetail has an underlying program_id or program object, try that program ID if different
    if (appDetail != null && programModel == null) {
      final underlyingProgramId = appDetail['program_id'] ??
          appDetail['program']?['id'] ??
          appDetail['submission_details']?['program_id'] ??
          appDetail['event_details']?['id'] ??
          appDetail['event_details']?['program_id'];
      if (underlyingProgramId != null &&
          underlyingProgramId.toString() != id.toString()) {
        try {
          programModel = await getProgramDetail(underlyingProgramId);
        } catch (_) {}
      }
    }

    // 4. If programModel was loaded but appDetail was not, try fetching application by programNo
    if (appDetail == null && programModel?.programNo != null && programModel!.programNo!.isNotEmpty) {
      try {
        appDetail = await getMyApplicationDetail(programModel.programNo!);
      } catch (_) {}
    }

    // 5. If banner is still not found in appDetail or programModel, try matching via getPrograms or registered programs!
    final extractedBanner = ApiConfig.extractBannerUrl(appDetail) ?? programModel?.imageUrl;
    if (extractedBanner == null || extractedBanner.isEmpty) {
      final String? progNo = appDetail?['program_no']?.toString() ?? programModel?.programNo;
      final String? title = appDetail?['title']?.toString() ??
          appDetail?['program_name']?.toString() ??
          programModel?.title;

      try {
        final progsRes = await getPrograms(search: title ?? progNo, limit: 10);
        for (final p in progsRes.items) {
          final matchesProgNo = progNo != null && progNo.isNotEmpty && p.programNo == progNo;
          final matchesTitle = title != null && title.isNotEmpty && p.title.toLowerCase().trim() == title.toLowerCase().trim();
          final matchesId = p.id.toString() == id.toString();
          if (matchesProgNo || matchesTitle || matchesId) {
            final pBanner = ApiConfig.extractBannerUrl({
              'banner_image_url': p.bannerImageUrl,
              'cover_image_url': p.coverImageUrl,
              'banner': p.banner,
            });
            if (pBanner != null && pBanner.isNotEmpty) {
              appDetail ??= <String, dynamic>{};
              appDetail['banner_image_url'] = pBanner;
              appDetail['cover_image_url'] = pBanner;
              appDetail['banner'] = pBanner;
              break;
            }
          }
        }
      } catch (_) {}

      // Try registered programs if still not found
      if (appDetail?['banner_image_url'] == null) {
        try {
          final regRes = await getRegisteredPrograms(limit: 20);
          for (final p in regRes.items) {
            final matchesProgNo = progNo != null && progNo.isNotEmpty && p.programNo == progNo;
            final matchesTitle = title != null && title.isNotEmpty && p.title.toLowerCase().trim() == title.toLowerCase().trim();
            final matchesId = p.id.toString() == id.toString();
            if (matchesProgNo || matchesTitle || matchesId) {
              final pBanner = ApiConfig.extractBannerUrl({
                'banner_image_url': p.bannerImageUrl,
                'cover_image_url': p.coverImageUrl,
                'banner': p.banner,
              });
              if (pBanner != null && pBanner.isNotEmpty) {
                appDetail ??= <String, dynamic>{};
                appDetail['banner_image_url'] = pBanner;
                appDetail['cover_image_url'] = pBanner;
                appDetail['banner'] = pBanner;
                break;
              }
            }
          }
        } catch (_) {}
      }
    }

    return ProgramSubmissionModel.fromDetailJson(
      appDetail ?? {},
      programModel: programModel,
    );
  }

  /// 9. POST /api/programs/:id/ai-validation - Post AI Validation Result (Mobile -> Backend)
  static Future<Map<String, dynamic>> postAiValidationResult(
    dynamic programId, {
    String status = 'approved',
    List<Map<String, dynamic>>? checks,
  }) async {
    final bool isRejected = status.toLowerCase() == 'rejected' ||
        status.toLowerCase() == 'failed' ||
        (checks != null &&
            checks.any((c) {
              final s = c['status']?.toString().toLowerCase();
              return s == 'rejected' || s == 'failed';
            }));

    final String normalizedStatus = isRejected
        ? 'rejected'
        : (status.toLowerCase() == 'pending' ? 'pending' : 'completed');

    final effectiveChecks = (checks ?? [
      {'check_type': 'content_review', 'status': isRejected ? 'failed' : 'approved', 'details': null},
      {'check_type': 'program_details_match', 'status': isRejected ? 'failed' : 'approved', 'details': null},
      {'check_type': 'supporting_materials', 'status': isRejected ? 'failed' : 'approved', 'details': null},
      {'check_type': 'overall', 'status': isRejected ? 'failed' : 'approved', 'details': null},
    ]).map((c) {
      final copy = Map<String, dynamic>.from(c);
      final s = copy['status']?.toString().toLowerCase();
      if (s == 'rejected' || s == 'failed') {
        copy['status'] = 'failed';
        copy['status_label'] = 'FAILED';
      }
      return copy;
    }).toList();

    final body = <String, dynamic>{
      'status': normalizedStatus,
      'checks': effectiveChecks,
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


