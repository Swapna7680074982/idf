enum ProgramStatus {
  upcoming,
  ongoing,
  completed,
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

class ProgramModel {
  final String id;
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
  final ProgramContactInfo contactInfo;
  final bool isRegistered;
  final List<int> gradientColors;
  final String? imageUrl;
  final String? category;
  final int participantsCount;
  final String targetAudience;

  const ProgramModel({
    required this.id,
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
    required this.contactInfo,
    this.isRegistered = false,
    required this.gradientColors,
    this.imageUrl,
    this.category,
    this.participantsCount = 1200,
    this.targetAudience = 'General Public & Youth',
  });

  ProgramModel copyWith({
    String? id,
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
    ProgramContactInfo? contactInfo,
    bool? isRegistered,
    List<int>? gradientColors,
    String? imageUrl,
    String? category,
    int? participantsCount,
    String? targetAudience,
  }) {
    return ProgramModel(
      id: id ?? this.id,
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
      contactInfo: contactInfo ?? this.contactInfo,
      isRegistered: isRegistered ?? this.isRegistered,
      gradientColors: gradientColors ?? this.gradientColors,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      participantsCount: participantsCount ?? this.participantsCount,
      targetAudience: targetAudience ?? this.targetAudience,
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
