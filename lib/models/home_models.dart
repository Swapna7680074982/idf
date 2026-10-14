class HomeRegisteredProgram {
  final int id;
  final String title;
  final String programType;
  final String? coverImageUrl;
  final String? cityText;
  final String? countryText;
  final String? startDate;
  final String eventStatus;
  final bool isRegistered;

  const HomeRegisteredProgram({
    required this.id,
    required this.title,
    required this.programType,
    this.coverImageUrl,
    this.cityText,
    this.countryText,
    this.startDate,
    required this.eventStatus,
    this.isRegistered = true,
  });

  factory HomeRegisteredProgram.fromJson(Map<String, dynamic> json) {
    return HomeRegisteredProgram(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      programType: json['program_type']?.toString() ?? '',
      coverImageUrl: json['cover_image_url']?.toString(),
      cityText: json['city_text']?.toString(),
      countryText: json['country_text']?.toString(),
      startDate: json['start_date']?.toString(),
      eventStatus: json['event_status']?.toString() ?? '',
      isRegistered: json['is_registered'] == true,
    );
  }
}

class HomeCertificationSummary {
  final int? applicationId;
  final String? applicationNo;
  final String? institutionName;
  final String? category;
  final String? displayStatus;
  final int? certificateId;
  final String? expiresOn;

  const HomeCertificationSummary({
    this.applicationId,
    this.applicationNo,
    this.institutionName,
    this.category,
    this.displayStatus,
    this.certificateId,
    this.expiresOn,
  });

  factory HomeCertificationSummary.fromJson(Map<String, dynamic> json) {
    return HomeCertificationSummary(
      applicationId: json['application_id'] is int
          ? json['application_id'] as int
          : int.tryParse(json['application_id']?.toString() ?? ''),
      applicationNo: json['application_no']?.toString(),
      institutionName: json['institution_name']?.toString(),
      category: json['category']?.toString(),
      displayStatus: json['display_status']?.toString(),
      certificateId: json['certificate_id'] is int
          ? json['certificate_id'] as int
          : int.tryParse(json['certificate_id']?.toString() ?? ''),
      expiresOn: json['expires_on']?.toString(),
    );
  }
}

class HomeSummaryResponse {
  final String userFullName;
  final int unreadNotifications;
  final int programApplicationsCount;
  final int certificationApplicationsCount;
  final List<HomeRegisteredProgram> registeredPrograms;
  final HomeCertificationSummary? certification;

  const HomeSummaryResponse({
    required this.userFullName,
    required this.unreadNotifications,
    required this.programApplicationsCount,
    required this.certificationApplicationsCount,
    required this.registeredPrograms,
    this.certification,
  });

  factory HomeSummaryResponse.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null;
    final appsObj = json['applications'] is Map<String, dynamic> ? json['applications'] as Map<String, dynamic> : null;
    final progList = json['registered_programs'] is List ? json['registered_programs'] as List : [];
    final certObj = json['certification'] is Map<String, dynamic> ? json['certification'] as Map<String, dynamic> : null;

    return HomeSummaryResponse(
      userFullName: userObj?['full_name']?.toString() ?? '',
      unreadNotifications: json['unread_notifications'] is int
          ? json['unread_notifications'] as int
          : int.tryParse(json['unread_notifications']?.toString() ?? '0') ?? 0,
      programApplicationsCount: (appsObj != null && appsObj['program_applications'] is int)
          ? appsObj['program_applications'] as int
          : int.tryParse(appsObj?['program_applications']?.toString() ?? '0') ?? 0,
      certificationApplicationsCount: (appsObj != null && appsObj['certification_applications'] is int)
          ? appsObj['certification_applications'] as int
          : int.tryParse(appsObj?['certification_applications']?.toString() ?? '0') ?? 0,
      registeredPrograms: progList
          .whereType<Map<String, dynamic>>()
          .map((item) => HomeRegisteredProgram.fromJson(item))
          .toList(),
      certification: certObj != null ? HomeCertificationSummary.fromJson(certObj) : null,
    );
  }
}
