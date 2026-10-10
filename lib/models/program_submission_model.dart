class ProgramSubmissionModel {
  // Step 1: Program Info
  String programName;
  String programType;
  String description;

  // Step 2: Organizer
  String organizingEntityName;
  String organizationType;
  String contactPerson;
  String phone;
  String email;

  // Step 3: Date & Location
  DateTime? startDate;
  DateTime? endDate;
  String country;
  String regionState;
  String city;
  String venueAddress;

  // Step 4: Content
  String programDescription;
  String agenda;

  // Step 5: Objectives & Target
  String targetAudience;
  String expectedParticipants;
  String objectives;

  // Step 6: Materials
  List<String> uploadedFileNames;

  // Metadata generated upon submission
  String? referenceNumber;
  DateTime? submissionDate;
  String status;

  ProgramSubmissionModel({
    this.programName = '',
    this.programType = '',
    this.description = '',
    this.organizingEntityName = '',
    this.organizationType = '',
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.startDate,
    this.endDate,
    this.country = '',
    this.regionState = '',
    this.city = '',
    this.venueAddress = '',
    this.programDescription = '',
    this.agenda = '',
    this.targetAudience = '',
    this.expectedParticipants = '',
    this.objectives = '',
    List<String>? uploadedFileNames,
    this.referenceNumber,
    this.submissionDate,
    this.status = 'AI Review',
  }) : uploadedFileNames = uploadedFileNames ?? [];

  ProgramSubmissionModel copyWith({
    String? programName,
    String? programType,
    String? description,
    String? organizingEntityName,
    String? organizationType,
    String? contactPerson,
    String? phone,
    String? email,
    DateTime? startDate,
    DateTime? endDate,
    String? country,
    String? regionState,
    String? city,
    String? venueAddress,
    String? programDescription,
    String? agenda,
    String? targetAudience,
    String? expectedParticipants,
    String? objectives,
    List<String>? uploadedFileNames,
    String? referenceNumber,
    DateTime? submissionDate,
    String? status,
  }) {
    return ProgramSubmissionModel(
      programName: programName ?? this.programName,
      programType: programType ?? this.programType,
      description: description ?? this.description,
      organizingEntityName: organizingEntityName ?? this.organizingEntityName,
      organizationType: organizationType ?? this.organizationType,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      country: country ?? this.country,
      regionState: regionState ?? this.regionState,
      city: city ?? this.city,
      venueAddress: venueAddress ?? this.venueAddress,
      programDescription: programDescription ?? this.programDescription,
      agenda: agenda ?? this.agenda,
      targetAudience: targetAudience ?? this.targetAudience,
      expectedParticipants: expectedParticipants ?? this.expectedParticipants,
      objectives: objectives ?? this.objectives,
      uploadedFileNames: uploadedFileNames ?? List.from(this.uploadedFileNames),
      referenceNumber: referenceNumber ?? this.referenceNumber,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
    );
  }
}
