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

enum AnswerFormatType {
  yesNo,
  percentage,
  numeric,
  singleChoice,
  textNarrative,
  checkbox,
}

class CertificationQuestionOption {
  final dynamic id;
  final String label;

  const CertificationQuestionOption({
    required this.id,
    required this.label,
  });

  factory CertificationQuestionOption.fromJson(dynamic json) {
    if (json is Map) {
      final id = json['id'] ?? json['option_id'] ?? json['value'] ?? json['code'] ?? json['key'] ?? '';
      final label = json['label'] ?? json['name'] ?? json['title'] ?? json['text'] ?? id.toString();
      return CertificationQuestionOption(id: id, label: label.toString());
    }
    return CertificationQuestionOption(id: json, label: json.toString());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
  };
}

/// Dynamic question inside each section from POST /api/certification/categories/config
class CertificationQuestion {
  final int id;
  final String text;
  final String answerType; // 'yes_no', 'text', 'number', 'percentage', 'single_choice', 'checkbox', etc.
  final String? placeholder;
  final bool isRequired;
  final List<String> options;
  final List<CertificationQuestionOption> optionItems;

  const CertificationQuestion({
    required this.id,
    required this.text,
    required this.answerType,
    this.placeholder,
    this.isRequired = true,
    this.options = const [],
    this.optionItems = const [],
  });

  AnswerFormatType get formatType {
    final t = answerType.toLowerCase().trim();
    if (t.contains('check') || t.contains('multi') || t.contains('box')) {
      return AnswerFormatType.checkbox;
    }
    if (t.contains('percent')) {
      return AnswerFormatType.percentage;
    }
    if (t.contains('num') || t.contains('int') || t.contains('decimal') || t.contains('count') || t.contains('float')) {
      return AnswerFormatType.numeric;
    }
    if (t.contains('choice') || t.contains('select') || t.contains('radio') || t.contains('dropdown') || (optionItems.isNotEmpty && !t.contains('yes_no') && !t.contains('bool'))) {
      return AnswerFormatType.singleChoice;
    }
    if (t.contains('text') || t.contains('narrative') || t.contains('string') || t.contains('textarea')) {
      return AnswerFormatType.textNarrative;
    }
    return AnswerFormatType.yesNo;
  }

  factory CertificationQuestion.fromJson(Map<String, dynamic> json) {
    var rawText = json['text']?.toString() ?? '';
    var rawAnswerType = json['answer_type']?.toString().toLowerCase() ?? 'yes_no';

    final optsRaw = json['options'] ?? json['choices'] ?? json['answer_options'];
    List<String> parsedOpts = [];
    List<CertificationQuestionOption> parsedOptionItems = [];
    if (optsRaw is List) {
      for (final item in optsRaw) {
        final opt = CertificationQuestionOption.fromJson(item);
        parsedOptionItems.add(opt);
        parsedOpts.add(opt.label);
      }
    }

    // 12Q. The question relating to active office policies: separate into three distinct options:
    // a. Ergonomic breaks, breaking sedentary time, or five-minute activity breaks.
    // b. Ten minutes of office time at any point during the day dedicated to music and active dance steps or other movements led by an instructor.
    // c. Weekly office sports activities in which employees hire a space or use an available workplace space to compete in teams.
    final textLower = rawText.toLowerCase();
    final isOfficePolicyQuestion = textLower.contains('active office') ||
        textLower.contains('activities exist at the workplace') ||
        textLower.contains('ergonomic breaks') ||
        (json['id'] != null && json['id'].toString() == '12');

    if (isOfficePolicyQuestion) {
      rawText = 'Do any of the following two activities exist at the workplace as an ACTIVE office policy?';
      rawAnswerType = 'checkbox';
      parsedOptionItems = const [
        CertificationQuestionOption(
          id: 'a',
          label: 'Ergonomic breaks, breaking sedentary time, or five-minute activity breaks.',
        ),
        CertificationQuestionOption(
          id: 'b',
          label: 'Ten minutes of office time at any point during the day dedicated to music and active dance steps or other movements led by an instructor.',
        ),
        CertificationQuestionOption(
          id: 'c',
          label: 'Weekly office sports activities in which employees hire a space or use an available workplace space to compete in teams.',
        ),
      ];
      parsedOpts = parsedOptionItems.map((o) => o.label).toList();
    }

    return CertificationQuestion(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      text: rawText,
      answerType: rawAnswerType,
      placeholder: json['placeholder']?.toString(),
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      options: parsedOpts,
      optionItems: parsedOptionItems,
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

class EvidenceAttachment {
  String? filePath;
  String? fileName;
  String? fileUrl;

  EvidenceAttachment({
    this.filePath,
    this.fileName,
    this.fileUrl,
  });

  factory EvidenceAttachment.fromMap(Map<String, dynamic> map) {
    return EvidenceAttachment(
      filePath: map['file_path']?.toString() ?? map['filePath']?.toString(),
      fileName: map['file_name']?.toString() ?? map['fileName']?.toString() ?? map['name']?.toString(),
      fileUrl: map['file_url']?.toString() ?? map['fileUrl']?.toString() ?? map['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (filePath != null) 'file_path': filePath,
    if (fileName != null) 'file_name': fileName,
    if (fileUrl != null) 'file_url': fileUrl,
  };
}

class EvidenceItem {
  final String id;
  final String? requirementId;
  final String title;
  final String description;
  final bool isRequired;
  final String evidenceKind; // 'photo', 'document', 'either'
  final bool requiresGps;
  final int? sectionId;
  List<EvidenceAttachment> attachments;

  EvidenceItem({
    required this.id,
    this.requirementId,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.evidenceKind = 'photo',
    this.requiresGps = false,
    this.sectionId,
    String? filePath,
    String? fileName,
    String? fileUrl,
    List<EvidenceAttachment>? attachments,
  }) : attachments = attachments ?? [] {
    if ((filePath != null && filePath.isNotEmpty) ||
        (fileName != null && fileName.isNotEmpty) ||
        (fileUrl != null && fileUrl.isNotEmpty)) {
      if (this.attachments.isEmpty) {
        this.attachments.add(EvidenceAttachment(
          filePath: filePath,
          fileName: (fileName != null && fileName.isNotEmpty)
              ? fileName
              : fileUrl?.split('/').last,
          fileUrl: fileUrl,
        ));
      }
    }
  }

  String? get filePath => attachments.isNotEmpty ? attachments.first.filePath : null;
  set filePath(String? val) {
    if (val == null) {
      if (attachments.isNotEmpty) attachments.first.filePath = null;
    } else {
      if (attachments.isEmpty) {
        attachments.add(EvidenceAttachment(filePath: val));
      } else {
        attachments.first.filePath = val;
      }
    }
  }

  String? get fileName => attachments.isNotEmpty ? attachments.first.fileName : null;
  set fileName(String? val) {
    if (val == null) {
      if (attachments.isNotEmpty) attachments.first.fileName = null;
    } else {
      if (attachments.isEmpty) {
        attachments.add(EvidenceAttachment(fileName: val));
      } else {
        attachments.first.fileName = val;
      }
    }
  }

  String? get fileUrl => attachments.isNotEmpty ? attachments.first.fileUrl : null;
  set fileUrl(String? val) {
    if (val == null) {
      if (attachments.isNotEmpty) attachments.first.fileUrl = null;
    } else {
      if (attachments.isEmpty) {
        attachments.add(EvidenceAttachment(fileUrl: val));
      } else {
        attachments.first.fileUrl = val;
      }
    }
  }

  bool get hasAttachments => attachments.any((a) =>
      (a.fileName != null && a.fileName!.isNotEmpty) ||
      (a.filePath != null && a.filePath!.isNotEmpty) ||
      (a.fileUrl != null && a.fileUrl!.isNotEmpty));

  bool hasAttachmentMatching({String? fileName, String? fileUrl, String? filePath}) {
    return attachments.any((a) {
      if (fileUrl != null && fileUrl.isNotEmpty && a.fileUrl != null && a.fileUrl!.isNotEmpty) {
        return a.fileUrl == fileUrl;
      }
      if (filePath != null && filePath.isNotEmpty && a.filePath != null && a.filePath!.isNotEmpty) {
        return a.filePath == filePath;
      }
      if (fileName != null && fileName.isNotEmpty && a.fileName != null && a.fileName!.isNotEmpty) {
        if ((a.fileUrl == null || a.fileUrl!.isEmpty) &&
            (a.filePath == null || a.filePath!.isEmpty) &&
            (fileUrl == null || fileUrl.isEmpty) &&
            (filePath == null || filePath.isEmpty)) {
          return a.fileName == fileName;
        }
      }
      return false;
    });
  }

  void addAttachment({String? filePath, String? fileName, String? fileUrl}) {
    attachments.add(EvidenceAttachment(
      filePath: filePath,
      fileName: (fileName != null && fileName.isNotEmpty)
          ? fileName
          : fileUrl?.split('/').last,
      fileUrl: fileUrl,
    ));
  }

  void removeAttachmentAt(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
    }
  }

  factory EvidenceItem.fromRequirement(CertificationEvidenceRequirement req) {
    return EvidenceItem(
      id: req.id.toString(),
      requirementId: req.id.toString(),
      title: req.title,
      description: req.description,
      isRequired: req.isRequired,
      evidenceKind: req.evidenceKind,
      requiresGps: req.requiresGps,
      sectionId: req.sectionId,
    );
  }

  EvidenceItem copyWithRequirement(CertificationEvidenceRequirement req) {
    final copyAttachments = attachments.map((a) => EvidenceAttachment(
      filePath: a.filePath,
      fileName: a.fileName,
      fileUrl: a.fileUrl,
    )).toList();

    return EvidenceItem(
      id: req.id.toString(),
      requirementId: req.id.toString(),
      title: req.title,
      description: req.description,
      isRequired: req.isRequired,
      evidenceKind: req.evidenceKind,
      requiresGps: req.requiresGps,
      sectionId: req.sectionId,
      attachments: copyAttachments,
      filePath: filePath,
      fileName: (fileName != null && fileName!.isNotEmpty) ? fileName : (fileUrl?.split('/').last),
      fileUrl: fileUrl,
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
  String pincode;
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
    this.pincode = '',
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

  /// Safely gets a boolean answer by int or string question id
  bool? getQuestionBool(dynamic questionId) {
    if (questionId == null) return null;
    final intId = int.tryParse(questionId.toString());
    if (intId == null || !questionAnswers.containsKey(intId)) return null;
    final val = questionAnswers[intId];
    if (val == null) return null;
    if (val is bool) return val;
    if (val is num) return val == 1;
    final s = val.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return null;
  }

  /// Safely checks if a question has been answered (boolean, list, string, number, map)
  bool isQuestionAnswered(dynamic questionId) {
    if (questionId == null) return false;
    final intId = int.tryParse(questionId.toString());
    if (intId == null || !questionAnswers.containsKey(intId)) return false;
    final val = questionAnswers[intId];
    if (val == null) return false;
    if (val is bool) return true;
    if (intId == 12) {
      if (val is List) return val.length >= 2;
      if (val is String) {
        return val.split(',').where((s) => s.trim().isNotEmpty).length >= 2;
      }
      return false;
    }
    if (val is List) return val.isNotEmpty;
    if (val is String) return val.trim().isNotEmpty;
    if (val is num) return true;
    if (val is Map) {
      if (val.containsKey('options')) {
        final opts = val['options'];
        if (opts is List) {
          if (intId == 12) return opts.length >= 2;
          return opts.isNotEmpty;
        }
      }
      final opt = val['option_id'] ?? val['id'] ?? val['value'] ?? val['text'] ?? val['label'];
      if (opt != null && opt.toString().trim().isNotEmpty) return true;
      return val.isNotEmpty;
    }
    return true;
  }

  /// Sets a question answer
  void setQuestionAnswer(dynamic questionId, dynamic answer) {
    final intId = int.tryParse(questionId.toString());
    if (intId != null) {
      questionAnswers[intId] = answer;
    }
  }

  /// Checks if any evidence requirement exists for this certification
  bool get isEvidenceRequired {
    if (evidenceItems.any((e) => e.isRequired)) return true;
    if (categoryConfig != null && categoryConfig!.evidenceRequirements.isNotEmpty) return true;
    return evidenceItems.isNotEmpty;
  }

  /// Checks if mandatory evidence is missing (i.e. required but no files attached)
  bool get hasMissingRequiredEvidence {
    if (evidenceItems.isEmpty) {
      if (categoryConfig != null && categoryConfig!.evidenceRequirements.isNotEmpty) {
        return true;
      }
      return false;
    }

    final reqItems = evidenceItems.where((e) => e.isRequired).toList();
    if (reqItems.isNotEmpty) {
      return reqItems.any((e) => !e.hasAttachments);
    }

    if (categoryConfig != null && categoryConfig!.evidenceRequirements.isNotEmpty) {
      return evidenceItems.any((e) => !e.hasAttachments);
    }

    return false;
  }

  /// Checks if ANY evidence has been uploaded at all
  bool get hasAnyEvidenceUploaded {
    return evidenceItems.any((e) => e.hasAttachments);
  }

  static CertificationApplicationModel prefilledForCertificate(
      CertificateApplicationItem item) {
    int maxScore = 0;
    int pass = 0;
    if (item.score.contains('/')) {
      final parts = item.score.split('/');
      pass = int.tryParse(parts[0].trim()) ?? 0;
      maxScore = int.tryParse(parts.length > 1 ? parts[1].trim() : '0') ?? 0;
    }

    final parsedId = int.tryParse(item.id) ?? int.tryParse(item.certificateId);

    return CertificationApplicationModel(
      id: parsedId,
      institutionTypeId: item.institutionType,
      institutionTypeTitle: item.institutionType,
      categoryMaxScore: maxScore,
      passScore: pass,
      institutionName: item.institutionName,
      applicationId: item.applicationNo.isNotEmpty ? item.applicationNo : (item.id.isNotEmpty ? item.id : item.certificateId),
      applicationNo: item.applicationNo.isNotEmpty ? item.applicationNo : (item.id.isNotEmpty ? item.id : item.certificateId),
      submissionDate: DateTime.tryParse(item.issuedDate),
      status: item.status,
      address: item.address,
      city: item.city,
      pincode: item.pincode,
    );
  }

  factory CertificationApplicationModel.fromApplicationJson(Map<String, dynamic> rawJson) {
    // Merge nested 'data' and 'application' maps if present so all fields are accessible
    final Map<String, dynamic> appMap = Map<String, dynamic>.from(rawJson);
    if (rawJson['data'] is Map<String, dynamic>) {
      final dataMap = rawJson['data'] as Map<String, dynamic>;
      appMap.addAll(dataMap);
      if (dataMap['application'] is Map<String, dynamic>) {
        appMap.addAll(dataMap['application'] as Map<String, dynamic>);
      }
    } else if (rawJson['application'] is Map<String, dynamic>) {
      appMap.addAll(rawJson['application'] as Map<String, dynamic>);
    }

    final inst = appMap['institution'] is Map<String, dynamic>
        ? appMap['institution'] as Map<String, dynamic>
        : (appMap['organization'] is Map<String, dynamic> ? appMap['organization'] as Map<String, dynamic> : null);

    final rawDetails = appMap['institution_details'] is Map
        ? Map<String, dynamic>.from(appMap['institution_details'] as Map)
        : (inst != null && inst['details'] is Map ? Map<String, dynamic>.from(inst['details'] as Map) : <String, dynamic>{});

    final Map<int, dynamic> qAnswers = {};
    final rawAnswers = appMap['answers'] ??
        (appMap['application'] is Map ? (appMap['application'] as Map)['answers'] : null) ??
        (appMap['data'] is Map ? (appMap['data'] as Map)['answers'] : null);

    if (rawAnswers is List) {
      for (final a in rawAnswers) {
        if (a is Map) {
          final qId = int.tryParse(a['question_id']?.toString() ?? a['id']?.toString() ?? '');
          if (qId != null) {
            final dynamic val = a['answer_bool'] ??
                a['answer_number'] ??
                a['answer_text'] ??
                a['answer_option_id'] ??
                a['answer'] ??
                a['value'];
            if (val != null) {
              if (val is bool) {
                qAnswers[qId] = val;
              } else if (val is num) {
                qAnswers[qId] = val == 1;
              } else {
                final s = val.toString().trim().toLowerCase();
                if (s == 'true' || s == '1' || s == 'yes') {
                  qAnswers[qId] = true;
                } else if (s == 'false' || s == '0' || s == 'no') {
                  qAnswers[qId] = false;
                } else {
                  qAnswers[qId] = val;
                }
              }
            }
          }
        }
      }
    } else if (rawAnswers is Map) {
      rawAnswers.forEach((key, val) {
        final qId = int.tryParse(key.toString());
        if (qId != null) {
          if (val is bool) {
            qAnswers[qId] = val;
          } else if (val is num) {
            qAnswers[qId] = val == 1;
          } else {
            final s = val.toString().trim().toLowerCase();
            if (s == 'true' || s == '1' || s == 'yes') {
              qAnswers[qId] = true;
            } else if (s == 'false' || s == '0' || s == 'no') {
              qAnswers[qId] = false;
            } else {
              qAnswers[qId] = val;
            }
          }
        }
      });
    }

    final List<EvidenceItem> evItems = [];

    void addOrAttach(String reqId, String title, String? fileUrl, String? fileName, String kind) {
      if ((fileUrl == null || fileUrl.isEmpty) && (fileName == null || fileName.isEmpty)) return;
      final cleanName = (fileName != null && fileName.isNotEmpty)
          ? fileName
          : (fileUrl?.split('/').last ?? 'evidence.jpg');

      final existingIdx = evItems.indexWhere((e) =>
          (reqId.isNotEmpty && (e.requirementId == reqId || e.id == reqId)) ||
          (title.isNotEmpty && e.title.trim().toLowerCase() == title.trim().toLowerCase()));

      if (existingIdx >= 0) {
        final existing = evItems[existingIdx];
        if (!existing.hasAttachmentMatching(fileName: cleanName, fileUrl: fileUrl)) {
          existing.addAttachment(fileName: cleanName, fileUrl: fileUrl);
        }
      } else {
        evItems.add(EvidenceItem(
          id: reqId,
          requirementId: reqId,
          title: title.isNotEmpty ? title : cleanName,
          description: '',
          fileUrl: fileUrl,
          fileName: cleanName,
          evidenceKind: kind,
        ));
      }
    }

    // 1. Evidence by requirement map (e.g. { "1": [ { ... }, { ... } ] })
    final evByReq = appMap['evidence_by_requirement'] ??
        (appMap['application'] is Map ? (appMap['application'] as Map)['evidence_by_requirement'] : null) ??
        (appMap['data'] is Map ? (appMap['data'] as Map)['evidence_by_requirement'] : null);
    if (evByReq is Map) {
      evByReq.forEach((reqKey, filesList) {
        if (filesList is List) {
          for (final ev in filesList) {
            if (ev is Map) {
              final reqId = ev['requirement_id']?.toString() ?? reqKey.toString();
              final title = ev['title']?.toString() ?? '';
              final fileUrl = ev['url']?.toString() ?? (ev['file'] is Map ? ev['file']['url']?.toString() : null);
              final fileName = ev['name']?.toString() ?? (ev['file'] is Map ? ev['file']['name']?.toString() : null);
              final kind = ev['kind']?.toString() ?? 'photo';
              addOrAttach(reqId, title, fileUrl, fileName, kind);
            }
          }
        }
      });
    }

    // 2. Evidence / materials / supporting_material lists
    final rawEvList = <dynamic>[];
    if (appMap['evidence'] is List) rawEvList.addAll(appMap['evidence'] as List);
    if (appMap['materials'] is List) rawEvList.addAll(appMap['materials'] as List);
    if (appMap['supporting_material'] is List) rawEvList.addAll(appMap['supporting_material'] as List);
    if (appMap['application'] is Map) {
      final appNested = appMap['application'] as Map;
      if (appNested['materials'] is List) rawEvList.addAll(appNested['materials'] as List);
      if (appNested['evidence'] is List) rawEvList.addAll(appNested['evidence'] as List);
      if (appNested['supporting_material'] is List) rawEvList.addAll(appNested['supporting_material'] as List);
    }
    if (appMap['data'] is Map) {
      final dataNested = appMap['data'] as Map;
      if (dataNested['materials'] is List) rawEvList.addAll(dataNested['materials'] as List);
      if (dataNested['evidence'] is List) rawEvList.addAll(dataNested['evidence'] as List);
    }

    for (final ev in rawEvList) {
      if (ev is Map) {
        final reqId = ev['requirement_id']?.toString() ?? ev['id']?.toString() ?? '1';
        final title = ev['title']?.toString() ?? '';
        final fileUrl = ev['url']?.toString() ?? (ev['file'] is Map ? ev['file']['url']?.toString() : null);
        final fileName = ev['name']?.toString() ?? (ev['file'] is Map ? ev['file']['name']?.toString() : null);
        final kind = ev['kind']?.toString() ?? 'photo';
        addOrAttach(reqId, title, fileUrl, fileName, kind);
      }
    }

    final catId = int.tryParse(inst?['category_id']?.toString() ?? appMap['category_id']?.toString() ?? '') ?? 1;
    final catName = inst?['category']?.toString() ?? appMap['category']?.toString() ?? 'Workplace / Worksite / Office / Hospital';

    final parsedId = appMap['id'] is int ? appMap['id'] as int : int.tryParse(appMap['id']?.toString() ?? '');

    final model = CertificationApplicationModel(
      id: parsedId,
      applicationId: appMap['application_id']?.toString() ?? appMap['application_no']?.toString(),
      applicationNo: appMap['application_no']?.toString() ?? appMap['application_id']?.toString(),
      categoryId: catId,
      institutionTypeId: catName,
      institutionTypeTitle: catName,
      institutionName: inst?['name']?.toString() ?? appMap['institution_name']?.toString() ?? '',
      address: inst?['address']?.toString() ?? appMap['address']?.toString() ?? '',
      country: inst?['country']?.toString() ?? appMap['country']?.toString() ?? '',
      countryId: inst?['country_id'] is int ? inst!['country_id'] as int : int.tryParse(inst?['country_id']?.toString() ?? appMap['country_id']?.toString() ?? ''),
      regionState: inst?['region']?.toString() ?? appMap['region']?.toString() ?? '',
      regionId: inst?['region_id'] is int ? inst!['region_id'] as int : int.tryParse(inst?['region_id']?.toString() ?? appMap['region_id']?.toString() ?? ''),
      city: inst?['city']?.toString() ?? appMap['city']?.toString() ?? '',
      cityId: inst?['city_id'] is int ? inst!['city_id'] as int : int.tryParse(inst?['city_id']?.toString() ?? appMap['city_id']?.toString() ?? ''),
      pincode: inst?['pincode']?.toString() ??
          inst?['postal_code']?.toString() ??
          inst?['zip_code']?.toString() ??
          appMap['pincode']?.toString() ??
          appMap['postal_code']?.toString() ??
          rawDetails['pincode']?.toString() ??
          rawDetails['postal_code']?.toString() ??
          '',
      contactPerson: inst?['contact_person']?.toString() ?? appMap['contact_person']?.toString() ?? '',
      contactPhone: inst?['contact_phone']?.toString() ?? appMap['contact_phone']?.toString() ?? '',
      contactEmail: inst?['contact_email']?.toString() ?? appMap['contact_email']?.toString() ?? '',
      numberOfRooms: rawDetails['number_of_rooms']?.toString() ?? '',
      distanceFromMainRoad: rawDetails['distance_from_main_road_km']?.toString() ?? '',
      parkingAvailability: rawDetails['parking_availability']?.toString() ?? '',
      detailFieldValues: rawDetails,
      questionAnswers: qAnswers,
      evidenceItems: evItems,
      status: appMap['status']?.toString() ?? 'changes_required',
      reviewStatus: appMap['review_status']?.toString() ?? 'changes_required',
      displayStatus: appMap['display_status']?.toString() ?? 'Changes Required',
      decision: appMap['decision']?.toString() ?? 'Pending',
      decisionText: appMap['decision_text']?.toString(),
      declarationAccepted: true,
    );

    return model;
  }

  void copyFrom(CertificationApplicationModel other) {
    if (other.categoryId != null) categoryId = other.categoryId;
    if (other.categoryConfig != null) categoryConfig = other.categoryConfig;
    if (other.institutionTypeId.isNotEmpty) institutionTypeId = other.institutionTypeId;
    if (other.institutionTypeTitle.isNotEmpty) institutionTypeTitle = other.institutionTypeTitle;
    if (other.categoryMaxScore > 0) categoryMaxScore = other.categoryMaxScore;
    if (other.passScore > 0) passScore = other.passScore;
    if (other.institutionName.isNotEmpty) institutionName = other.institutionName;
    if (other.address.isNotEmpty) address = other.address;
    if (other.country.isNotEmpty) country = other.country;
    if (other.countryId != null) countryId = other.countryId;
    if (other.regionState.isNotEmpty) regionState = other.regionState;
    if (other.regionId != null) regionId = other.regionId;
    if (other.city.isNotEmpty) city = other.city;
    if (other.cityId != null) cityId = other.cityId;
    if (other.pincode.isNotEmpty) pincode = other.pincode;
    if (other.contactPerson.isNotEmpty) contactPerson = other.contactPerson;
    if (other.contactPhone.isNotEmpty) contactPhone = other.contactPhone;
    if (other.contactEmail.isNotEmpty) contactEmail = other.contactEmail;
    if (other.numberOfRooms.isNotEmpty) numberOfRooms = other.numberOfRooms;
    if (other.distanceFromMainRoad.isNotEmpty) distanceFromMainRoad = other.distanceFromMainRoad;
    if (other.parkingAvailability.isNotEmpty) parkingAvailability = other.parkingAvailability;
    if (other.detailFieldValues.isNotEmpty) {
      detailFieldValues = Map<String, dynamic>.from(other.detailFieldValues);
    }
    if (other.questionAnswers.isNotEmpty) {
      questionAnswers = Map<int, dynamic>.from(other.questionAnswers);
    }
    if (other.evidenceItems.isNotEmpty) {
      evidenceItems = List<EvidenceItem>.from(other.evidenceItems);
    }
    declarationAccepted = other.declarationAccepted;
    if (other.id != null) id = other.id;
    if (other.applicationId != null && other.applicationId!.isNotEmpty) applicationId = other.applicationId;
    if (other.applicationNo != null && other.applicationNo!.isNotEmpty) applicationNo = other.applicationNo;
    if (other.submissionDate != null) submissionDate = other.submissionDate;
    if (other.status.isNotEmpty) status = other.status;
    if (other.reviewStatus.isNotEmpty) reviewStatus = other.reviewStatus;
    if (other.displayStatus.isNotEmpty) displayStatus = other.displayStatus;
    if (other.decision.isNotEmpty) decision = other.decision;
    if (other.decisionText != null) decisionText = other.decisionText;
    if (other.timeline != null) timeline = other.timeline;
    if (other.aiValidation != null) aiValidation = other.aiValidation;
    if (other.materials != null) materials = other.materials;
  }

  Map<String, dynamic> toSubmissionJson() {
    final Map<String, dynamic> qaMap = {};
    final answersList = <Map<String, dynamic>>[];

    questionAnswers.forEach((k, v) {
      if (v == null) return;
      qaMap[k.toString()] = v;
      final qId = int.tryParse(k.toString()) ?? 0;

      bool? ansBool;
      num? ansNum;
      String? ansText;
      dynamic ansOptionId;

      if (v is bool) {
        ansBool = v;
      } else if (v is Map) {
        if (v.containsKey('answer_bool')) ansBool = v['answer_bool'] as bool?;
        if (v.containsKey('answer_number')) ansNum = v['answer_number'] as num?;
        if (v.containsKey('answer_option_id')) ansOptionId = v['answer_option_id'];
        if (v.containsKey('answer_text')) ansText = v['answer_text']?.toString();
        if (v.containsKey('option_id')) ansOptionId = v['option_id'];
        if (v.containsKey('id')) ansOptionId = v['id'];
        if (v.containsKey('text')) ansText = v['text']?.toString();
      } else if (v is num) {
        ansNum = v;
      } else {
        final s = v.toString().trim();
        final sLower = s.toLowerCase();
        if (sLower == 'true' || sLower == 'yes') {
          ansBool = true;
        } else if (sLower == 'false' || sLower == 'no') {
          ansBool = false;
        } else if (num.tryParse(s) != null && !s.startsWith('+') && !s.startsWith('0')) {
          ansNum = num.tryParse(s);
        } else {
          ansText = s;
        }
      }

      final item = <String, dynamic>{
        'question_id': qId,
        'answer_bool': ansBool,
        'answer_number': ansNum,
        'answer_text': ansText,
        'answer_option_id': ansOptionId,
      };
      answersList.add(item);
    });

    final validEvidence = <Map<String, dynamic>>[];
    for (final e in evidenceItems) {
      final reqId = int.tryParse(e.id) ?? int.tryParse(e.requirementId ?? '1') ?? 1;
      for (final att in e.attachments) {
        final effectiveUrl = (att.fileUrl != null && att.fileUrl!.isNotEmpty)
            ? att.fileUrl!
            : (att.filePath ?? '');
        final effectiveName = (att.fileName != null && att.fileName!.isNotEmpty)
            ? att.fileName!
            : (effectiveUrl.isNotEmpty ? effectiveUrl.split('/').last : 'evidence_doc');

        if (effectiveUrl.isNotEmpty || effectiveName.isNotEmpty) {
          validEvidence.add(<String, dynamic>{
            'requirement_id': reqId,
            'title': e.title,
            'name': effectiveName,
            'file_name': effectiveName,
            'url': effectiveUrl,
            'file_url': effectiveUrl,
            'kind': e.evidenceKind.isNotEmpty ? e.evidenceKind : 'photo',
            'evidence_kind': e.evidenceKind.isNotEmpty ? e.evidenceKind : 'photo',
            'source': 'upload',
            'latitude': null,
            'longitude': null,
          });
        }
      }
    }

    return {
      if (id != null) 'id': id,
      if (applicationId != null && applicationId!.isNotEmpty) 'application_id': applicationId,
      if (applicationNo != null && applicationNo!.isNotEmpty) 'application_no': applicationNo,
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
      if (pincode.isNotEmpty) ...{
        'pincode': pincode,
        'postal_code': pincode,
        'zip_code': pincode,
      },
      'contact_person': contactPerson,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'detail_fields': Map<String, dynamic>.from(detailFieldValues),
      'question_answers': qaMap,
      'answers': answersList,
      'evidence': validEvidence,
      'materials': validEvidence,
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

    // Extract Institution & Detail info if provided
    final inst = appMap['institution'] is Map<String, dynamic>
        ? appMap['institution'] as Map<String, dynamic>
        : (appMap['organization'] is Map<String, dynamic> ? appMap['organization'] as Map<String, dynamic> : null);
    if (inst != null) {
      if (inst['name'] != null && inst['name'].toString().isNotEmpty) {
        institutionName = inst['name'].toString();
      }
      if (inst['address'] != null && inst['address'].toString().isNotEmpty) {
        address = inst['address'].toString();
      }
      if (inst['country'] != null && inst['country'].toString().isNotEmpty) {
        country = inst['country'].toString();
      }
      if (inst['country_id'] != null) {
        countryId = int.tryParse(inst['country_id'].toString()) ?? countryId;
      }
      if (inst['region'] != null && inst['region'].toString().isNotEmpty) {
        regionState = inst['region'].toString();
      }
      if (inst['region_id'] != null) {
        regionId = int.tryParse(inst['region_id'].toString()) ?? regionId;
      }
      if (inst['city'] != null && inst['city'].toString().isNotEmpty) {
        city = inst['city'].toString();
      }
      if (inst['city_id'] != null) {
        cityId = int.tryParse(inst['city_id'].toString()) ?? cityId;
      }
      if (inst['pincode'] != null && inst['pincode'].toString().isNotEmpty) {
        pincode = inst['pincode'].toString();
      } else if (inst['postal_code'] != null && inst['postal_code'].toString().isNotEmpty) {
        pincode = inst['postal_code'].toString();
      } else if (inst['zip_code'] != null && inst['zip_code'].toString().isNotEmpty) {
        pincode = inst['zip_code'].toString();
      }
      if (inst['contact_person'] != null && inst['contact_person'].toString().isNotEmpty) {
        contactPerson = inst['contact_person'].toString();
      }
      if (inst['contact_phone'] != null && inst['contact_phone'].toString().isNotEmpty) {
        contactPhone = inst['contact_phone'].toString();
      }
      if (inst['contact_email'] != null && inst['contact_email'].toString().isNotEmpty) {
        contactEmail = inst['contact_email'].toString();
      }
      if (inst['details'] is Map) {
        final dMap = Map<String, dynamic>.from(inst['details'] as Map);
        detailFieldValues.addAll(dMap);
        numberOfRooms = dMap['number_of_rooms']?.toString() ?? numberOfRooms;
        distanceFromMainRoad = dMap['distance_from_main_road_km']?.toString() ?? distanceFromMainRoad;
        parkingAvailability = dMap['parking_availability']?.toString() ?? parkingAvailability;
      }
    }

    if (appMap['institution_details'] is Map) {
      final dMap = Map<String, dynamic>.from(appMap['institution_details'] as Map);
      detailFieldValues.addAll(dMap);
      numberOfRooms = dMap['number_of_rooms']?.toString() ?? numberOfRooms;
      distanceFromMainRoad = dMap['distance_from_main_road_km']?.toString() ?? distanceFromMainRoad;
      parkingAvailability = dMap['parking_availability']?.toString() ?? parkingAvailability;
    }

    // Extract questionnaire answers
    if (appMap['answers'] is List) {
      for (final a in appMap['answers']) {
        if (a is Map) {
          final qId = int.tryParse(a['question_id']?.toString() ?? '');
          if (qId != null) {
            final dynamic val = a['answer_bool'] ?? a['answer_number'] ?? a['answer_text'] ?? a['answer_option_id'];
            if (val != null) {
              if (val is bool) {
                questionAnswers[qId] = val;
              } else if (val is num) {
                questionAnswers[qId] = val == 1;
              } else {
                final s = val.toString().trim().toLowerCase();
                if (s == 'true' || s == '1' || s == 'yes') {
                  questionAnswers[qId] = true;
                } else if (s == 'false' || s == '0' || s == 'no') {
                  questionAnswers[qId] = false;
                } else {
                  questionAnswers[qId] = val;
                }
              }
            }
          }
        }
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
    final rawMaterials = appMap['evidence'] ?? appMap['materials'] ?? appMap['supporting_material'];
    if (rawMaterials is List) {
      materials = rawMaterials
          .whereType<Map<String, dynamic>>()
          .map((e) => CertificationMaterialItem.fromJson(e))
          .toList();

      for (final ev in rawMaterials) {
        if (ev is Map) {
          final reqId = ev['requirement_id']?.toString() ?? ev['id']?.toString() ?? '1';
          final title = ev['title']?.toString() ?? '';
          final fileUrl = ev['url']?.toString() ?? (ev['file'] is Map ? ev['file']['url']?.toString() : null);
          final fileName = ev['name']?.toString() ?? (ev['file'] is Map ? ev['file']['name']?.toString() : null);
          final kind = ev['kind']?.toString() ?? 'photo';
          
          final existingIdx = evidenceItems.indexWhere((item) => item.id == reqId || item.requirementId == reqId);
          if (existingIdx >= 0) {
            evidenceItems[existingIdx].fileUrl = fileUrl;
            evidenceItems[existingIdx].fileName = (fileName != null && fileName.isNotEmpty) ? fileName : (fileUrl?.split('/').last);
          } else {
            evidenceItems.add(EvidenceItem(
              id: reqId,
              requirementId: reqId,
              title: title,
              description: '',
              fileUrl: fileUrl,
              fileName: (fileName != null && fileName.isNotEmpty) ? fileName : (fileUrl?.split('/').last),
              evidenceKind: kind,
            ));
          }
        }
      }
    }
  }
}

/// Timeline stage for certification workflow
class CertificationTimelineStage {
  final String stage;
  final String label;
  final String state; // 'completed', 'in_progress', 'pending'
  final String? note;
  final String? comment;
  final String? occurredAt;

  const CertificationTimelineStage({
    required this.stage,
    required this.label,
    required this.state,
    this.note,
    this.comment,
    this.occurredAt,
  });

  factory CertificationTimelineStage.fromJson(Map<String, dynamic> json) {
    final stg = json['stage']?.toString() ?? '';
    var st = json['state']?.toString() ?? 'pending';
    var nt = json['note']?.toString();

    // 6. change ai validation change pending -> rejected
    if (stg.toLowerCase() == 'ai_validation' || stg.toLowerCase() == 'ai_audit') {
      if (st.toLowerCase() == 'pending') {
        st = 'rejected';
        nt = (nt == null || nt.toLowerCase().contains('pending'))
            ? 'AI validation rejected'
            : nt;
      }
    }

    return CertificationTimelineStage(
      stage: stg,
      label: json['label']?.toString() ?? '',
      state: st,
      note: nt,
      comment: json['comment']?.toString() ?? json['comments']?.toString() ?? json['reviewer_comment']?.toString() ?? json['admin_comment']?.toString(),
      occurredAt: json['occurred_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'stage': stage,
    'label': label,
    'state': state,
    if (note != null) 'note': note,
    if (comment != null) 'comment': comment,
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
  final int score;
  final int maxScore;

  const CertificationAiValidationCheck({
    this.check,
    required this.checkType,
    required this.label,
    required this.status,
    this.statusLabel,
    this.details,
    this.score = 25,
    this.maxScore = 25,
  });

  factory CertificationAiValidationCheck.fromJson(Map<String, dynamic> json) {
    final ct = json['check_type']?.toString() ?? json['check']?.toString() ?? '';
    final lbl = json['label']?.toString() ?? _defaultLabelForType(ct);
    final rawStat = json['status']?.toString() ?? 'pending';
    // 6. change ai validation change pending -> rejected
    final stat = rawStat.toLowerCase() == 'pending' ? 'rejected' : rawStat;
    final parsedScore = int.tryParse(json['score']?.toString() ?? '') ?? (stat == 'approved' ? 25 : 0);
    final parsedMax = int.tryParse(json['max_score']?.toString() ?? '') ?? 25;

    return CertificationAiValidationCheck(
      check: json['check']?.toString() ?? ct,
      checkType: ct,
      label: lbl,
      status: stat,
      statusLabel: json['status_label']?.toString() ??
          (stat == 'approved'
              ? 'Approved'
              : 'Rejected'),
      details: json['details']?.toString(),
      score: parsedScore,
      maxScore: parsedMax,
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
  final String pincode;
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
    this.pincode = '',
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
      pincode: json['pincode']?.toString() ??
          json['postal_code']?.toString() ??
          json['zip_code']?.toString() ??
          '',
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
    if (pincode.isNotEmpty) ...{
      'pincode': pincode,
      'postal_code': pincode,
      'zip_code': pincode,
    },
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

  String? get effectiveComment {
    if (reviewerComment != null && reviewerComment!.isNotEmpty) return reviewerComment;
    if (adminComment != null && adminComment!.isNotEmpty) return adminComment;
    if (aiValidationComment != null && aiValidationComment!.isNotEmpty) return aiValidationComment;
    return null;
  }

  CertificationApplicationDetail copyWith({
    int? id,
    String? applicationId,
    String? applicationNo,
    String? applicationType,
    String? status,
    String? reviewStatus,
    String? displayStatus,
    String? decision,
    String? decisionText,
    bool? editable,
    int? currentStep,
    int? totalSteps,
    String? submittedAt,
    String? decisionAt,
    String? reviewerComment,
    String? adminComment,
    String? aiValidationComment,
    CertificationInstitution? institution,
    CertificationSubmissionDetails? submissionDetails,
    List<CertificationTimelineStage>? timeline,
    List<CertificationAiValidationCheck>? aiValidation,
    List<CertificationMaterialItem>? materials,
  }) {
    return CertificationApplicationDetail(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      applicationNo: applicationNo ?? this.applicationNo,
      applicationType: applicationType ?? this.applicationType,
      status: status ?? this.status,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      displayStatus: displayStatus ?? this.displayStatus,
      decision: decision ?? this.decision,
      decisionText: decisionText ?? this.decisionText,
      editable: editable ?? this.editable,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      submittedAt: submittedAt ?? this.submittedAt,
      decisionAt: decisionAt ?? this.decisionAt,
      reviewerComment: reviewerComment ?? this.reviewerComment,
      adminComment: adminComment ?? this.adminComment,
      aiValidationComment: aiValidationComment ?? this.aiValidationComment,
      institution: institution ?? this.institution,
      submissionDetails: submissionDetails ?? this.submissionDetails,
      timeline: timeline ?? this.timeline,
      aiValidation: aiValidation ?? this.aiValidation,
      materials: materials ?? this.materials,
    );
  }

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

    String? foundComment = json['reviewer_comment']?.toString() ??
        json['changes_required_reason']?.toString() ??
        json['comment']?.toString() ??
        json['comments']?.toString() ??
        json['reason']?.toString() ??
        json['admin_comment']?.toString() ??
        json['notes']?.toString();

    if (foundComment == null && json['reviews'] is List && (json['reviews'] as List).isNotEmpty) {
      final lastReview = (json['reviews'] as List).last;
      if (lastReview is Map) {
        foundComment = lastReview['comment']?.toString() ??
            lastReview['comments']?.toString() ??
            lastReview['notes']?.toString() ??
            lastReview['reviewer_comment']?.toString();
      }
    } else if (foundComment == null && json['review'] is Map) {
      final r = json['review'] as Map;
      foundComment = r['comment']?.toString() ??
          r['comments']?.toString() ??
          r['notes']?.toString() ??
          r['reviewer_comment']?.toString();
    }

    if (foundComment == null) {
      for (final s in stages) {
        if (s.comment != null && s.comment!.isNotEmpty) {
          foundComment = s.comment;
          break;
        }
      }
    }

    final rawStatus = json['status']?.toString() ?? 'Submitted';
    final rawReviewStatus = json['review_status']?.toString() ?? 'ai_audit';
    final rawDecision = json['decision']?.toString() ?? 'Pending';

    final bool hasFailedAi = checks.any((c) {
      final s = c.status.toLowerCase();
      return s == 'rejected' || s == 'failed';
    }) ||
    (foundComment?.toLowerCase().contains('ai validation rejected') ?? false) ||
    (json['ai_validation_comment']?.toString().toLowerCase().contains('rejected') ?? false) ||
    rawStatus.toLowerCase().contains('reject') ||
    rawReviewStatus.toLowerCase().contains('reject') ||
    rawDecision.toLowerCase().contains('reject');

    final effectiveStatus = (hasFailedAi && rawStatus.toLowerCase() != 'approved') ? 'Rejected' : rawStatus;
    final effectiveReviewStatus = (hasFailedAi && rawStatus.toLowerCase() != 'approved') ? 'rejected' : rawReviewStatus;
    final effectiveDisplayStatus = (hasFailedAi && rawStatus.toLowerCase() != 'approved')
        ? 'Rejected'
        : (json['display_status']?.toString() ?? rawStatus);
    final effectiveDecision = (hasFailedAi && rawStatus.toLowerCase() != 'approved') ? 'Rejected' : rawDecision;

    return CertificationApplicationDetail(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      applicationId: json['application_id']?.toString() ?? '',
      applicationNo: json['application_no']?.toString() ?? json['application_id']?.toString() ?? '',
      applicationType: json['application_type']?.toString() ?? 'new',
      status: effectiveStatus,
      reviewStatus: effectiveReviewStatus,
      displayStatus: effectiveDisplayStatus,
      decision: effectiveDecision,
      decisionText: json['decision_text']?.toString() ?? (hasFailedAi ? 'Rejected' : 'Pending'),
      editable: json['editable'] == true,
      currentStep: json['current_step'] is int ? json['current_step'] as int : 4,
      totalSteps: json['total_steps'] is int ? json['total_steps'] as int : 4,
      submittedAt: json['submitted_at']?.toString(),
      decisionAt: json['decision_at']?.toString(),
      reviewerComment: foundComment,
      adminComment: foundComment,
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

