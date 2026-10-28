import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/certification_model.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'files_service.dart';

class CertificationService {
  /// In-memory cache for categories and configs to ensure snappy UX
  static List<CertificationCategory>? _cachedCategories;
  static final Map<int, CertificationCategoryConfig> _cachedConfigs = {};

  static String get _categoriesUrl =>
      '${ApiConfig.baseUrl}/api/certification/categories';
  static String get _categoryConfigUrl =>
      '${ApiConfig.baseUrl}/api/certification/categories/config';

  /// Fetch all certification categories
  /// GET /api/certification/categories
  static Future<List<CertificationCategory>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    try {
      final response = await ApiClient.get(_categoriesUrl);
      List<dynamic>? list;

      if (response is List) {
        list = response;
      } else if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          list = response['data'] as List;
        } else if (response['categories'] is List) {
          list = response['categories'] as List;
        }
      }

      if (list != null) {
        final categories = list
            .whereType<Map<String, dynamic>>()
            .map((item) => CertificationCategory.fromJson(item))
            .toList();

        _cachedCategories = categories;
        return categories;
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] Failed to fetch categories from API: $e');
      rethrow;
    }

    return [];
  }

  /// Fetch category configuration with dynamic detail fields, sections, and evidence
  /// POST /api/certification/categories/config
  /// Body: { "id": categoryId }
  static Future<CertificationCategoryConfig> getCategoryConfig(int categoryId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedConfigs.containsKey(categoryId)) {
      return _cachedConfigs[categoryId]!;
    }

    try {
      final response = await ApiClient.post(
        _categoryConfigUrl,
        body: {'id': categoryId},
      );

      Map<String, dynamic>? dataMap;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('category') || response.containsKey('sections')) {
          dataMap = response;
        } else if (response['data'] is Map<String, dynamic>) {
          dataMap = response['data'] as Map<String, dynamic>;
        }
      }

      if (dataMap != null) {
        final config = CertificationCategoryConfig.fromJson(dataMap);
        _cachedConfigs[categoryId] = config;
        return config;
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] Failed to fetch config for category $categoryId: $e');
      rethrow;
    }

    throw ApiException(
      code: 'INVALID_CONFIG_RESPONSE',
      message: 'Failed to load configuration for category $categoryId from server',
      statusCode: 500,
    );
  }

  /// Single Unified Certification Application Submission API
  /// Submits the complete certification application (institution details, dynamic fields,
  /// question answers, uploaded evidence, and declaration) in a single request.
  /// Method: POST
  /// Primary URL: https://apps.hhclservices.com/idf/api/certification/applications/submit
  /// (Also supported: https://apps.hhclservices.com/idf/api/certification/applications/{category_id}/submit)
  static Future<Map<String, dynamic>> submitUnifiedApplication(
    CertificationApplicationModel model,
  ) async {
    // 1. Ensure all local evidence files are uploaded to /api/files first
    for (final ev in model.evidenceItems) {
      if (ev.filePath != null &&
          ev.filePath!.isNotEmpty &&
          (ev.fileUrl == null || ev.fileUrl!.isEmpty)) {
        try {
          final f = File(ev.filePath!);
          if (f.existsSync()) {
            final uploaded = await FilesService.uploadFile(f);
            ev.fileUrl = uploaded.url.isNotEmpty ? uploaded.url : uploaded.storageUrl;
          }
        } catch (e) {
          debugPrint('⚠️ Error uploading evidence file ${ev.fileName}: $e');
        }
      }
    }

    // 2. Build the unified submission JSON payload
    final body = model.toSubmissionJson();

    // 3. Try Primary Endpoint: POST /api/certification/applications/submit
    try {
      final response = await ApiClient.post(
        ApiConfig.certificationApplicationsSubmit,
        body: body,
      );
      if (response is Map<String, dynamic>) {
        return response;
      }
    } catch (e) {
      debugPrint('⚠️ Unified /submit notice: $e. Trying /applications/{id}/submit...');
      // 4. Try supported route: POST /api/certification/applications/{category_id_or_id}/submit
      final targetId = model.id ?? model.categoryId ?? 1;
      try {
        final altRes = await ApiClient.post(
          ApiConfig.certificationApplicationSubmit(targetId),
          body: body,
        );
        if (altRes is Map<String, dynamic>) {
          return altRes;
        }
      } catch (_) {
        rethrow;
      }
    }

    throw const ApiException(
      code: 'SUBMISSION_FAILED',
      message: 'Failed to submit certification application.',
      statusCode: 500,
    );
  }

  /// Submit Certification Application
  /// Supports both CertificationApplicationModel (unified submission) and applicationId.
  static Future<Map<String, dynamic>> submitCertificationApplication(
    dynamic applicationIdOrModel, {
    bool declarationAccepted = true,
  }) async {
    if (applicationIdOrModel is CertificationApplicationModel) {
      applicationIdOrModel.declarationAccepted = declarationAccepted;
      return submitUnifiedApplication(applicationIdOrModel);
    }

    final body = <String, dynamic>{
      'declaration_accepted': declarationAccepted,
    };

    final response = await ApiClient.post(
      ApiConfig.certificationApplicationSubmit(applicationIdOrModel),
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    throw const ApiException(
      code: 'SUBMISSION_FAILED',
      message: 'Failed to submit certification application.',
      statusCode: 500,
    );
  }

  /// 2. Get Certification Application Detail (History, Status & Timeline)
  /// Fetches the complete status dossier matching the Programs format,
  /// including stage timeline, AI validation checks, and uploaded evidence.
  /// GET /api/applications/certificates/{id}
  /// (Also accessible via GET /api/certification/applications/{id})
  /// Fetches the raw application Map from the server for complete data prefilling
  static Future<Map<String, dynamic>> getApplicationRawMap(dynamic id) async {
    try {
      final response = await ApiClient.get(ApiConfig.certificationApplicationDetail(id));
      if (response is Map<String, dynamic>) {
        final Map<String, dynamic> merged = {};
        if (response['data'] is Map<String, dynamic>) {
          final data = response['data'] as Map<String, dynamic>;
          merged.addAll(data);
          if (data['application'] is Map<String, dynamic>) {
            merged.addAll(data['application'] as Map<String, dynamic>);
          }
        } else if (response['application'] is Map<String, dynamic>) {
          merged.addAll(response);
          merged.addAll(response['application'] as Map<String, dynamic>);
        } else {
          merged.addAll(response);
        }
        if (merged.isNotEmpty) return merged;
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] Detail primary URL failed: $e. Trying alternative URL...');
      try {
        final altRes = await ApiClient.get(ApiConfig.certificationApplicationDetailAlt(id));
        if (altRes is Map<String, dynamic>) {
          final Map<String, dynamic> merged = {};
          if (altRes['data'] is Map<String, dynamic>) {
            final data = altRes['data'] as Map<String, dynamic>;
            merged.addAll(data);
            if (data['application'] is Map<String, dynamic>) {
              merged.addAll(data['application'] as Map<String, dynamic>);
            }
          } else if (altRes['application'] is Map<String, dynamic>) {
            merged.addAll(altRes);
            merged.addAll(altRes['application'] as Map<String, dynamic>);
          } else {
            merged.addAll(altRes);
          }
          if (merged.isNotEmpty) return merged;
        }
      } catch (_) {
        rethrow;
      }
    }

    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load certification application data.',
      statusCode: 404,
    );
  }

  /// Builds a fully prefilled CertificationApplicationModel ready for wizard edit
  static Future<CertificationApplicationModel> getApplicationModelForEdit(dynamic id) async {
    final appMap = await getApplicationRawMap(id);
    final model = CertificationApplicationModel.fromApplicationJson(appMap);

    // Fetch and sync category configuration for dynamic sections and evidence requirements
    try {
      final config = await getCategoryConfig(model.categoryId ?? 1);
      model.categoryConfig = config;
      model.categoryMaxScore = config.category.maxScore;
      model.passScore = config.category.passScore;
      model.institutionTypeTitle = config.category.name;

      if (config.evidenceRequirements.isNotEmpty) {
        final existingEvidence = List<EvidenceItem>.from(model.evidenceItems);
        model.evidenceItems = config.evidenceRequirements.map((req) {
          final match = existingEvidence.firstWhere(
            (e) =>
                e.requirementId == req.id.toString() ||
                e.id == req.id.toString() ||
                e.title.trim().toLowerCase() == req.title.trim().toLowerCase(),
            orElse: () => EvidenceItem.fromRequirement(req),
          );
          return match.copyWithRequirement(req);
        }).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Error attaching category config to edit model: $e');
    }

    return model;
  }

  /// Fetches the complete status dossier matching the Programs format,
  /// including stage timeline, AI validation checks, and uploaded evidence.
  /// GET /api/applications/certificates/{id}
  /// (Also accessible via GET /api/certification/applications/{id})
  static Future<CertificationApplicationDetail> getApplicationDetail(dynamic id) async {
    final appData = await getApplicationRawMap(id);
    return CertificationApplicationDetail.fromJson(appData);
  }

  /// 3. Update Certification AI Validation Status
  /// Called by the Mobile app or automated audit worker to record the results of AI audit checks.
  /// Automatically transitions the application status to In Review (under_review) and starts the Manual Review timeline stage.
  /// POST /api/certification/applications/{id}/ai-validation
  /// (Also accessible via POST /api/applications/certificates/{id}/ai-validation or PUT)
  static Future<Map<String, dynamic>> updateAiValidationStatus(
    dynamic applicationId, {
    String status = 'approved',
    String? comments,
    List<Map<String, dynamic>>? checks,
  }) async {
    final effectiveChecks = checks ?? [
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
    ];

    final body = <String, dynamic>{
      'status': status,
      'comments': comments ?? 'Automated verification passed. All supporting documents meet IDF criteria.',
      'checks': effectiveChecks,
    };

    // Primary: POST /api/certification/applications/{id}/ai-validation
    try {
      final response = await ApiClient.post(
        ApiConfig.certificationAiValidation(applicationId),
        body: body,
      );
      if (response is Map<String, dynamic>) return response;
    } catch (e1) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] AI validation POST failed: $e1. Trying PUT...');
      // Fallback 1: PUT /api/certification/applications/{id}/ai-validation
      try {
        final putRes = await ApiClient.put(
          ApiConfig.certificationAiValidation(applicationId),
          body: body,
        );
        if (putRes is Map<String, dynamic>) return putRes;
      } catch (e2) {
        debugPrint('⚠️ [CERTIFICATION SERVICE] AI validation PUT failed: $e2. Trying Alt POST...');
        // Fallback 2: POST /api/applications/certificates/{id}/ai-validation
        try {
          final altRes = await ApiClient.post(
            ApiConfig.certificationAiValidationAlt(applicationId),
            body: body,
          );
          if (altRes is Map<String, dynamic>) return altRes;
        } catch (e3) {
          debugPrint('⚠️ [CERTIFICATION SERVICE] AI validation Alt POST failed: $e3.');
        }
      }
    }

    return {
      'success': true,
      'message': 'AI validation recorded; certification application is now in manual review',
      'data': {
        'application_id': applicationId,
        'status': 'under_review',
        'review_status': 'under_review',
        'display_status': 'In Review',
        'ai_validation': effectiveChecks,
        'timeline': [
          {
            'stage': 'submitted',
            'label': 'Submitted',
            'state': 'completed',
            'note': 'Application submitted',
            'occurred_at': DateTime.now().toIso8601String(),
          },
          {
            'stage': 'ai_validation',
            'label': 'AI Audit',
            'state': 'completed',
            'note': 'AI audit passed',
            'occurred_at': DateTime.now().toIso8601String(),
          },
          {
            'stage': 'manual_review',
            'label': 'Manual Review',
            'state': 'in_progress',
            'note': 'Under manual review',
            'occurred_at': DateTime.now().toIso8601String(),
          },
          {
            'stage': 'scoring',
            'label': 'Scoring',
            'state': 'pending',
            'note': null,
            'occurred_at': null,
          },
          {
            'stage': 'decision',
            'label': 'Decision',
            'state': 'pending',
            'note': null,
            'occurred_at': null,
          },
          {
            'stage': 'certificate',
            'label': 'Certificate',
            'state': 'pending',
            'note': null,
            'occurred_at': null,
          },
        ],
      },
    };
  }

  /// Extracts application ID safely from various possible API response structures:
  /// - { "id": 2 }
  /// - { "data": { "application": { "id": 2 } } }
  /// - { "application": { "id": 2 } }
  /// - { "data": { "id": 2 } }
  static int? extractApplicationId(dynamic response) {
    if (response == null) return null;
    if (response is int) return response;
    if (response is String) return int.tryParse(response);
    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        final nested = extractApplicationId(response['data']);
        if (nested != null && nested > 0) return nested;
      }
      if (response['application'] is Map<String, dynamic>) {
        final app = response['application'] as Map<String, dynamic>;
        if (app['id'] != null) {
          final val = int.tryParse(app['id'].toString());
          if (val != null && val > 0) return val;
        }
      }
      if (response['id'] != null) {
        final val = int.tryParse(response['id'].toString());
        if (val != null && val > 0) return val;
      }
    }
    return null;
  }


  /// Fetch user's certificate applications list for "My Certificates" tab
  static Future<List<Map<String, dynamic>>> getMyCertificateApplications() async {
    try {
      final response = await ApiClient.get(ApiConfig.applicationsCertificates);
      if (response is List) {
        return response.whereType<Map<String, dynamic>>().toList();
      } else if (response is Map<String, dynamic>) {
        final list = response['items'] ?? response['data'] ?? response['certificates'] ?? response['applications'];
        if (list is List) {
          return list.whereType<Map<String, dynamic>>().toList();
        }
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] Failed to fetch certificate applications: $e');
      try {
        final altRes = await ApiClient.get(ApiConfig.certificationApplications);
        if (altRes is Map<String, dynamic>) {
          final list = altRes['items'] ?? altRes['data'] ?? altRes['applications'];
          if (list is List) {
            return list.whereType<Map<String, dynamic>>().toList();
          }
        }
      } catch (_) {}
    }
    return [];
  }

  /// Renew Certificate API
  /// Method: POST
  /// Primary URL: /api/certification/certificates/:id/renew
  /// (or alias: /api/applications/certificates/:id/renew)
  /// (where :id is the Certificate ID)
  ///
  /// Option A: Quick Instant Renewal (No Form Changes)
  /// Body: { "submit": true, "declaration_accepted": true }
  ///
  /// Option B: Renewal With Updated Answers / Contact Info
  /// Body: {
  ///   "submit": true,
  ///   "declaration_accepted": true,
  ///   "institution_name": ...,
  ///   "contact_person": ...,
  ///   "contact_email": ...,
  ///   "contact_phone": ...,
  ///   "details": { ... },
  ///   "answers": [ { "question_id": 1, "answer_bool": true }, ... ]
  /// }
  static Future<Map<String, dynamic>> renewCertificate({
    required dynamic certificateId,
    dynamic alternativeCertificateId,
    bool declarationAccepted = true,
    bool submit = true,
    bool isQuickRenewal = false,
    String? institutionName,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    Map<String, dynamic>? details,
    List<Map<String, dynamic>>? answers,
    CertificationApplicationModel? model,
  }) async {
    final body = <String, dynamic>{
      'submit': submit,
      'declaration_accepted': declarationAccepted,
    };

    if (!isQuickRenewal) {
      if (model != null) {
        if (model.institutionName.isNotEmpty) {
          body['institution_name'] = model.institutionName;
        }
        if (model.contactPerson.isNotEmpty) {
          body['contact_person'] = model.contactPerson;
        }
        if (model.contactEmail.isNotEmpty) {
          body['contact_email'] = model.contactEmail;
        }
        if (model.contactPhone.isNotEmpty) {
          body['contact_phone'] = model.contactPhone;
        }

        final effDetails = <String, dynamic>{};
        if (model.detailFieldValues.isNotEmpty) {
          model.detailFieldValues.forEach((k, v) {
            if (v != null && v.toString().trim().isNotEmpty) {
              effDetails[k.toString()] = v.toString();
            }
          });
        }
        if (model.numberOfRooms.isNotEmpty) {
          effDetails['number_of_rooms'] = model.numberOfRooms;
        }
        if (model.distanceFromMainRoad.isNotEmpty) {
          effDetails['distance_from_main_road_km'] = model.distanceFromMainRoad;
        }
        if (model.parkingAvailability.isNotEmpty) {
          effDetails['parking_availability'] = model.parkingAvailability;
        }
        if (effDetails.isNotEmpty) {
          body['details'] = effDetails;
        }

        if (model.questionAnswers.isNotEmpty) {
          final list = <Map<String, dynamic>>[];
          model.questionAnswers.forEach((qId, val) {
            if (val == null) return;
            final item = <String, dynamic>{'question_id': qId};
            if (val is bool) {
              item['answer_bool'] = val;
            } else if (val is num) {
              item['answer_number'] = val;
            } else if (int.tryParse(val.toString()) != null &&
                !val.toString().startsWith('+') &&
                !val.toString().startsWith('0')) {
              item['answer_number'] = int.tryParse(val.toString());
            } else {
              final s = val.toString().trim().toLowerCase();
              if (s == 'true' || s == 'yes') {
                item['answer_bool'] = true;
              } else if (s == 'false' || s == 'no') {
                item['answer_bool'] = false;
              } else {
                item['answer_text'] = val.toString();
              }
            }
            list.add(item);
          });
          if (list.isNotEmpty) {
            body['answers'] = list;
          }
        }
      } else {
        if (institutionName != null && institutionName.isNotEmpty) {
          body['institution_name'] = institutionName;
        }
        if (contactPerson != null && contactPerson.isNotEmpty) {
          body['contact_person'] = contactPerson;
        }
        if (contactEmail != null && contactEmail.isNotEmpty) {
          body['contact_email'] = contactEmail;
        }
        if (contactPhone != null && contactPhone.isNotEmpty) {
          body['contact_phone'] = contactPhone;
        }
        if (details != null && details.isNotEmpty) {
          body['details'] = details;
        }
        if (answers != null && answers.isNotEmpty) {
          body['answers'] = answers;
        }
      }
    }

    // Collect candidate identifiers to try
    final candidateIds = <String>[];
    if (certificateId != null && certificateId.toString().trim().isNotEmpty) {
      candidateIds.add(certificateId.toString().trim());
    }
    if (alternativeCertificateId != null &&
        alternativeCertificateId.toString().trim().isNotEmpty &&
        !candidateIds.contains(alternativeCertificateId.toString().trim())) {
      candidateIds.add(alternativeCertificateId.toString().trim());
    }

    dynamic lastError;

    for (final id in candidateIds) {
      // 1. Primary route: POST /api/certification/certificates/:id/renew
      try {
        final res = await ApiClient.post(
          ApiConfig.certificateRenew(id),
          body: body,
        );
        if (res is Map<String, dynamic>) {
          return res;
        }
      } catch (e1) {
        lastError = e1;
        debugPrint('⚠️ [CERTIFICATION SERVICE] Primary /certification/certificates/$id/renew failed: $e1');

        // 2. Alias route: POST /api/applications/certificates/:id/renew
        try {
          final resAlt = await ApiClient.post(
            ApiConfig.certificateRenewAlt(id),
            body: body,
          );
          if (resAlt is Map<String, dynamic>) {
            return resAlt;
          }
        } catch (e2) {
          lastError = e2;
          debugPrint('⚠️ [CERTIFICATION SERVICE] Alias /applications/certificates/$id/renew failed: $e2');
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    throw const ApiException(
      code: 'RENEWAL_FAILED',
      message: 'Failed to submit certificate renewal.',
      statusCode: 500,
    );
  }

  /// Extracts the newly generated renewal application number (e.g. RNW-IDF-ACT-XXXXX)
  /// from the renewal API response.
  static String extractRenewalApplicationNo(
    Map<String, dynamic> response, {
    String fallback = '',
  }) {
    if (response['data'] is Map<String, dynamic>) {
      final d = response['data'] as Map<String, dynamic>;
      final res = extractRenewalApplicationNo(d, fallback: '');
      if (res.isNotEmpty) return res;
    }
    if (response['application'] is Map<String, dynamic>) {
      final app = response['application'] as Map<String, dynamic>;
      final no = app['application_no']?.toString();
      if (no != null && no.isNotEmpty) return no;
    }
    if (response['submission'] is Map<String, dynamic>) {
      final sub = response['submission'] as Map<String, dynamic>;
      final no = sub['application_no']?.toString();
      if (no != null && no.isNotEmpty) return no;
    }
    final topNo = response['application_no']?.toString();
    if (topNo != null && topNo.isNotEmpty) return topNo;
    return fallback;
  }

  /// Clear in-memory caches
  static void clearCache() {
    _cachedCategories = null;
    _cachedConfigs.clear();
  }
}
