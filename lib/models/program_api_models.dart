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
}

class ProgramApiItem {
  final int id;
  final String title;
  final String programType;
  final int? programTypeId;
  final String organizerName;
  final String? coverImageUrl;
  final String? cityText;
  final String? countryText;
  final String? startDate;
  final String? endDate;
  final String eventStatus;
  final bool isRegistered;
  final String? registeredAt;

  const ProgramApiItem({
    required this.id,
    required this.title,
    required this.programType,
    this.programTypeId,
    required this.organizerName,
    this.coverImageUrl,
    this.cityText,
    this.countryText,
    this.startDate,
    this.endDate,
    required this.eventStatus,
    this.isRegistered = false,
    this.registeredAt,
  });

  factory ProgramApiItem.fromJson(Map<String, dynamic> json) {
    return ProgramApiItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      programType: json['program_type']?.toString() ?? '',
      programTypeId: json['program_type_id'] is int
          ? json['program_type_id'] as int
          : int.tryParse(json['program_type_id']?.toString() ?? ''),
      organizerName: json['organizer_name']?.toString() ?? 'IDF Active',
      coverImageUrl: json['cover_image_url']?.toString(),
      cityText: json['city_text']?.toString(),
      countryText: json['country_text']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      eventStatus: json['event_status']?.toString() ?? 'upcoming',
      isRegistered: json['is_registered'] == true || json['registered_at'] != null,
      registeredAt: json['registered_at']?.toString(),
    );
  }
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
  final List<ProgramApiItem> items;
  final PaginationInfo pagination;

  const ProgramsResponse({
    required this.items,
    required this.pagination,
  });

  factory ProgramsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['items'] is List ? json['items'] as List : [];
    final pag = json['pagination'] is Map<String, dynamic>
        ? PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>)
        : const PaginationInfo(page: 1, limit: 20, total: 0, totalPages: 1);

    return ProgramsResponse(
      items: list
          .whereType<Map<String, dynamic>>()
          .map((item) => ProgramApiItem.fromJson(item))
          .toList(),
      pagination: pag,
    );
  }
}
