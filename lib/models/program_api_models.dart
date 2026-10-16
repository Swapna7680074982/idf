class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    this.hasNext = false,
    this.hasPrev = false,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] is int ? json['page'] as int : int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: json['limit'] is int ? json['limit'] as int : int.tryParse(json['limit']?.toString() ?? '20') ?? 20,
      total: json['total'] is int ? json['total'] as int : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: json['total_pages'] is int
          ? json['total_pages'] as int
          : int.tryParse(json['total_pages']?.toString() ?? '1') ?? 1,
      hasNext: json['has_next'] == true,
      hasPrev: json['has_prev'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'total_pages': totalPages,
    'has_next': hasNext,
    'has_prev': hasPrev,
  };
}

class ProgramApiItem {
  final int id;
  final String? programNo;
  final String title;
  final String? programName;
  final String programType;
  final int? programTypeId;
  final String organizerName;
  final String? coverImageUrl;
  final String? bannerImageUrl;
  final String? banner;
  final String? cityText;
  final String? countryText;
  final String? startDate;
  final String? endDate;
  final String eventStatus;
  final bool isRegistered;
  final String? registeredAt;
  final String? registrationLink;
  final String? reviewStatus;
  final String? status;
  final bool isOrganizer;

  const ProgramApiItem({
    required this.id,
    this.programNo,
    required this.title,
    this.programName,
    required this.programType,
    this.programTypeId,
    required this.organizerName,
    this.coverImageUrl,
    this.bannerImageUrl,
    this.banner,
    this.cityText,
    this.countryText,
    this.startDate,
    this.endDate,
    required this.eventStatus,
    this.isRegistered = false,
    this.registeredAt,
    this.registrationLink,
    this.reviewStatus,
    this.status,
    this.isOrganizer = false,
  });

  factory ProgramApiItem.fromJson(Map<String, dynamic> json) {
    final effectiveCover = json['cover_image_url'] ?? json['banner_image_url'] ?? json['banner'];
    final effectiveBanner = json['banner_image_url'] ?? json['banner'] ?? json['cover_image_url'];
    final statusStr = (json['review_status'] ?? json['status'])?.toString().toLowerCase() ?? '';
    final isSubmittedOrDraft = statusStr == 'submitted' || statusStr == 'draft' || statusStr == 'in_review';
    final isOrg = json['is_organizer'] == 1 ||
        json['is_organizer'] == true ||
        json['is_organizer'] == '1' ||
        isSubmittedOrDraft;

    final rawIsRegistered = json['is_registered'] == true ||
        json['is_registered'] == 1 ||
        json['is_registered'] == '1' ||
        json['registered_at'] != null;

    return ProgramApiItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      programNo: json['program_no']?.toString(),
      title: (json['title'] ?? json['program_name'])?.toString() ?? '',
      programName: json['program_name']?.toString(),
      programType: json['program_type']?.toString() ?? '',
      programTypeId: json['program_type_id'] is int
          ? json['program_type_id'] as int
          : int.tryParse(json['program_type_id']?.toString() ?? ''),
      organizerName: (json['organizer_name'] ?? json['organization_entity_name'])?.toString() ??
          (isOrg ? 'You (Organizer)' : 'IDF Active'),
      coverImageUrl: effectiveCover?.toString(),
      bannerImageUrl: effectiveBanner?.toString(),
      banner: json['banner']?.toString(),
      cityText: (json['city_text'] ?? json['city'])?.toString(),
      countryText: (json['country_text'] ?? json['country'])?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      eventStatus: json['event_status']?.toString() ?? 'upcoming',
      isRegistered: rawIsRegistered && !isOrg,
      registeredAt: json['registered_at']?.toString(),
      registrationLink: json['registration_link']?.toString(),
      reviewStatus: (json['review_status'] ?? json['status'])?.toString(),
      status: json['status']?.toString(),
      isOrganizer: isOrg,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (programNo != null) 'program_no': programNo,
    'title': title,
    if (programName != null) 'program_name': programName,
    'program_type': programType,
    if (programTypeId != null) 'program_type_id': programTypeId,
    'banner_image_url': bannerImageUrl,
    'cover_image_url': coverImageUrl,
    'banner': banner,
    'city_text': cityText,
    'country_text': countryText,
    'start_date': startDate,
    'end_date': endDate,
    'event_status': eventStatus,
    'registered_at': registeredAt,
    'review_status': reviewStatus,
    'status': status,
    'is_organizer': isOrganizer ? 1 : 0,
    'is_registered': isRegistered,
  };
}

class ProgramRegistrationResult {
  final int programId;
  final String programName;
  final String programType;
  final String? date;
  final String? location;
  final String status;

  const ProgramRegistrationResult({
    required this.programId,
    required this.programName,
    required this.programType,
    this.date,
    this.location,
    required this.status,
  });

  factory ProgramRegistrationResult.fromJson(Map<String, dynamic> json) {
    return ProgramRegistrationResult(
      programId: json['program_id'] is int
          ? json['program_id'] as int
          : int.tryParse(json['program_id']?.toString() ?? '0') ?? 0,
      programName: json['program_name']?.toString() ?? '',
      programType: json['program_type']?.toString() ?? '',
      date: json['date']?.toString(),
      location: json['location']?.toString(),
      status: json['registration_status']?.toString() ?? 'confirmed',
    );
  }
}

class ProgramsResponse {
  final bool success;
  final String message;
  final List<ProgramApiItem> items;
  final PaginationInfo pagination;

  const ProgramsResponse({
    this.success = true,
    this.message = 'OK',
    required this.items,
    required this.pagination,
  });

  factory ProgramsResponse.fromJson(Map<String, dynamic> json) {
    final effectiveMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final list = effectiveMap['items'] is List ? effectiveMap['items'] as List : [];
    final pag = effectiveMap['pagination'] is Map<String, dynamic>
        ? PaginationInfo.fromJson(effectiveMap['pagination'] as Map<String, dynamic>)
        : const PaginationInfo(page: 1, limit: 20, total: 0, totalPages: 1);

    return ProgramsResponse(
      success: json['success'] != false,
      message: (json['message'] ?? 'OK').toString(),
      items: list
          .whereType<Map<String, dynamic>>()
          .map((item) => ProgramApiItem.fromJson(item))
          .toList(),
      pagination: pag,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': {
      'items': items.map((i) => i.toJson()).toList(),
      'pagination': pagination.toJson(),
    },
  };
}

/// Agenda Schedule item for POST /api/programs
class ProgramAgendaScheduleItem {
  final String startTime;
  final String title;

  const ProgramAgendaScheduleItem({
    required this.startTime,
    required this.title,
  });

  factory ProgramAgendaScheduleItem.fromJson(Map<String, dynamic> json) {
    return ProgramAgendaScheduleItem(
      startTime: (json['start_time'] ?? json['time'] ?? '09:00').toString(),
      title: (json['title'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'title': title,
  };
}

/// Material item for POST /api/programs
class ProgramMaterialDoc {
  final String name;
  final String url;
  final String mimeType;

  const ProgramMaterialDoc({
    required this.name,
    required this.url,
    required this.mimeType,
  });

  factory ProgramMaterialDoc.fromJson(Map<String, dynamic> json) {
    return ProgramMaterialDoc(
      name: (json['name'] ?? json['file_name'] ?? '').toString(),
      url: (json['url'] ?? json['file_url'] ?? '').toString(),
      mimeType: (json['mime_type'] ?? 'application/pdf').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'mime_type': mimeType,
  };
}

/// Created Program Object inside POST /api/programs response
class ProgramProposalCreated {
  final int id;
  final String programNo;
  final String title;
  final String programName;
  final String? bannerImageUrl;
  final String? coverImageUrl;
  final String? banner;
  final List<ProgramAgendaScheduleItem> agenda;
  final List<ProgramMaterialDoc> materials;
  final String reviewStatus;
  final String status;

  const ProgramProposalCreated({
    required this.id,
    required this.programNo,
    required this.title,
    required this.programName,
    this.bannerImageUrl,
    this.coverImageUrl,
    this.banner,
    this.agenda = const [],
    this.materials = const [],
    required this.reviewStatus,
    required this.status,
  });

  factory ProgramProposalCreated.fromJson(Map<String, dynamic> json) {
    final agendaList = json['agenda'] is List
        ? json['agenda'] as List
        : (json['program_agenda_schedule'] is List ? json['program_agenda_schedule'] as List : []);
    final materialsList = json['materials'] is List ? json['materials'] as List : [];

    return ProgramProposalCreated(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      programNo: json['program_no']?.toString() ?? '',
      title: (json['title'] ?? json['program_name'] ?? '').toString(),
      programName: (json['program_name'] ?? json['title'] ?? '').toString(),
      bannerImageUrl: json['banner_image_url']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      banner: json['banner']?.toString(),
      agenda: agendaList
          .whereType<Map<String, dynamic>>()
          .map((a) => ProgramAgendaScheduleItem.fromJson(a))
          .toList(),
      materials: materialsList
          .whereType<Map<String, dynamic>>()
          .map((m) => ProgramMaterialDoc.fromJson(m))
          .toList(),
      reviewStatus: (json['review_status'] ?? json['status'] ?? 'submitted').toString(),
      status: (json['status'] ?? json['review_status'] ?? 'submitted').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'program_no': programNo,
    'title': title,
    'program_name': programName,
    if (bannerImageUrl != null) 'banner_image_url': bannerImageUrl,
    if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
    if (banner != null) 'banner': banner,
    'agenda': agenda.map((a) => a.toJson()).toList(),
    'materials': materials.map((m) => m.toJson()).toList(),
    'review_status': reviewStatus,
    'status': status,
  };
}

/// Full Response model for POST /api/programs
class ProgramSubmissionResponse {
  final bool success;
  final String message;
  final ProgramProposalCreated? program;
  final Map<String, dynamic> rawData;

  const ProgramSubmissionResponse({
    required this.success,
    required this.message,
    this.program,
    this.rawData = const {},
  });

  factory ProgramSubmissionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (json.containsKey('program') ? json : <String, dynamic>{});

    final programMap = data['program'] is Map<String, dynamic>
        ? data['program'] as Map<String, dynamic>
        : (data.containsKey('id') ? data : null);

    return ProgramSubmissionResponse(
      success: json['success'] != false,
      message: (json['message'] ?? 'Program submitted for review').toString(),
      program: programMap != null ? ProgramProposalCreated.fromJson(programMap) : null,
      rawData: json,
    );
  }

  /// Bracket operator support for transparent `Map<String, dynamic>` compatibility
  dynamic operator [](String key) {
    if (key == 'data') {
      return rawData['data'] ?? {
        if (program != null) 'program': program!.toJson(),
      };
    }
    if (key == 'program') {
      return program?.toJson() ?? rawData['program'];
    }
    if (key == 'success') return success;
    if (key == 'message') return message;
    return rawData[key];
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': {
      if (program != null) 'program': program!.toJson(),
    },
  };
}

/// Request model for POST /api/programs matching exact schema
class ProgramCreateRequest {
  final String programName;
  final int programTypeId;
  final String banner;
  final String description;
  final String organizationEntityName;
  final String organizationType;
  final String contactPerson;
  final String phone;
  final String email;
  final String startDate;
  final String endDate;
  final String country;
  final String region;
  final String city;
  final String venue;
  final List<Map<String, dynamic>> programAgendaSchedule;
  final List<Map<String, dynamic>> materials;
  final String? registrationLink;
  final String? registrationInstructions;
  final String status;

  const ProgramCreateRequest({
    required this.programName,
    required this.programTypeId,
    required this.banner,
    required this.description,
    required this.organizationEntityName,
    this.organizationType = 'NGO / Non-Profit',
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.startDate,
    required this.endDate,
    required this.country,
    this.region = 'Telangana',
    required this.city,
    required this.venue,
    this.programAgendaSchedule = const [],
    this.materials = const [],
    this.registrationLink,
    this.registrationInstructions,
    this.status = 'submitted',
  });

  Map<String, dynamic> toJson() => {
    'program_name': programName,
    'program_type_id': programTypeId,
    'banner': banner,
    'description': description,
    'organization_entity_name': organizationEntityName,
    'organization_type': organizationType,
    'contact_person': contactPerson,
    'phone': phone,
    'email': email,
    'start_date': startDate,
    'end_date': endDate,
    'country': country,
    'region': region,
    'city': city,
    'venue': venue,
    'program_agenda_schedule': programAgendaSchedule,
    'materials': materials,
    'registration_link': registrationLink ?? '',
    'registration_instructions': registrationInstructions ?? '',
    'status': status,
  };
}
