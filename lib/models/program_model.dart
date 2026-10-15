import '../services/api_config.dart';
import 'home_models.dart';
import 'program_api_models.dart';

enum ProgramStatus {
  upcoming,
  ongoing,
  completed,
  cancelled;

  static ProgramStatus parse(String? statusStr, {String? startDate, String? endDate}) {
    final s = statusStr?.trim().toLowerCase();
    if (s == 'cancelled' || s == 'canceled') {
      return ProgramStatus.cancelled;
    }

    // Trigger condition based on date comparison:
    // Today < start_date -> upcoming
    // start_date <= Today <= end_date -> ongoing
    // Today > end_date -> completed
    try {
      if (startDate != null && startDate.trim().isNotEmpty) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final startDt = DateTime.tryParse(startDate.trim());
        final endDt = endDate != null && endDate.trim().isNotEmpty
            ? DateTime.tryParse(endDate.trim())
            : startDt;

        if (startDt != null) {
          final startOnly = DateTime(startDt.year, startDt.month, startDt.day);
          final endOnly = endDt != null
              ? DateTime(endDt.year, endDt.month, endDt.day)
              : startOnly;

          if (today.isBefore(startOnly)) {
            return ProgramStatus.upcoming;
          } else if (today.isAfter(endOnly)) {
            return ProgramStatus.completed;
          } else {
            return ProgramStatus.ongoing;
          }
        }
      }
    } catch (_) {}

    // Fallback based on backend event_status string:
    if (s == 'ongoing') return ProgramStatus.ongoing;
    if (s == 'completed') return ProgramStatus.completed;
    return ProgramStatus.upcoming;
  }
}

enum ProgramType {
  activityDrive,
  campaign,
  conference,
  workshop,
  seminar,
  communityWalk,
  marathon,
}

class ProgramAgendaItem {
  final String time;
  final String title;
  final String? description;

  const ProgramAgendaItem({
    required this.time,
    required this.title,
    this.description,
  });
}

class ProgramContactInfo {
  final String contactPerson;
  final String phone;
  final String email;

  const ProgramContactInfo({
    required this.contactPerson,
    required this.phone,
    required this.email,
  });
}

class ProgramMaterialItem {
  final String name;
  final String url;
  final String mimeType;

  const ProgramMaterialItem({
    required this.name,
    required this.url,
    required this.mimeType,
  });

  factory ProgramMaterialItem.fromJson(Map<String, dynamic> json) {
    return ProgramMaterialItem(
      name: (json['name'] ?? json['file_name'] ?? 'Supporting Document').toString(),
      url: (json['url'] ?? json['file_url'] ?? '').toString(),
      mimeType: (json['mime_type'] ?? 'application/pdf').toString(),
    );
  }
}

class ProgramModel {
  final String id;
  final String? programNo;
  final String title;
  final String tag;
  final ProgramType type;
  final ProgramStatus status;
  final String organizer;
  final String organizationType;
  final String venue;
  final String location;
  final String country;
  final String city;
  final String startDate;
  final String endDate;
  final String description;
  final List<ProgramAgendaItem> agenda;
  final List<ProgramMaterialItem> materials;
  final ProgramContactInfo contactInfo;
  final bool isRegistered;
  final bool canRegister;
  final List<int> gradientColors;
  final String? imageUrl;
  final String? category;
  final String? registrationLink;
  final String? registrationInstructions;
  final int participantsCount;
  final String targetAudience;
  final String? reviewStatus;
  final bool isOrganizer;

  const ProgramModel({
    required this.id,
    this.programNo,
    required this.title,
    required this.tag,
    required this.type,
    required this.status,
    required this.organizer,
    required this.organizationType,
    required this.venue,
    required this.location,
    required this.country,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.agenda,
    this.materials = const [],
    required this.contactInfo,
    this.isRegistered = false,
    this.canRegister = true,
    required this.gradientColors,
    this.imageUrl,
    this.category,
    this.registrationLink,
    this.registrationInstructions,
    this.participantsCount = 1200,
    this.targetAudience = 'General Public & Youth',
    this.reviewStatus,
    this.isOrganizer = false,
  });

  ProgramModel copyWith({
    String? id,
    String? programNo,
    String? title,
    String? tag,
    ProgramType? type,
    ProgramStatus? status,
    String? organizer,
    String? organizationType,
    String? venue,
    String? location,
    String? country,
    String? city,
    String? startDate,
    String? endDate,
    String? description,
    List<ProgramAgendaItem>? agenda,
    List<ProgramMaterialItem>? materials,
    ProgramContactInfo? contactInfo,
    bool? isRegistered,
    bool? canRegister,
    List<int>? gradientColors,
    String? imageUrl,
    String? category,
    String? registrationLink,
    String? registrationInstructions,
    int? participantsCount,
    String? targetAudience,
    String? reviewStatus,
    bool? isOrganizer,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      programNo: programNo ?? this.programNo,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      type: type ?? this.type,
      status: status ?? this.status,
      organizer: organizer ?? this.organizer,
      organizationType: organizationType ?? this.organizationType,
      venue: venue ?? this.venue,
      location: location ?? this.location,
      country: country ?? this.country,
      city: city ?? this.city,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      agenda: agenda ?? this.agenda,
      materials: materials ?? this.materials,
      contactInfo: contactInfo ?? this.contactInfo,
      isRegistered: isRegistered ?? this.isRegistered,
      canRegister: canRegister ?? this.canRegister,
      gradientColors: gradientColors ?? this.gradientColors,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      registrationLink: registrationLink ?? this.registrationLink,
      registrationInstructions: registrationInstructions ?? this.registrationInstructions,
      participantsCount: participantsCount ?? this.participantsCount,
      targetAudience: targetAudience ?? this.targetAudience,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      isOrganizer: isOrganizer ?? this.isOrganizer,
    );
  }

  factory ProgramModel.fromDetailJson(Map<String, dynamic> json) {
    final eventDetails = json['event_details'] is Map<String, dynamic>
        ? json['event_details'] as Map<String, dynamic>
        : <String, dynamic>{};
    final contact = json['contact'] is Map<String, dynamic>
        ? json['contact'] as Map<String, dynamic>
        : <String, dynamic>{};
    final registration = json['registration'] is Map<String, dynamic>
        ? json['registration'] as Map<String, dynamic>
        : <String, dynamic>{};
    final agendaList = json['agenda'] is List ? json['agenda'] as List : [];
    final materialsList = json['materials'] is List ? json['materials'] as List : [];

    final typeStr = (json['program_type'] ?? '').toString().toLowerCase();
    final ProgramType type;
    if (typeStr.contains('campaign')) {
      type = ProgramType.campaign;
    } else if (typeStr.contains('conference')) {
      type = ProgramType.conference;
    } else if (typeStr.contains('workshop')) {
      type = ProgramType.workshop;
    } else if (typeStr.contains('seminar')) {
      type = ProgramType.seminar;
    } else if (typeStr.contains('walk')) {
      type = ProgramType.communityWalk;
    } else {
      type = ProgramType.activityDrive;
    }

    final isOrg = json['is_organizer'] == 1 || json['is_organizer'] == true || json['is_organizer'] == '1';
    final city = (eventDetails['city'] ?? json['city_text'] ?? json['city'] ?? '').toString();
    final country = (eventDetails['country'] ?? json['country_text'] ?? json['country'] ?? '').toString();
    final location = [city, country].where((s) => s.isNotEmpty).join(', ');
    final organizer = (eventDetails['organizer'] ?? json['organizer_name'] ?? json['organization_entity_name'] ?? (isOrg ? 'You (Organizer)' : 'IDF Active')).toString();
    final venue = (eventDetails['venue'] ?? json['venue'] ?? location).toString();
    final startDate = (eventDetails['start_date'] ?? json['start_date'] ?? '').toString();
    final endDate = (eventDetails['end_date'] ?? json['end_date'] ?? startDate).toString();
    final statusStr = (json['event_status'] ?? '').toString();
    final status = ProgramStatus.parse(statusStr, startDate: startDate, endDate: endDate);

    final parsedAgenda = agendaList.whereType<Map<String, dynamic>>().map((a) {
      return ProgramAgendaItem(
        time: (a['time'] ?? a['start_time'] ?? '').toString(),
        title: (a['title'] ?? '').toString(),
        description: a['description']?.toString(),
      );
    }).toList();

    final parsedMaterials = materialsList.whereType<Map<String, dynamic>>().map((m) {
      return ProgramMaterialItem.fromJson(m);
    }).toList();

    final contactInfo = ProgramContactInfo(
      contactPerson: (contact['person'] ?? contact['contact_person'] ?? '').toString(),
      phone: (contact['phone'] ?? contact['contact_phone'] ?? '').toString(),
      email: (contact['email'] ?? contact['contact_email'] ?? '').toString(),
    );

    final isReg = registration['is_registered'] == true || json['is_registered'] == true;
    final canReg = registration['can_register'] != false;
    final regLink = (registration['registration_link'] ?? json['registration_link'])?.toString();
    final regInstructions = (registration['registration_instructions'] ?? json['registration_instructions'])?.toString();

    final effectiveBanner = json['banner_image_url'] ?? json['cover_image_url'] ?? json['banner'];

    return ProgramModel(
      id: (json['id'] ?? json['program_no'] ?? '').toString(),
      programNo: json['program_no']?.toString(),
      title: (json['title'] ?? json['program_name'] ?? '').toString(),
      tag: (json['program_type'] ?? 'ACTIVITY DRIVE').toString().toUpperCase(),
      type: type,
      status: status,
      organizer: organizer.isNotEmpty ? organizer : 'IDF Active',
      organizationType: (json['organization_type'] ?? json['organization_type_text'] ?? '').toString(),
      venue: venue.isNotEmpty ? venue : (location.isNotEmpty ? location : 'TBD'),
      location: location.isNotEmpty ? location : venue,
      country: country,
      city: city,
      startDate: startDate,
      endDate: endDate,
      description: (json['about'] ?? json['description'] ?? json['program_description'] ?? '').toString(),
      agenda: parsedAgenda,
      materials: parsedMaterials,
      contactInfo: contactInfo,
      isRegistered: isReg,
      canRegister: canReg,
      gradientColors: const [0xFF006097, 0xFF017CC2],
      imageUrl: ApiConfig.resolveImageUrl(effectiveBanner?.toString()),
      category: json['program_type']?.toString(),
      registrationLink: regLink,
      registrationInstructions: regInstructions,
      reviewStatus: (json['review_status'] ?? json['status'])?.toString(),
      isOrganizer: isOrg,
    );
  }

  factory ProgramModel.fromApiItem(dynamic apiItem) {
    if (apiItem is Map<String, dynamic>) {
      return ProgramModel.fromDetailJson(apiItem);
    }

    if (apiItem is ProgramApiItem) {
      final startDate = apiItem.startDate?.toString() ?? '';
      final endDate = (apiItem.endDate ?? apiItem.startDate)?.toString() ?? '';
      final statusStr = apiItem.eventStatus;
      final status = ProgramStatus.parse(statusStr, startDate: startDate, endDate: endDate);

      final typeStr = apiItem.programType.toLowerCase();
      final ProgramType type;
      if (typeStr.contains('campaign')) {
        type = ProgramType.campaign;
      } else if (typeStr.contains('conference')) {
        type = ProgramType.conference;
      } else if (typeStr.contains('workshop')) {
        type = ProgramType.workshop;
      } else if (typeStr.contains('seminar')) {
        type = ProgramType.seminar;
      } else if (typeStr.contains('walk')) {
        type = ProgramType.communityWalk;
      } else {
        type = ProgramType.activityDrive;
      }

      final city = apiItem.cityText?.toString() ?? '';
      final country = apiItem.countryText?.toString() ?? '';
      final location = [city, country].where((s) => s.isNotEmpty).join(', ');

      return ProgramModel(
        id: apiItem.id.toString(),
        programNo: apiItem.programNo ?? (apiItem.id > 0 ? 'PRG-2026-0000${apiItem.id}' : null),
        title: apiItem.title,
        tag: apiItem.programType.isNotEmpty ? apiItem.programType.toUpperCase() : 'ACTIVITY DRIVE',
        type: type,
        status: status,
        organizer: (apiItem.organizerName.isNotEmpty)
            ? apiItem.organizerName
            : (apiItem.isOrganizer ? 'You (Organizer)' : 'IDF Active'),
        organizationType: '',
        venue: location.isNotEmpty ? location : 'IDF Active Venue',
        location: location.isNotEmpty ? location : 'International',
        country: country,
        city: city,
        startDate: apiItem.startDate ?? '',
        endDate: apiItem.endDate ?? apiItem.startDate ?? '',
        description: '',
        agenda: const [],
        materials: const [],
        contactInfo: const ProgramContactInfo(
          contactPerson: '',
          phone: '',
          email: '',
        ),
        isRegistered: apiItem.isRegistered,
        canRegister: true,
        gradientColors: const [0xFF006097, 0xFF017CC2],
        imageUrl: ApiConfig.resolveImageUrl(apiItem.coverImageUrl ?? apiItem.bannerImageUrl ?? apiItem.banner),
        category: apiItem.programType.isNotEmpty ? apiItem.programType : null,
        registrationLink: apiItem.registrationLink,
        reviewStatus: apiItem.reviewStatus ?? apiItem.status,
        isOrganizer: apiItem.isOrganizer,
      );
    }

    if (apiItem is HomeRegisteredProgram) {
      final startDate = apiItem.startDate?.toString() ?? '';
      final endDate = (apiItem.endDate ?? apiItem.startDate)?.toString() ?? '';
      final statusStr = apiItem.eventStatus;
      final status = ProgramStatus.parse(statusStr, startDate: startDate, endDate: endDate);

      final typeStr = apiItem.programType.toLowerCase();
      final ProgramType type;
      if (typeStr.contains('campaign')) {
        type = ProgramType.campaign;
      } else if (typeStr.contains('conference')) {
        type = ProgramType.conference;
      } else if (typeStr.contains('workshop')) {
        type = ProgramType.workshop;
      } else if (typeStr.contains('seminar')) {
        type = ProgramType.seminar;
      } else if (typeStr.contains('walk')) {
        type = ProgramType.communityWalk;
      } else {
        type = ProgramType.activityDrive;
      }

      final city = apiItem.cityText?.toString() ?? '';
      final country = apiItem.countryText?.toString() ?? '';
      final location = [city, country].where((s) => s.isNotEmpty).join(', ');

      return ProgramModel(
        id: apiItem.id.toString(),
        programNo: apiItem.programNo ?? (apiItem.id > 0 ? 'PRG-2026-0000${apiItem.id}' : null),
        title: apiItem.title,
        tag: apiItem.programType.isNotEmpty ? apiItem.programType.toUpperCase() : 'ACTIVITY DRIVE',
        type: type,
        status: status,
        organizer: (apiItem.organizerName?.isNotEmpty ?? false)
            ? apiItem.organizerName!
            : (apiItem.isOrganizer ? 'You (Organizer)' : 'IDF Active'),
        organizationType: '',
        venue: location.isNotEmpty ? location : 'IDF Active Venue',
        location: location.isNotEmpty ? location : 'International',
        country: country,
        city: city,
        startDate: apiItem.startDate ?? '',
        endDate: apiItem.endDate ?? apiItem.startDate ?? '',
        description: '',
        agenda: const [],
        materials: const [],
        contactInfo: const ProgramContactInfo(
          contactPerson: '',
          phone: '',
          email: '',
        ),
        isRegistered: apiItem.isRegistered,
        canRegister: true,
        gradientColors: const [0xFF006097, 0xFF017CC2],
        imageUrl: ApiConfig.resolveImageUrl(apiItem.coverImageUrl ?? apiItem.bannerImageUrl ?? apiItem.banner),
        category: apiItem.programType.isNotEmpty ? apiItem.programType : null,
        registrationLink: apiItem.registrationLink,
        reviewStatus: apiItem.reviewStatus ?? apiItem.status,
        isOrganizer: apiItem.isOrganizer,
      );
    }

    // Defensive fallback using safe reflection-free property access
    String? safeProp(String prop) {
      try {
        switch (prop) {
          case 'id': return apiItem.id?.toString();
          case 'title': return (apiItem.title ?? apiItem.programName)?.toString();
          case 'programType': return apiItem.programType?.toString();
          case 'cityText': return apiItem.cityText?.toString();
          case 'countryText': return apiItem.countryText?.toString();
          case 'startDate': return apiItem.startDate?.toString();
          case 'endDate': return apiItem.endDate?.toString();
          case 'eventStatus': return apiItem.eventStatus?.toString();
          case 'coverImageUrl': return apiItem.coverImageUrl?.toString();
          case 'bannerImageUrl': return apiItem.bannerImageUrl?.toString();
          case 'banner': return apiItem.banner?.toString();
          case 'organizerName': return apiItem.organizerName?.toString();
          case 'registrationLink': return apiItem.registrationLink?.toString();
          case 'reviewStatus': return apiItem.reviewStatus?.toString();
          case 'status': return apiItem.status?.toString();
        }
      } catch (_) {}
      return null;
    }

    final startDate = safeProp('startDate') ?? '';
    final endDate = safeProp('endDate') ?? startDate;
    final statusStr = safeProp('eventStatus') ?? '';
    final status = ProgramStatus.parse(statusStr, startDate: startDate, endDate: endDate);

    final typeStr = (safeProp('programType') ?? '').toLowerCase();
    final ProgramType type;
    if (typeStr.contains('campaign')) {
      type = ProgramType.campaign;
    } else if (typeStr.contains('conference')) {
      type = ProgramType.conference;
    } else if (typeStr.contains('workshop')) {
      type = ProgramType.workshop;
    } else if (typeStr.contains('seminar')) {
      type = ProgramType.seminar;
    } else if (typeStr.contains('walk')) {
      type = ProgramType.communityWalk;
    } else {
      type = ProgramType.activityDrive;
    }

    final city = safeProp('cityText') ?? '';
    final country = safeProp('countryText') ?? '';
    final location = [city, country].where((s) => s.isNotEmpty).join(', ');
    final rawId = safeProp('id') ?? '0';

    return ProgramModel(
      id: rawId,
      programNo: 'PRG-2026-0000$rawId',
      title: safeProp('title') ?? 'IDF Program',
      tag: (safeProp('programType') ?? 'ACTIVITY DRIVE').toUpperCase(),
      type: type,
      status: status,
      organizer: safeProp('organizerName') ?? 'IDF Active',
      organizationType: '',
      venue: location.isNotEmpty ? location : 'IDF Active Venue',
      location: location.isNotEmpty ? location : 'International',
      country: country,
      city: city,
      startDate: startDate,
      endDate: endDate,
      description: '',
      agenda: const [],
      materials: const [],
      contactInfo: const ProgramContactInfo(
        contactPerson: '',
        phone: '',
        email: '',
      ),
      isRegistered: true,
      canRegister: true,
      gradientColors: const [0xFF006097, 0xFF017CC2],
      imageUrl: ApiConfig.resolveImageUrl(safeProp('coverImageUrl') ?? safeProp('bannerImageUrl') ?? safeProp('banner')),
      category: safeProp('programType'),
      registrationLink: safeProp('registrationLink'),
      reviewStatus: safeProp('reviewStatus') ?? safeProp('status'),
      isOrganizer: false,
    );
  }

  static List<ProgramModel> samplePrograms() {
    return [
      ProgramModel(
        id: 'PRG-2025-001',
        title: 'Global Walk for Diabetes 2025',
        tag: 'ACTIVITY DRIVE',
        type: ProgramType.activityDrive,
        status: ProgramStatus.upcoming,
        organizer: 'IDF Africa Region',
        organizationType: 'NGO / Non-profit Organization',
        venue: 'Uhuru Park, Nairobi, Kenya',
        location: 'Nairobi, Kenya',
        country: 'Kenya',
        city: 'Nairobi',
        startDate: '2025-11-14',
        endDate: '2025-11-14',
        description:
            'Join thousands of people worldwide in a global walk to raise awareness about diabetes and the importance of physical activity. The Global Walk for Diabetes is an annual event organized by IDF as part of the ACTIVATE initiative.',
        agenda: const [
          ProgramAgendaItem(
            time: '08:00',
            title: 'Registration & warm-up',
            description: 'Participant check-in, bib distribution, and aerobic warm-up session led by certified fitness trainers.',
          ),
          ProgramAgendaItem(
            time: '09:00',
            title: 'Opening ceremony',
            description: 'Welcome address by IDF Regional Director and special guest dignitary.',
          ),
          ProgramAgendaItem(
            time: '09:30',
            title: 'Walk begins (5km route)',
            description: 'Scenic community walk through Nairobi central parks with medical support and hydration stations.',
          ),
          ProgramAgendaItem(
            time: '11:00',
            title: 'Cool-down & refreshments',
            description: 'Guided stretching, complimentary glucose screenings, and healthy refreshments.',
          ),
          ProgramAgendaItem(
            time: '11:30',
            title: 'Guest speakers & closing',
            description: 'Keynote on physical activity in diabetes prevention and prize distribution.',
          ),
        ],
        contactInfo: const ProgramContactInfo(
          contactPerson: 'Dr. Amina Osei',
          phone: '+254 700 123 456',
          email: 'africa@idf.org',
        ),
        isRegistered: false,
        gradientColors: [0xFF006097, 0xFF017CC2],
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&auto=format&fit=crop&q=80',
        category: 'Activity Drive',
      ),
      ProgramModel(
        id: 'PRG-2025-002',
        title: 'ACTIVATE Physical Activity Summit',
        tag: 'CONFERENCE',
        type: ProgramType.conference,
        status: ProgramStatus.upcoming,
        organizer: 'IDF Global Headquarters',
        organizationType: 'Academic / Research Institution',
        venue: 'Brussels International Convention Centre',
        location: 'Brussels, Belgium',
        country: 'Belgium',
        city: 'Brussels',
        startDate: '2025-12-05',
        endDate: '2025-12-07',
        description:
            'A global gathering of healthcare leaders, sports medicine experts, and policymakers dedicated to integrating physical activity into standard diabetes prevention and management regimens.',
        agenda: const [
          ProgramAgendaItem(
            time: '09:00',
            title: 'Welcome & Global Policy Briefing',
          ),
          ProgramAgendaItem(
            time: '11:00',
            title: 'Clinical Guidelines for Prescribing Exercise in T2D',
          ),
          ProgramAgendaItem(
            time: '14:00',
            title: 'Workshops & Technology Demonstrations',
          ),
          ProgramAgendaItem(
            time: '16:30',
            title: 'Regional Action Plan Roundtables',
          ),
        ],
        contactInfo: const ProgramContactInfo(
          contactPerson: 'Prof. Jean-Marc Dupont',
          phone: '+32 2 543 16 00',
          email: 'activate@idf.org',
        ),
        isRegistered: false,
        gradientColors: [0xFF4F46E5, 0xFF7C3AED],
        imageUrl: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800&auto=format&fit=crop&q=80',
        category: 'Conference',
      ),
      ProgramModel(
        id: 'PRG-2025-003',
        title: 'Community Cycling Campaign – SEA',
        tag: 'CAMPAIGN',
        type: ProgramType.campaign,
        status: ProgramStatus.ongoing,
        organizer: 'IDF Western Pacific',
        organizationType: 'NGO / Non-profit Organization',
        venue: 'Lumpini Park Circuit, Bangkok',
        location: 'Bangkok, Thailand',
        country: 'Thailand',
        city: 'Bangkok',
        startDate: '2025-08-10',
        endDate: '2025-10-30',
        description:
            'A 3-month regional cycling campaign encouraging workplace commuters and families to cycle daily, tracking collective mileage towards 1,000,000 km for diabetes awareness.',
        agenda: const [
          ProgramAgendaItem(
            time: '06:30',
            title: 'Morning group ride flag-off',
          ),
          ProgramAgendaItem(
            time: '08:30',
            title: 'Community health booths & bike safety clinic',
          ),
          ProgramAgendaItem(
            time: '10:00',
            title: 'Youth cycling skills workshop',
          ),
        ],
        contactInfo: const ProgramContactInfo(
          contactPerson: 'Somchai Prasert',
          phone: '+66 2 345 6789',
          email: 'wp@idf.org',
        ),
        isRegistered: true,
        gradientColors: [0xFF059669, 0xFF10B981],
        imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80',
        category: 'Campaign',
      ),
      ProgramModel(
        id: 'PRG-2025-004',
        title: 'Diabetes Awareness Walk 2026',
        tag: 'CAMPAIGN',
        type: ProgramType.campaign,
        status: ProgramStatus.upcoming,
        organizer: 'IDF South-East Asia',
        organizationType: 'Healthcare Organization',
        venue: 'Necklace Road, Hussain Sagar Lake',
        location: 'Hyderabad, India',
        country: 'India',
        city: 'Hyderabad',
        startDate: '2026-09-18',
        endDate: '2026-09-18',
        description:
            'Annual city-wide 10k walk bringing together over 5,000 citizens, doctors, and students to promote daily exercise and early diabetes risk assessment.',
        agenda: const [
          ProgramAgendaItem(
            time: '06:00',
            title: 'Assembly & Kit Distribution',
          ),
          ProgramAgendaItem(
            time: '06:45',
            title: 'Walk Kick-off',
          ),
          ProgramAgendaItem(
            time: '08:30',
            title: 'Breakfast & Free Blood Sugar Checks',
          ),
        ],
        contactInfo: const ProgramContactInfo(
          contactPerson: 'Dr. Rajesh Kumar',
          phone: '+91 40 1234 5678',
          email: 'sea@idf.org',
        ),
        isRegistered: true,
        gradientColors: [0xFFEA580C, 0xFFF97316],
        imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&auto=format&fit=crop&q=80',
        category: 'Campaign',
      ),
    ];
  }
}
