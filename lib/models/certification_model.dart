import 'application_item_model.dart';

class InstitutionTypeInfo {
  final String id;
  final String title;
  final int maxPoints;
  final String description;
  final String emoji;

  const InstitutionTypeInfo({
    required this.id,
    required this.title,
    required this.maxPoints,
    required this.description,
    required this.emoji,
  });

  static const List<InstitutionTypeInfo> defaultTypes = [
    InstitutionTypeInfo(
      id: 'workplace',
      title: 'Workplace / Worksite /\nOffice / Hospital',
      maxPoints: 15,
      description:
          'Corporate offices, industrial worksites, and hospital premises promoting staff physical activity.',
      emoji: '🏢',
    ),
    InstitutionTypeInfo(
      id: 'ngo',
      title: 'NGO / Community\nOrganization',
      maxPoints: 6,
      description:
          'Non-governmental and community-based organizations driving physical activity programs.',
      emoji: '🤝',
    ),
    InstitutionTypeInfo(
      id: 'school',
      title: 'School',
      maxPoints: 16,
      description:
          'Primary and secondary educational institutions with structured physical education.',
      emoji: '🏫',
    ),
    InstitutionTypeInfo(
      id: 'university',
      title: 'College / University',
      maxPoints: 10,
      description:
          'Higher education institutions promoting student and staff physical well-being.',
      emoji: '🎓',
    ),
  ];
}

class EvidenceItem {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  String? filePath;
  String? fileName;

  EvidenceItem({
    required this.id,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.filePath,
    this.fileName,
  });
}

class CertificationApplicationModel {
  // Step 1: Type
  String institutionTypeId;
  String institutionTypeTitle;
  int categoryMaxScore;

  // Step 2: Institution Details
  String institutionName;
  String address;
  String country;
  String regionState;
  String city;
  String contactPerson;
  String contactPhone;
  String contactEmail;
  String numberOfRooms;
  String distanceFromMainRoad;
  String parkingAvailability;

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
    this.institutionTypeId = 'workplace',
    this.institutionTypeTitle = 'Workplace / Worksite / Office / Hospital',
    this.categoryMaxScore = 15,
    this.institutionName = '',
    this.address = '',
    this.country = '',
    this.regionState = '',
    this.city = '',
    this.contactPerson = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.numberOfRooms = '',
    this.distanceFromMainRoad = '',
    this.parkingAvailability = '',
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
  }) : evidenceItems = evidenceItems ?? _defaultEvidence();

  static List<EvidenceItem> _defaultEvidence() {
    return [
      EvidenceItem(
        id: 'safe_area',
        title: 'Safe Exercise Area',
        description: 'Photo evidence of accessible exercise space',
        isRequired: true,
      ),
      EvidenceItem(
        id: 'signage',
        title: 'PA Promotion Signage',
        description: 'Photos of signage promoting physical activity',
        isRequired: true,
      ),
      EvidenceItem(
        id: 'facilities',
        title: 'Sports / Fitness Facilities',
        description: 'Photos of any fitness or sports equipment/areas',
        isRequired: false,
      ),
      EvidenceItem(
        id: 'policy_doc',
        title: 'PA Policy Document',
        description: 'Formal policy document or physical activity guideline',
        isRequired: false,
      ),
      EvidenceItem(
        id: 'event_records',
        title: 'Event Records',
        description: 'Photos or documents from past PA events',
        isRequired: false,
      ),
    ];
  }

  static CertificationApplicationModel prefilledForCertificate(
      CertificateApplicationItem item) {
    String typeId = 'university';
    String typeTitle = 'College / University';
    int maxScore = 10;
    final lowerType = item.institutionType.toLowerCase();
    if (lowerType.contains('work') ||
        lowerType.contains('hospital') ||
        lowerType.contains('office') ||
        lowerType.contains('health')) {
      typeId = 'workplace';
      typeTitle = 'Workplace / Worksite / Office / Hospital';
      maxScore = 15;
    } else if (lowerType.contains('ngo') || lowerType.contains('community')) {
      typeId = 'ngo';
      typeTitle = 'NGO / Community Organization';
      maxScore = 6;
    } else if (lowerType.contains('school')) {
      typeId = 'school';
      typeTitle = 'School';
      maxScore = 16;
    }

    final isChangesRequired = item.status == 'Changes Required';

    return CertificationApplicationModel(
      institutionTypeId: typeId,
      institutionTypeTitle: typeTitle,
      categoryMaxScore: maxScore,
      institutionName: item.institutionName,
      address: '124 University Way, Main Campus',
      country: 'Nigeria',
      regionState: 'Lagos',
      city: 'Ojo',
      contactPerson: 'Dr. Sarah Osei',
      contactPhone: '+234 800 000 0000',
      contactEmail: 'contact@org.com',
      numberOfRooms: '150+',
      distanceFromMainRoad: '50m',
      parkingAvailability: 'Ample Parking Available',
      // Infrastructure
      hasSafeExerciseArea: true,
      hasStandingDesks: true,
      hasDedicatedWalkingTrail: true,
      hasCycleStands: true,
      hasPaPromotionSignage: true,
      // Organizational
      hasAnnualHealthChecks: true,
      sportsEventsCount: '4',
      hasFormalPaPolicy: true,
      hasStructuredErgonomicBreaks: true,
      // Individual
      hasPaChampions: true,
      memberParticipationPercentage: '78%',
      hasActivePlayIntegrated: true,
      // Scalability
      hasExternalPartnerships: true,
      advocacyActivitiesDescription:
          'Annual National Diabetes Walk and student wellness campaign.',
      receivesSponsorship: true,
      // Evidence
      evidenceItems: [
        EvidenceItem(
          id: 'safe_area',
          title: 'Safe Exercise Area',
          description: 'Photo evidence of accessible exercise space',
          isRequired: true,
          fileName: 'campus_exercise_ground.jpg',
          filePath: 'campus_exercise_ground.jpg',
        ),
        EvidenceItem(
          id: 'signage',
          title: 'PA Promotion Signage',
          description: 'Photos of signage promoting physical activity',
          isRequired: true,
          fileName: 'wellness_signage_display.jpg',
          filePath: 'wellness_signage_display.jpg',
        ),
        EvidenceItem(
          id: 'facilities',
          title: 'Sports / Fitness Facilities',
          description: 'Photos of any fitness or sports equipment/areas',
          isRequired: false,
          fileName: 'sports_hall_gym.jpg',
          filePath: 'sports_hall_gym.jpg',
        ),
        EvidenceItem(
          id: 'policy_doc',
          title: 'PA Policy Document',
          description: 'Formal policy document or physical activity guideline',
          isRequired: false,
          fileName: isChangesRequired
              ? null
              : 'institutional_wellness_policy_2025.pdf',
          filePath: isChangesRequired
              ? null
              : 'institutional_wellness_policy_2025.pdf',
        ),
        EvidenceItem(
          id: 'event_records',
          title: 'Event Records',
          description: 'Photos or documents from past PA events',
          isRequired: false,
          fileName: 'diabetes_walk_2025_report.pdf',
          filePath: 'diabetes_walk_2025_report.pdf',
        ),
      ],
      declarationAccepted: true,
      applicationId: item.certificateId,
      submissionDate: DateTime.now(),
      status: item.status,
    );
  }
}

