import '../services/api_config.dart';

class HomeRegisteredProgram {
  final int id;
  final String? programNo;
  final String title;
  final String? programName;
  final String programType;
  final String? coverImageUrl;
  final String? bannerImageUrl;
  final String? banner;
  final String? cityText;
  final String? countryText;
  final String? startDate;
  final String? endDate;
  final String eventStatus;
  final bool isRegistered;
  final String? organizerName;
  final String? registrationLink;
  final String? reviewStatus;
  final String? status;
  final bool isOrganizer;

  const HomeRegisteredProgram({
    required this.id,
    this.programNo,
    required this.title,
    this.programName,
    required this.programType,
    this.coverImageUrl,
    this.bannerImageUrl,
    this.banner,
    this.cityText,
    this.countryText,
    this.startDate,
    this.endDate,
    required this.eventStatus,
    this.isRegistered = true,
    this.organizerName,
    this.registrationLink,
    this.reviewStatus,
    this.status,
    this.isOrganizer = false,
  });

  factory HomeRegisteredProgram.fromJson(Map<String, dynamic> json) {
    final effectiveCover = ApiConfig.extractBannerUrl(json);
    final effectiveBanner = effectiveCover;
    final statusStr = (json['review_status'] ?? json['status'])?.toString().toLowerCase() ?? '';
    final isSubmittedOrDraft = statusStr == 'submitted' || statusStr == 'draft' || statusStr == 'in_review';
    final isOrg = json['is_organizer'] == 1 ||
        json['is_organizer'] == true ||
        json['is_organizer'] == '1' ||
        json['is_creator'] == 1 ||
        json['is_creator'] == true ||
        json['role'] == 'organizer' ||
        (json['organizer_name']?.toString().toLowerCase().contains('you') ?? false) ||
        isSubmittedOrDraft;

    final rawIsRegistered = json['is_registered'] == true ||
        json['is_registered'] == 1 ||
        json['is_registered'] == '1' ||
        json['registered_at'] != null;

    return HomeRegisteredProgram(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      programNo: json['program_no']?.toString(),
      title: (json['title'] ?? json['program_name'])?.toString() ?? '',
      programName: json['program_name']?.toString(),
      programType: json['program_type']?.toString() ?? '',
      coverImageUrl: effectiveCover?.toString(),
      bannerImageUrl: effectiveBanner?.toString(),
      banner: json['banner']?.toString(),
      cityText: (json['city_text'] ?? json['city'])?.toString(),
      countryText: (json['country_text'] ?? json['country'])?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      eventStatus: json['event_status']?.toString() ?? 'upcoming',
      isRegistered: rawIsRegistered && !isOrg,
      organizerName: (json['organizer_name'] ?? json['organization_entity_name'])?.toString(),
      registrationLink: json['registration_link']?.toString(),
      reviewStatus: (json['review_status'] ?? json['status'])?.toString(),
      status: json['status']?.toString(),
      isOrganizer: isOrg,
    );
  }
}

class HomeCertificationSummary {
  final int? applicationId;
  final String? applicationNo;
  final String? institutionName;
  final String? category;
  final String? displayStatus;
  final String? certificateId;
  final String? expiresOn;
  final String? issuedOn;
  final String? status;
  final String? reviewStatus;
  final Map<String, dynamic>? rawJson;

  const HomeCertificationSummary({
    this.applicationId,
    this.applicationNo,
    this.institutionName,
    this.category,
    this.displayStatus,
    this.certificateId,
    this.expiresOn,
    this.issuedOn,
    this.status,
    this.reviewStatus,
    this.rawJson,
  });

  factory HomeCertificationSummary.fromJson(Map<String, dynamic> json) {
    final rawCertId = json['certificate_no'] ??
        json['certificate_code'] ??
        json['certificate_number'] ??
        json['certificate_id'];
    final certIdStr = (rawCertId != null && rawCertId.toString() != 'null')
        ? rawCertId.toString().trim()
        : null;

    final appNoStr = (json['application_no'] ??
        json['application_id'] ??
        json['id'])?.toString().trim();

    return HomeCertificationSummary(
      applicationId: json['application_id'] is int
          ? json['application_id'] as int
          : int.tryParse(json['application_id']?.toString() ?? ''),
      applicationNo: appNoStr,
      institutionName: json['institution_name']?.toString(),
      category: (json['category'] ?? json['institution_type'])?.toString(),
      displayStatus: (json['display_status'] ?? json['displayStatus'])?.toString(),
      certificateId: certIdStr,
      expiresOn: (json['expires_on'] ?? json['expires_date'])?.toString(),
      issuedOn: (json['issued_on'] ?? json['issued_date'] ?? json['applied_at'])?.toString(),
      status: json['status']?.toString(),
      reviewStatus: (json['review_status'] ?? json['reviewStatus'])?.toString(),
      rawJson: json,
    );
  }
}

class IdfActivateCard {
  final String tag;
  final String badge;
  final String title;
  final String description;
  final String subtitle;
  final String buttonText;
  final String actionText;
  final String actionUrl;

  const IdfActivateCard({
    this.tag = '',
    this.badge = '',
    this.title = '',
    this.description = '',
    this.subtitle = '',
    this.buttonText = 'Learn More',
    this.actionText = 'Learn More',
    this.actionUrl = '',
  });

  factory IdfActivateCard.fromJson(Map<String, dynamic> json) {
    return IdfActivateCard(
      tag: (json['tag'] ?? json['badge'] ?? '').toString(),
      badge: (json['badge'] ?? json['tag'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? json['subtitle'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['description'] ?? '').toString(),
      buttonText: (json['button_text'] ?? json['action_text'] ?? 'Learn More').toString(),
      actionText: (json['action_text'] ?? json['button_text'] ?? 'Learn More').toString(),
      actionUrl: (json['action_url'] ?? '').toString(),
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
  final IdfActivateCard? idfActivateCard;

  const HomeSummaryResponse({
    required this.userFullName,
    required this.unreadNotifications,
    required this.programApplicationsCount,
    required this.certificationApplicationsCount,
    required this.registeredPrograms,
    this.certification,
    this.idfActivateCard,
  });

  factory HomeSummaryResponse.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null;
    final appsObj = json['applications'] is Map<String, dynamic> ? json['applications'] as Map<String, dynamic> : null;
    final progList = json['registered_programs'] is List ? json['registered_programs'] as List : [];
    final certObj = json['certification'] is Map<String, dynamic> ? json['certification'] as Map<String, dynamic> : null;
    final cardObj = json['idf_activate_card'] is Map<String, dynamic> ? json['idf_activate_card'] as Map<String, dynamic> : null;

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
      idfActivateCard: cardObj != null ? IdfActivateCard.fromJson(cardObj) : null,
    );
  }
}
