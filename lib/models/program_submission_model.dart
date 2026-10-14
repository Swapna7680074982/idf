class ProgramSubmissionModel {
  // Step 1: Program Info
  String programName;
  String programType;
  int? programTypeId;
  String description;

  // Banner
  String? bannerPath;
  String? bannerFileName;
  int? bannerFileId;
  String? bannerUrl;

  // Step 2: Organizer
  String organizingEntityName;
  String organizationType;
  int? organizationTypeId;
  String contactPerson;
  String phone;
  String email;

  // Step 3: Date & Location
  DateTime? startDate;
  DateTime? endDate;
  String country;
  int? countryId;
  String regionState;
  int? regionId;
  String city;
  int? cityId;
  String venueAddress;

  // Step 4: Content
  String programDescription;
  String agenda;
  List<Map<String, String>> agendaItems;

  // Step 5: Objectives & Target
  String targetAudience;
  String expectedParticipants;
  String objectives;

  // Step 6: Materials
  List<String> uploadedFileNames;
  List<int> supportingFileIds;

  // Metadata generated upon submission
  String? referenceNumber;
  DateTime? submissionDate;
  String status;

  ProgramSubmissionModel({
    this.programName = '',
    this.programType = '',
    this.programTypeId,
    this.description = '',
    this.bannerPath,
    this.bannerFileName,
    this.bannerFileId,
    this.bannerUrl,
    this.organizingEntityName = '',
    this.organizationType = '',
    this.organizationTypeId,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.startDate,
    this.endDate,
    this.country = '',
    this.countryId,
    this.regionState = '',
    this.regionId,
    this.city = '',
    this.cityId,
    this.venueAddress = '',
    this.programDescription = '',
    this.agenda = '',
    List<Map<String, String>>? agendaItems,
    this.targetAudience = '',
    this.expectedParticipants = '',
    this.objectives = '',
    List<String>? uploadedFileNames,
    List<int>? supportingFileIds,
    this.referenceNumber,
    this.submissionDate,
    this.status = 'AI Review',
  })  : agendaItems = agendaItems ?? [],
        uploadedFileNames = uploadedFileNames ?? [],
        supportingFileIds = supportingFileIds ?? [];

  ProgramSubmissionModel copyWith({
    String? programName,
    String? programType,
    int? programTypeId,
    String? description,
    String? bannerPath,
    String? bannerFileName,
    int? bannerFileId,
    String? bannerUrl,
    String? organizingEntityName,
    String? organizationType,
    int? organizationTypeId,
    String? contactPerson,
    String? phone,
    String? email,
    DateTime? startDate,
    DateTime? endDate,
    String? country,
    int? countryId,
    String? regionState,
    int? regionId,
    String? city,
    int? cityId,
    String? venueAddress,
    String? programDescription,
    String? agenda,
    String? targetAudience,
    String? expectedParticipants,
    String? objectives,
    List<String>? uploadedFileNames,
    List<int>? supportingFileIds,
    String? referenceNumber,
    DateTime? submissionDate,
    String? status,
  }) {
    return ProgramSubmissionModel(
      programName: programName ?? this.programName,
      programType: programType ?? this.programType,
      programTypeId: programTypeId ?? this.programTypeId,
      description: description ?? this.description,
      bannerPath: bannerPath ?? this.bannerPath,
      bannerFileName: bannerFileName ?? this.bannerFileName,
      bannerFileId: bannerFileId ?? this.bannerFileId,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      organizingEntityName: organizingEntityName ?? this.organizingEntityName,
      organizationType: organizationType ?? this.organizationType,
      organizationTypeId: organizationTypeId ?? this.organizationTypeId,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      country: country ?? this.country,
      countryId: countryId ?? this.countryId,
      regionState: regionState ?? this.regionState,
      regionId: regionId ?? this.regionId,
      city: city ?? this.city,
      cityId: cityId ?? this.cityId,
      venueAddress: venueAddress ?? this.venueAddress,
      programDescription: programDescription ?? this.programDescription,
      agenda: agenda ?? this.agenda,
      targetAudience: targetAudience ?? this.targetAudience,
      expectedParticipants: expectedParticipants ?? this.expectedParticipants,
      objectives: objectives ?? this.objectives,
      uploadedFileNames: uploadedFileNames ?? List.from(this.uploadedFileNames),
      supportingFileIds: supportingFileIds ?? List.from(this.supportingFileIds),
      referenceNumber: referenceNumber ?? this.referenceNumber,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
    );
  }
}
