import 'application_item_model.dart';

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

  // Submission metadata
  String? applicationId;
  DateTime? submissionDate;
  String status;

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
    this.applicationId,
    this.submissionDate,
    this.status = 'AI Audit',
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
      institutionTypeId: item.institutionType,
      institutionTypeTitle: item.institutionType,
      categoryMaxScore: maxScore,
      passScore: pass,
      institutionName: item.institutionName,
      applicationId: item.certificateId.isNotEmpty ? item.certificateId : item.id,
      submissionDate: DateTime.tryParse(item.issuedDate),
      status: item.status,
    );
  }
}

