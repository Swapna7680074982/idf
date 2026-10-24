import 'application_item_model.dart';
import '../services/api_config.dart';

/// Certification Category returned by GET /api/certification/categories
class CertificationCategory {
  final int id;
  final String code;
  final String name;
  final String description;
  final String icon;
  final int maxScore;
  final int passScore;
  final int certificateValidityMonths;
  final int? passPercent;

  const CertificationCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.maxScore,
    required this.passScore,
    required this.certificateValidityMonths,
    this.passPercent,
  });

  factory CertificationCategory.fromJson(Map<String, dynamic> json) {
    return CertificationCategory(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      maxScore: json['max_score'] is int
          ? json['max_score'] as int
          : int.tryParse(json['max_score']?.toString() ?? '0') ?? 0,
      passScore: json['pass_score'] is int
          ? json['pass_score'] as int
          : int.tryParse(json['pass_score']?.toString() ?? '0') ?? 0,
      certificateValidityMonths: json['certificate_validity_months'] is int
          ? json['certificate_validity_months'] as int
          : int.tryParse(json['certificate_validity_months']?.toString() ?? '24') ?? 24,
      passPercent: json['pass_percent'] is int
          ? json['pass_percent'] as int
          : int.tryParse(json['pass_percent']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'icon': icon,
        'max_score': maxScore,
        'pass_score': passScore,
        'certificate_validity_months': certificateValidityMonths,
        'pass_percent': passPercent,
      };

  String get emoji {
    switch (icon.toLowerCase()) {
      case 'building':
        return '🏢';
      case 'handshake':
        return '🤝';
      case 'school':
        return '🏫';
      case 'mortarboard':
      case 'graduation':
        return '🎓';
      case 'hospital':
        return '🏥';
      default:
        switch (code.toLowerCase()) {
          case 'workplace':
            return '🏢';
          case 'ngo':
            return '🤝';
          case 'school':
            return '🏫';
          case 'college':
          case 'university':
            return '🎓';
          case 'health_facility':
            return '🏥';
          default:
            return '📋';
        }
    }
  }
}

/// Dynamic detail field returned by POST /api/certification/categories/config
class CertificationDetailField {
  final int id;
  final String fieldKey;
  final String groupLabel;
  final String label;
  final String inputType; // 'select', 'number', 'decimal', 'text', etc.
  final String? unit; // e.g. 'sq ft'
  final String? placeholder;
  final bool isRequired;
  final List<String> options;

  const CertificationDetailField({
    required this.id,
    required this.fieldKey,
    required this.groupLabel,
    required this.label,
    required this.inputType,
    this.unit,
    this.placeholder,
    this.isRequired = false,
    this.options = const [],
  });

  factory CertificationDetailField.fromJson(Map<String, dynamic> json) {
    final optsRaw = json['options'];
    List<String> parsedOptions = [];
    if (optsRaw is List) {
      parsedOptions = optsRaw.map((e) => e.toString()).toList();
    }

    return CertificationDetailField(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      fieldKey: json['field_key']?.toString() ?? '',
      groupLabel: json['group_label']?.toString() ?? 'Details',
      label: json['label']?.toString() ?? '',
      inputType: json['input_type']?.toString().toLowerCase() ?? 'text',
      unit: json['unit']?.toString(),
      placeholder: json['placeholder']?.toString(),
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      options: parsedOptions,
    );
  }
}

/// Dynamic question inside each section from POST /api/certification/categories/config
class CertificationQuestion {
  final int id;
  final String text;
  final String answerType; // 'yes_no', 'text', 'number', etc.
  final String? placeholder;
  final bool isRequired;
  final List<String> options;

  const CertificationQuestion({
    required this.id,
    required this.text,
    required this.answerType,
    this.placeholder,
    this.isRequired = true,
    this.options = const [],
  });

  factory CertificationQuestion.fromJson(Map<String, dynamic> json) {
    final optsRaw = json['options'];
    List<String> parsedOpts = [];
    if (optsRaw is List) {
      parsedOpts = optsRaw.map((e) => e.toString()).toList();
    }

    return CertificationQuestion(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      text: json['text']?.toString() ?? '',
      answerType: json['answer_type']?.toString().toLowerCase() ?? 'yes_no',
      placeholder: json['placeholder']?.toString(),
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      options: parsedOpts,
    );
  }
}

/// Dynamic section returned from POST /api/certification/categories/config
class CertificationSection {
  final int id;
  final String code;
  final String name;
  final String icon;
  final int step;
  final int maxScore;
  final List<CertificationQuestion> questions;

  const CertificationSection({
    required this.id,
    required this.code,
    required this.name,
    required this.icon,
    required this.step,
    required this.maxScore,
    required this.questions,
  });

  factory CertificationSection.fromJson(Map<String, dynamic> json) {
    final qRaw = json['questions'];
    List<CertificationQuestion> qs = [];
    if (qRaw is List) {
      qs = qRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationQuestion.fromJson(e))
          .toList();
    }

    return CertificationSection(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      step: json['step'] is int
          ? json['step'] as int
          : int.tryParse(json['step']?.toString() ?? '1') ?? 1,
      maxScore: json['max_score'] is int
          ? json['max_score'] as int
          : int.tryParse(json['max_score']?.toString() ?? '0') ?? 0,
      questions: qs,
    );
  }

  String get emoji {
    switch (icon.toLowerCase()) {
      case 'infrastructure':
        return '🏗️';
      case 'policy':
      case 'organizational':
        return '📋';
      case 'person':
      case 'individual':
        return '👤';
      case 'scalability':
      case 'advocacy':
        return '🌱';
      default:
        return '📝';
    }
  }
}

/// Dynamic evidence requirement returned by POST /api/certification/categories/config
class CertificationEvidenceRequirement {
  final int id;
  final int sectionId;
  final String title;
  final String description;
  final String evidenceKind; // 'photo', 'document', 'either'
  final bool isRequired;
  final bool requiresGps;

  const CertificationEvidenceRequirement({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.description,
    required this.evidenceKind,
    required this.isRequired,
    required this.requiresGps,
  });

  factory CertificationEvidenceRequirement.fromJson(Map<String, dynamic> json) {
    return CertificationEvidenceRequirement(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      sectionId: json['section_id'] is int
          ? json['section_id'] as int
          : int.tryParse(json['section_id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      evidenceKind: json['evidence_kind']?.toString().toLowerCase() ?? 'photo',
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      requiresGps: json['requires_gps'] == true || json['requires_gps'] == 1,
    );
  }
}

/// Full category configuration returned by POST /api/certification/categories/config
class CertificationCategoryConfig {
  final CertificationCategory category;
  final List<CertificationDetailField> detailFields;
  final List<CertificationSection> sections;
  final List<CertificationEvidenceRequirement> evidenceRequirements;

  const CertificationCategoryConfig({
    required this.category,
    required this.detailFields,
    required this.sections,
    required this.evidenceRequirements,
  });

  factory CertificationCategoryConfig.fromJson(Map<String, dynamic> json) {
    final catJson = json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : <String, dynamic>{};

    final fieldsRaw = json['detail_fields'];
    List<CertificationDetailField> fields = [];
    if (fieldsRaw is List) {
      fields = fieldsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationDetailField.fromJson(e))
          .toList();
    }

    final sectionsRaw = json['sections'];
    List<CertificationSection> sects = [];
    if (sectionsRaw is List) {
      sects = sectionsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationSection.fromJson(e))
          .toList();
    }

    final evRaw = json['evidence_requirements'];
    List<CertificationEvidenceRequirement> evs = [];
    if (evRaw is List) {
      evs = evRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationEvidenceRequirement.fromJson(e))
          .toList();
    }

    return CertificationCategoryConfig(
      category: CertificationCategory.fromJson(catJson),
      detailFields: fields,
      sections: sects,
      evidenceRequirements: evs,
    );
  }
}

class InstitutionTypeInfo {
  final String id;
  final String title;
  final int maxPoints;
  final String description;
  final String emoji;
  final int? categoryId;
  final int? passScore;
  final int? passPercent;
  final int? validityMonths;

  const InstitutionTypeInfo({
    required this.id,
    required this.title,
    required this.maxPoints,
    required this.description,
    required this.emoji,
    this.categoryId,
    this.passScore,
    this.passPercent,
    this.validityMonths,
  });

  factory InstitutionTypeInfo.fromCategory(CertificationCategory cat) {
    return InstitutionTypeInfo(
      id: cat.code.isNotEmpty ? cat.code : cat.id.toString(),
      title: cat.name,
      maxPoints: cat.maxScore,
      description: cat.description,
      emoji: cat.emoji,
      categoryId: cat.id,
      passScore: cat.passScore,
      passPercent: cat.passPercent,
      validityMonths: cat.certificateValidityMonths,
    );
  }
}

class EvidenceItem {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  final String evidenceKind; // 'photo', 'document', 'either'
  final bool requiresGps;
  final int? sectionId;
  String? filePath;
  String? fileName;
  String? fileUrl;

  EvidenceItem({
    required this.id,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.evidenceKind = 'photo',
    this.requiresGps = false,
    this.sectionId,
    this.filePath,
    this.fileName,
    this.fileUrl,
  });

  factory EvidenceItem.fromRequirement(CertificationEvidenceRequirement req) {
    return EvidenceItem(
      id: req.id.toString(),
      title: req.title,
      description: req.description,
      isRequired: req.isRequired,
      evidenceKind: req.evidenceKind,
      requiresGps: req.requiresGps,
      sectionId: req.sectionId,
    );
  }
}

class CertificationApplicationModel {
  // Category Info
  int? categoryId;
  CertificationCategoryConfig? categoryConfig;

  // Step 1: Type
  String institutionTypeId;
  String institutionTypeTitle;
  int categoryMaxScore;
  int passScore;

  // Step 2: Institution Details
  String institutionName;
  String address;
  String country;
  int? countryId;
  String regionState;
  int? regionId;
  String city;
  int? cityId;
  String contactPerson;
  String contactPhone;
  String contactEmail;
  String numberOfRooms;
  String distanceFromMainRoad;
  String parkingAvailability;

  // Dynamic Detail Field Values: field_key -> value
  Map<String, dynamic> detailFieldValues;

  // Dynamic Question Answers: question_id -> value
  Map<int, dynamic> questionAnswers;

  // Step 3: Section 1 - Infrastructure / Amenities
  bool? hasSafeExerciseArea;
  bool? hasStandingDesks;
  bool? hasDedicatedWalkingTrail;
  bool? hasCycleStands;
  bool? hasPaPromotionSignage;

  // Step 4: Section 2 - Organizational / Policy
  bool? hasAnnualHealthChecks;
  String sportsEventsCount;
  bool? hasFormalPaPolicy;
  bool? hasStructuredErgonomicBreaks;

  // Step 5: Section 3 - Individual Level
  bool? hasPaChampions;
  String memberParticipationPercentage;
  bool? hasActivePlayIntegrated;

  // Step 6: Section 4 - Scalability / Advocacy
  bool? hasExternalPartnerships;
  String advocacyActivitiesDescription;
  bool? receivesSponsorship;

  // Step 7: Evidence
  List<EvidenceItem> evidenceItems;

  // Step 9: Declaration
  bool declarationAccepted;

  // Submission metadata & API tracking
  int? id;
  String? applicationId;
  String? applicationNo;
  DateTime? submissionDate;
  String status;
  String reviewStatus;
  String displayStatus;
  String decision;
  String? decisionText;
  List<CertificationTimelineStage>? timeline;
  List<CertificationAiValidationCheck>? aiValidation;
  List<CertificationMaterialItem>? materials;

  CertificationApplicationModel({
    this.categoryId,
    this.categoryConfig,
    this.institutionTypeId = '',
    this.institutionTypeTitle = '',
    this.categoryMaxScore = 0,
    this.passScore = 0,
    this.institutionName = '',
    this.address = '',
    this.country = '',
    this.countryId,
    this.regionState = '',
    this.regionId,
    this.city = '',
    this.cityId,
    this.contactPerson = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.numberOfRooms = '',
    this.distanceFromMainRoad = '',
    this.parkingAvailability = '',
    Map<String, dynamic>? detailFieldValues,
    Map<int, dynamic>? questionAnswers,
    this.hasSafeExerciseArea,
    this.hasStandingDesks,
    this.hasDedicatedWalkingTrail,
    this.hasCycleStands,
    this.hasPaPromotionSignage,
    this.hasAnnualHealthChecks,
    this.sportsEventsCount = '',
    this.hasFormalPaPolicy,
    this.hasStructuredErgonomicBreaks,
    this.hasPaChampions,
    this.memberParticipationPercentage = '',
    this.hasActivePlayIntegrated,
    this.hasExternalPartnerships,
    this.advocacyActivitiesDescription = '',
    this.receivesSponsorship,
    List<EvidenceItem>? evidenceItems,
    this.declarationAccepted = false,
    this.id,
    this.applicationId,
    this.applicationNo,
    this.submissionDate,
    this.status = 'Submitted',
    this.reviewStatus = 'ai_audit',
    this.displayStatus = 'Submitted',
    this.decision = 'Pending',
    this.decisionText,
    this.timeline,
    this.aiValidation,
    this.materials,
  })  : detailFieldValues = detailFieldValues ?? {},
        questionAnswers = questionAnswers ?? {},
        evidenceItems = evidenceItems ?? [];

  static CertificationApplicationModel prefilledForCertificate(
      CertificateApplicationItem item) {
    int maxScore = 0;
    int pass = 0;
    if (item.score.contains('/')) {
      final parts = item.score.split('/');
      pass = int.tryParse(parts[0].trim()) ?? 0;
      maxScore = int.tryParse(parts.length > 1 ? parts[1].trim() : '0') ?? 0;
    }

    return CertificationApplicationModel(
      id: int.tryParse(item.id),
      institutionTypeId: item.institutionType,
      institutionTypeTitle: item.institutionType,
      categoryMaxScore: maxScore,
      passScore: pass,
      institutionName: item.institutionName,
      applicationId: item.certificateId.isNotEmpty ? item.certificateId : item.id,
      applicationNo: item.certificateId.isNotEmpty ? item.certificateId : item.id,
      submissionDate: DateTime.tryParse(item.issuedDate),
      status: item.status,
    );
  }

  Map<String, dynamic> toSubmissionJson() {
    final Map<String, dynamic> qaMap = {};
    questionAnswers.forEach((k, v) {
      qaMap[k.toString()] = v;
    });

    final validEvidence = evidenceItems.where((e) =>
      (e.fileUrl != null && e.fileUrl!.isNotEmpty) ||
      (e.filePath != null && e.filePath!.isNotEmpty)
    ).map((e) {
      final reqId = int.tryParse(e.id) ?? 1;
      final effectiveUrl = (e.fileUrl != null && e.fileUrl!.isNotEmpty)
          ? e.fileUrl!
          : (e.filePath ?? '');
      final effectiveName = (e.fileName != null && e.fileName!.isNotEmpty)
          ? e.fileName!
          : 'evidence_doc';

      return <String, dynamic>{
        'id': reqId,
        'requirement_id': reqId,
        'title': e.title,
        'file_name': effectiveName,
        'file_url': effectiveUrl,
        'evidence_kind': e.evidenceKind,
        'source': 'upload',
      };
    }).toList();

    return {
      'category_id': categoryId ?? 1,
      'institution_name': institutionName,
      'institution_type': institutionTypeTitle.isNotEmpty ? institutionTypeTitle : 'Workplace / Worksite / Office / Hospital',
      'address': address,
      if (countryId != null) 'country_id': countryId,
      'country': country,
      if (regionId != null) 'region_id': regionId,
      'region': regionState,
      if (cityId != null) 'city_id': cityId,
      'city': city,
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'detail_fields': Map<String, dynamic>.from(detailFieldValues),
      'question_answers': qaMap,
      'evidence': validEvidence,
      'declaration_accepted': declarationAccepted,
    };
  }

  void updateFromApiResponse(Map<String, dynamic> data) {
    Map<String, dynamic>? appMap;
    if (data['application'] is Map<String, dynamic>) {
      appMap = data['application'] as Map<String, dynamic>;
    } else if (data['data'] is Map<String, dynamic>) {
      final d = data['data'] as Map<String, dynamic>;
      if (d['application'] is Map<String, dynamic>) {
        appMap = d['application'] as Map<String, dynamic>;
      } else {
        appMap = d;
      }
    } else {
      appMap = data;
    }

    // Extract ID (e.g. 2)
    if (appMap.containsKey('id') && appMap['id'] != null) {
      id = appMap['id'] is int ? appMap['id'] as int : int.tryParse(appMap['id'].toString());
    } else if (appMap.containsKey('application_id') && appMap['application_id'] != null) {
      final parsedId = int.tryParse(appMap['application_id'].toString());
      if (parsedId != null && parsedId > 0) id = parsedId;
    }
    if (appMap['submission'] is Map && (appMap['submission'] as Map)['id'] != null) {
      final parsedId = int.tryParse((appMap['submission'] as Map)['id'].toString());
      if (parsedId != null && parsedId > 0) id = parsedId;
    }

    // Extract official Application Number (e.g. "APP-CERT-2026-0002")
    if (appMap['application_no'] != null && appMap['application_no'].toString().trim().isNotEmpty) {
      applicationNo = appMap['application_no'].toString().trim();
      applicationId = applicationNo;
    } else if (appMap['application_id'] != null) {
      final appIdStr = appMap['application_id'].toString().trim();
      if (applicationNo == null || applicationNo!.isEmpty || !applicationNo!.contains('-')) {
        applicationId = appIdStr;
        applicationNo = appIdStr;
      }
    }
    if (appMap['submission'] is Map && (appMap['submission'] as Map)['application_id'] != null) {
      final subAppId = (appMap['submission'] as Map)['application_id'].toString().trim();
      if (subAppId.isNotEmpty && (applicationNo == null || applicationNo!.isEmpty || !applicationNo!.contains('-') || subAppId.contains('-'))) {
        applicationId = subAppId;
        applicationNo = applicationId;
      }
    }

    if (appMap['status'] != null) {
      status = appMap['status'].toString();
    }
    if (appMap['review_status'] != null) {
      reviewStatus = appMap['review_status'].toString();
    }
    if (appMap['display_status'] != null) {
      displayStatus = appMap['display_status'].toString();
    } else if (reviewStatus == 'under_review' || status == 'under_review') {
      displayStatus = 'In Review';
    }

    final subDetails = appMap['submission_details'] is Map ? appMap['submission_details'] as Map : null;
    if (appMap['decision'] != null) {
      decision = appMap['decision'].toString();
    } else if (subDetails != null && subDetails['decision'] != null) {
      decision = subDetails['decision']?.toString() ?? 'Pending';
    }

    if (appMap['decision_text'] != null) {
      decisionText = appMap['decision_text'].toString();
    } else if (subDetails != null && subDetails['decision_text'] != null) {
      decisionText = subDetails['decision_text'].toString();
    }

    if (appMap['submitted_at'] != null) {
      submissionDate = DateTime.tryParse(appMap['submitted_at'].toString()) ?? submissionDate;
    } else if (subDetails != null && subDetails['submitted'] != null) {
      submissionDate = DateTime.tryParse(subDetails['submitted'].toString()) ?? submissionDate;
    } else if (appMap['submission'] is Map && (appMap['submission'] as Map)['submission_date'] != null) {
      submissionDate = DateTime.tryParse((appMap['submission'] as Map)['submission_date'].toString()) ?? submissionDate;
    }

    if (appMap['timeline'] is List) {
      timeline = (appMap['timeline'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationTimelineStage.fromJson(e))
          .toList();
    }
    final rawAi = appMap['ai_audit'] ?? appMap['ai_validation'];
    if (rawAi is List) {
      aiValidation = rawAi
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationAiValidationCheck.fromJson(e))
          .toList();
    }
    final rawMaterials = appMap['evidence'] ?? appMap['materials'];
    if (rawMaterials is List) {
      materials = rawMaterials
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationMaterialItem.fromJson(e))
          .toList();
    }
  }
}

/// Timeline stage for certification workflow
class CertificationTimelineStage {
  final String stage;
  final String label;
  final String state; // 'completed', 'in_progress', 'pending'
  final String? note;
  final String? occurredAt;

  const CertificationTimelineStage({
    required this.stage,
    required this.label,
    required this.state,
    this.note,
    this.occurredAt,
  });

  factory CertificationTimelineStage.fromJson(Map<String, dynamic> json) {
    return CertificationTimelineStage(
      stage: json['stage']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      state: json['state']?.toString() ?? 'pending',
      note: json['note']?.toString(),
      occurredAt: json['occurred_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'stage': stage,
    'label': label,
    'state': state,
    if (note != null) 'note': note,
    if (occurredAt != null) 'occurred_at': occurredAt,
  };
}

/// AI Validation check item
class CertificationAiValidationCheck {
  final String? check;
  final String checkType;
  final String label;
  final String status; // 'pending', 'approved', 'rejected', 'changes_required'
  final String? statusLabel;
  final String? details;

  const CertificationAiValidationCheck({
    this.check,
    required this.checkType,
    required this.label,
    required this.status,
    this.statusLabel,
    this.details,
  });

  factory CertificationAiValidationCheck.fromJson(Map<String, dynamic> json) {
    final ct = json['check_type']?.toString() ?? json['check']?.toString() ?? '';
    final lbl = json['label']?.toString() ?? _defaultLabelForType(ct);
    final stat = json['status']?.toString() ?? 'pending';

    return CertificationAiValidationCheck(
      check: json['check']?.toString() ?? ct,
      checkType: ct,
      label: lbl,
      status: stat,
      statusLabel: json['status_label']?.toString() ?? (stat == 'approved' ? 'Approved' : 'Pending'),
      details: json['details']?.toString(),
    );
  }

  static String _defaultLabelForType(String type) {
    switch (type.toLowerCase()) {
      case 'evidence_review':
        return 'Evidence Review';
      case 'image_location_validation':
        return 'Image Location Validation';
      case 'detail_evidence_match':
        return 'Detail Evidence Match';
      case 'overall':
        return 'Overall';
      default:
        return type.replaceAll('_', ' ').toUpperCase();
    }
  }

  Map<String, dynamic> toJson() => {
    if (check != null) 'check': check,
    'check_type': checkType,
    'label': label,
    'status': status,
    if (statusLabel != null) 'status_label': statusLabel,
    if (details != null) 'details': details,
  };
}

/// Material / uploaded evidence item returned by GET application details
class CertificationMaterialItem {
  final dynamic id;
  final dynamic requirementId;
  final String title;
  final String name;
  final String kind;
  final String source;
  final double? latitude;
  final double? longitude;
  final String? capturedAt;
  final String aiStatus;
  final String? aiNote;
  final String url;

  const CertificationMaterialItem({
    required this.id,
    this.requirementId,
    required this.title,
    required this.name,
    required this.kind,
    required this.source,
    this.latitude,
    this.longitude,
    this.capturedAt,
    required this.aiStatus,
    this.aiNote,
    required this.url,
  });

  factory CertificationMaterialItem.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['url']?.toString() ??
        json['file_url']?.toString() ??
        (json['file'] is Map ? (json['file'] as Map)['url']?.toString() : null) ??
        '';
    final resolvedUrl = ApiConfig.resolveImageUrl(rawUrl) ?? rawUrl;

    final rawName = json['name']?.toString() ??
        json['file_name']?.toString() ??
        (json['file'] is Map ? (json['file'] as Map)['name']?.toString() : null) ??
        '';

    return CertificationMaterialItem(
      id: json['id'],
      requirementId: json['requirement_id'],
      title: json['title']?.toString() ?? '',
      name: rawName,
      kind: json['kind']?.toString() ?? json['evidence_kind']?.toString() ?? 'photo',
      source: json['source']?.toString() ?? 'upload',
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : null,
      capturedAt: json['captured_at']?.toString(),
      aiStatus: json['ai_status']?.toString() ?? 'pending',
      aiNote: json['ai_note']?.toString(),
      url: resolvedUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requirement_id': requirementId,
    'title': title,
    'name': name,
    'kind': kind,
    'source': source,
    'latitude': latitude,
    'longitude': longitude,
    'captured_at': capturedAt,
    'ai_status': aiStatus,
    if (aiNote != null) 'ai_note': aiNote,
    'url': url,
  };
}

/// Institution info in certification application
class CertificationInstitution {
  final String name;
  final int? categoryId;
  final String category;
  final String address;
  final int? countryId;
  final String country;
  final int? regionId;
  final String region;
  final int? cityId;
  final String city;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;

  const CertificationInstitution({
    required this.name,
    this.categoryId,
    required this.category,
    required this.address,
    this.countryId,
    required this.country,
    this.regionId,
    required this.region,
    this.cityId,
    required this.city,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
  });

  factory CertificationInstitution.fromJson(Map<String, dynamic> json) {
    return CertificationInstitution(
      name: json['name']?.toString() ?? '',
      categoryId: json['category_id'] is int ? json['category_id'] as int : int.tryParse(json['category_id']?.toString() ?? ''),
      category: json['category']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      countryId: json['country_id'] is int ? json['country_id'] as int : int.tryParse(json['country_id']?.toString() ?? ''),
      country: json['country']?.toString() ?? '',
      regionId: json['region_id'] is int ? json['region_id'] as int : int.tryParse(json['region_id']?.toString() ?? ''),
      region: json['region']?.toString() ?? '',
      cityId: json['city_id'] is int ? json['city_id'] as int : int.tryParse(json['city_id']?.toString() ?? ''),
      city: json['city']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category_id': categoryId,
    'category': category,
    'address': address,
    'country_id': countryId,
    'country': country,
    'region_id': regionId,
    'region': region,
    'city_id': cityId,
    'city': city,
    'contact_person': contactPerson,
    'contact_email': contactEmail,
    'contact_phone': contactPhone,
  };
}

/// Submission details block
class CertificationSubmissionDetails {
  final String applicationId;
  final String? submitted;
  final String? lastUpdated;
  final String currentStatus;
  final String displayStatus;
  final String? decision;

  const CertificationSubmissionDetails({
    required this.applicationId,
    this.submitted,
    this.lastUpdated,
    required this.currentStatus,
    required this.displayStatus,
    this.decision,
  });

  factory CertificationSubmissionDetails.fromJson(Map<String, dynamic> json) {
    return CertificationSubmissionDetails(
      applicationId: json['application_id']?.toString() ?? '',
      submitted: json['submitted']?.toString(),
      lastUpdated: json['last_updated']?.toString(),
      currentStatus: json['current_status']?.toString() ?? '',
      displayStatus: json['display_status']?.toString() ?? '',
      decision: json['decision']?.toString(),
    );
  }
}

/// Complete dossier returned by GET /api/applications/certificates/{id}
class CertificationApplicationDetail {
  final int id;
  final String applicationId;
  final String applicationNo;
  final String applicationType;
  final String status;
  final String reviewStatus;
  final String displayStatus;
  final String decision;
  final String? decisionText;
  final bool editable;
  final int currentStep;
  final int totalSteps;
  final String? submittedAt;
  final String? decisionAt;
  final String? reviewerComment;
  final String? adminComment;
  final String? aiValidationComment;
  final CertificationInstitution? institution;
  final CertificationSubmissionDetails? submissionDetails;
  final List<CertificationTimelineStage> timeline;
  final List<CertificationAiValidationCheck> aiValidation;
  final List<CertificationMaterialItem> materials;

  const CertificationApplicationDetail({
    required this.id,
    required this.applicationId,
    required this.applicationNo,
    required this.applicationType,
    required this.status,
    required this.reviewStatus,
    required this.displayStatus,
    required this.decision,
    this.decisionText,
    required this.editable,
    required this.currentStep,
    required this.totalSteps,
    this.submittedAt,
    this.decisionAt,
    this.reviewerComment,
    this.adminComment,
    this.aiValidationComment,
    this.institution,
    this.submissionDetails,
    this.timeline = const [],
    this.aiValidation = const [],
    this.materials = const [],
  });

  factory CertificationApplicationDetail.fromJson(Map<String, dynamic> json) {
    final tRaw = json['timeline'];
    List<CertificationTimelineStage> stages = [];
    if (tRaw is List) {
      stages = tRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationTimelineStage.fromJson(e))
          .toList();
    }

    final aiRaw = json['ai_validation'];
    List<CertificationAiValidationCheck> checks = [];
    if (aiRaw is List) {
      checks = aiRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationAiValidationCheck.fromJson(e))
          .toList();
    }

    final mRaw = json['materials'] ?? json['supporting_material'] ?? json['evidence'];
    List<CertificationMaterialItem> mats = [];
    if (mRaw is List) {
      mats = mRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationMaterialItem.fromJson(e))
          .toList();
    }

    return CertificationApplicationDetail(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      applicationId: json['application_id']?.toString() ?? '',
      applicationNo: json['application_no']?.toString() ?? json['application_id']?.toString() ?? '',
      applicationType: json['application_type']?.toString() ?? 'new',
      status: json['status']?.toString() ?? 'Submitted',
      reviewStatus: json['review_status']?.toString() ?? 'ai_audit',
      displayStatus: json['display_status']?.toString() ?? 'Submitted',
      decision: json['decision']?.toString() ?? 'Pending',
      decisionText: json['decision_text']?.toString() ?? 'Pending',
      editable: json['editable'] == true,
      currentStep: json['current_step'] is int ? json['current_step'] as int : 4,
      totalSteps: json['total_steps'] is int ? json['total_steps'] as int : 4,
      submittedAt: json['submitted_at']?.toString(),
      decisionAt: json['decision_at']?.toString(),
      reviewerComment: json['reviewer_comment']?.toString(),
      adminComment: json['admin_comment']?.toString(),
      aiValidationComment: json['ai_validation_comment']?.toString(),
      institution: json['institution'] is Map<String, dynamic>
          ? CertificationInstitution.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      submissionDetails: json['submission_details'] is Map<String, dynamic>
          ? CertificationSubmissionDetails.fromJson(json['submission_details'] as Map<String, dynamic>)
          : null,
      timeline: stages,
      aiValidation: checks,
      materials: mats,
    );
  }
}

