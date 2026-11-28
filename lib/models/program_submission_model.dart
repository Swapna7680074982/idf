import 'dart:io';
import '../services/api_config.dart';
import '../services/token_storage.dart';
import 'application_item_model.dart';
import 'program_model.dart';

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
  String pincode;
  String venueAddress;

  // Step 4: Content
  String programDescription;
  String agenda;
  List<Map<String, String>> agendaItems;

  // Step 5: Registration Details
  String registrationInstructions;
  String registrationLink;

  // Step 6: Materials
  List<String> uploadedFileNames;
  List<int> supportingFileIds;
  List<Map<String, dynamic>> materials;

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
    this.pincode = '',
    this.venueAddress = '',
    this.programDescription = '',
    this.agenda = '',
    List<Map<String, String>>? agendaItems,
    this.registrationInstructions = '',
    this.registrationLink = '',
    List<String>? uploadedFileNames,
    List<int>? supportingFileIds,
    List<Map<String, dynamic>>? materials,
    this.referenceNumber,
    this.submissionDate,
    this.status = 'AI Review',
  })  : agendaItems = agendaItems ?? [],
        uploadedFileNames = uploadedFileNames ?? [],
        supportingFileIds = supportingFileIds ?? [],
        materials = materials ?? [];

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
    String? pincode,
    String? venueAddress,
    String? programDescription,
    String? agenda,
    String? registrationInstructions,
    String? registrationLink,
    List<String>? uploadedFileNames,
    List<int>? supportingFileIds,
    List<Map<String, dynamic>>? materials,
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
      pincode: pincode ?? this.pincode,
      venueAddress: venueAddress ?? this.venueAddress,
      programDescription: programDescription ?? this.programDescription,
      agenda: agenda ?? this.agenda,
      registrationInstructions: registrationInstructions ?? this.registrationInstructions,
      registrationLink: registrationLink ?? this.registrationLink,
      uploadedFileNames: uploadedFileNames ?? List.from(this.uploadedFileNames),
      supportingFileIds: supportingFileIds ?? List.from(this.supportingFileIds),
      materials: materials ?? List.from(this.materials),
      referenceNumber: referenceNumber ?? this.referenceNumber,
      submissionDate: submissionDate ?? this.submissionDate,
      status: status ?? this.status,
    );
  }

  /// Copies all populated fields from [other] into this model
  void copyFrom(ProgramSubmissionModel other) {
    if (other.programName.isNotEmpty) programName = other.programName;
    if (other.programType.isNotEmpty) programType = other.programType;
    if (other.programTypeId != null) programTypeId = other.programTypeId;
    if (other.description.isNotEmpty) description = other.description;
    if (other.programDescription.isNotEmpty) programDescription = other.programDescription;
    if (description.isEmpty && programDescription.isNotEmpty) description = programDescription;
    if (programDescription.isEmpty && description.isNotEmpty) programDescription = description;
    if (other.bannerPath != null && other.bannerPath!.isNotEmpty) bannerPath = other.bannerPath;
    if (other.bannerFileName != null && other.bannerFileName!.isNotEmpty) bannerFileName = other.bannerFileName;
    if (other.bannerFileId != null) bannerFileId = other.bannerFileId;
    if (other.bannerUrl != null && other.bannerUrl!.isNotEmpty) {
      final res = ApiConfig.resolveMediaUrl(other.bannerUrl);
      bannerUrl = res.isNotEmpty ? res : other.bannerUrl;
      bannerFileName ??= other.bannerFileName ?? other.bannerUrl?.split('/').last;
    } else if (other.bannerPath != null &&
        (other.bannerPath!.startsWith('http') || other.bannerPath!.startsWith('/')) &&
        !File(other.bannerPath!).existsSync()) {
      final res = ApiConfig.resolveMediaUrl(other.bannerPath);
      bannerUrl = res.isNotEmpty ? res : other.bannerPath;
      bannerFileName ??= other.bannerFileName ?? other.bannerPath?.split('/').last;
    }
    if (other.organizingEntityName.isNotEmpty && other.organizingEntityName.toLowerCase() != 'you (organizer)') {
      organizingEntityName = other.organizingEntityName;
    }
    if (other.organizationType.isNotEmpty) organizationType = other.organizationType;
    if (other.organizationTypeId != null) organizationTypeId = other.organizationTypeId;
    if (other.contactPerson.isNotEmpty) contactPerson = other.contactPerson;
    if (other.phone.isNotEmpty) phone = other.phone;
    if (other.email.isNotEmpty) email = other.email;
    if (other.startDate != null) startDate = other.startDate;
    if (other.endDate != null) endDate = other.endDate;
    if (other.country.isNotEmpty) country = other.country;
    if (other.countryId != null) countryId = other.countryId;
    if (other.regionState.isNotEmpty) regionState = other.regionState;
    if (other.regionId != null) regionId = other.regionId;
    if (other.city.isNotEmpty) city = other.city;
    if (other.cityId != null) cityId = other.cityId;
    if (other.pincode.isNotEmpty) pincode = other.pincode;
    if (other.venueAddress.isNotEmpty) venueAddress = other.venueAddress;
    if (other.agenda.isNotEmpty) agenda = other.agenda;
    if (other.agendaItems.isNotEmpty) agendaItems = List.from(other.agendaItems);
    if (other.registrationInstructions.isNotEmpty) registrationInstructions = other.registrationInstructions;
    if (other.registrationLink.isNotEmpty) registrationLink = other.registrationLink;
    if (other.uploadedFileNames.isNotEmpty) uploadedFileNames = List.from(other.uploadedFileNames);
    if (other.supportingFileIds.isNotEmpty) supportingFileIds = List.from(other.supportingFileIds);
    if (other.materials.isNotEmpty) materials = List.from(other.materials);
    if (other.referenceNumber != null && other.referenceNumber!.isNotEmpty) referenceNumber = other.referenceNumber;
    if (other.submissionDate != null) submissionDate = other.submissionDate;
    if (other.status.isNotEmpty) status = other.status;
  }

  /// Automatically fills missing organizer and contact information from the logged-in user and organization
  void applyUserOrgFallback() {
    final user = TokenStorage.currentUser;
    final org = user?.organization;
    if (org != null) {
      if (organizingEntityName.trim().isEmpty || organizingEntityName.toLowerCase() == 'you (organizer)') {
        organizingEntityName = org.name;
      }
      if (organizationType.trim().isEmpty && org.organizationType != null && org.organizationType!.isNotEmpty) {
        organizationType = org.organizationType!;
      }
      organizationTypeId ??= org.organizationTypeId;
      if (contactPerson.trim().isEmpty) {
        contactPerson = org.contactPerson ?? user?.fullName ?? '';
      }
      if (email.trim().isEmpty) {
        email = org.contactEmail ?? user?.email ?? '';
      }
      if (phone.trim().isEmpty) {
        final code = org.contactPhoneCode ?? user?.phoneCountryCode ?? '';
        final num = org.contactPhone ?? user?.phoneNumber ?? '';
        phone = '$code $num'.trim();
      }
      if (country.trim().isEmpty && org.country != null && org.country!.isNotEmpty) {
        country = org.country!;
        countryId ??= org.countryId;
      }
      if (regionState.trim().isEmpty && org.region != null && org.region!.isNotEmpty) {
        regionState = org.region!;
        regionId ??= org.regionId;
      }
      if (city.trim().isEmpty && org.city != null && org.city!.isNotEmpty) {
        city = org.city!;
        cityId ??= org.cityId;
      }
      if (venueAddress.trim().isEmpty && org.address != null && org.address!.isNotEmpty) {
        venueAddress = org.address!;
      }
    } else if (user != null) {
      if (contactPerson.trim().isEmpty) {
        contactPerson = user.fullName;
      }
      if (email.trim().isEmpty) {
        email = user.email;
      }
      if (phone.trim().isEmpty) {
        final code = user.phoneCountryCode ?? '';
        final num = user.phoneNumber ?? '';
        phone = '$code $num'.trim();
      }
    }
  }

  /// Builds a fully prefilled model from backend application/program detail JSON
  factory ProgramSubmissionModel.fromDetailJson(
    Map<String, dynamic> rawJson, {
    ProgramModel? programModel,
  }) {
    final Map<String, dynamic> root = Map<String, dynamic>.from(rawJson);
    final Map<String, dynamic> dataObj = root['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(root['data'] as Map<String, dynamic>)
        : <String, dynamic>{};
    final Map<String, dynamic> appObj = root['application'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(root['application'] as Map<String, dynamic>)
        : (dataObj['application'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(dataObj['application'] as Map<String, dynamic>)
            : <String, dynamic>{});
    final Map<String, dynamic> progObj = root['program'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(root['program'] as Map<String, dynamic>)
        : (dataObj['program'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(dataObj['program'] as Map<String, dynamic>)
            : (appObj['program'] is Map<String, dynamic>
                ? Map<String, dynamic>.from(appObj['program'] as Map<String, dynamic>)
                : <String, dynamic>{}));

    // Merge root, data, program, and application maps so all properties are available
    final Map<String, dynamic> json = <String, dynamic>{
      ...root,
      ...dataObj,
      ...progObj,
      ...appObj,
    };

    final Map<String, dynamic> programInfo = json['program_information'] is Map<String, dynamic>
        ? json['program_information'] as Map<String, dynamic>
        : (json['program_details'] is Map<String, dynamic>
            ? json['program_details'] as Map<String, dynamic>
            : (progObj.isNotEmpty
                ? progObj
                : (json['program'] is Map<String, dynamic>
                    ? json['program'] as Map<String, dynamic>
                    : <String, dynamic>{})));

    final Map<String, dynamic> eventDetails = json['event_details'] is Map<String, dynamic>
        ? json['event_details'] as Map<String, dynamic>
        : (programInfo['event_details'] is Map<String, dynamic>
            ? programInfo['event_details'] as Map<String, dynamic>
            : <String, dynamic>{});

    final Map<String, dynamic> contact = json['contact'] is Map<String, dynamic>
        ? json['contact'] as Map<String, dynamic>
        : (programInfo['contact'] is Map<String, dynamic>
            ? programInfo['contact'] as Map<String, dynamic>
            : <String, dynamic>{});

    final Map<String, dynamic> registration = json['registration'] is Map<String, dynamic>
        ? json['registration'] as Map<String, dynamic>
        : (programInfo['registration'] is Map<String, dynamic>
            ? programInfo['registration'] as Map<String, dynamic>
            : <String, dynamic>{});

    final Map<String, dynamic> submissionDetails = json['submission_details'] is Map<String, dynamic>
        ? json['submission_details'] as Map<String, dynamic>
        : <String, dynamic>{};

    final title = (programInfo['program_name'] ??
            programInfo['title'] ??
            json['title'] ??
            json['program_name'] ??
            programModel?.title ??
            '')
        .toString()
        .trim();

    final progType = (programInfo['program_type'] ??
            programInfo['type'] ??
            programInfo['category'] ??
            json['program_type'] ??
            json['category'] ??
            programModel?.category ??
            programModel?.tag ??
            '')
        .toString()
        .trim();

    final progTypeId = int.tryParse(
      '${programInfo['program_type_id'] ?? json['program_type_id'] ?? ''}',
    );

    final desc = (programInfo['description'] ??
            programInfo['about'] ??
            programInfo['program_description'] ??
            json['about'] ??
            json['description'] ??
            json['program_description'] ??
            programModel?.description ??
            '')
        .toString()
        .trim();

    String organizer = (programInfo['organizer_name'] ??
            programInfo['organizer'] ??
            programInfo['organization_entity_name'] ??
            eventDetails['organizer'] ??
            json['organizer_name'] ??
            json['organizer'] ??
            json['organization_entity_name'] ??
            programModel?.organizer ??
            '')
        .toString()
        .trim();
    if (organizer.toLowerCase() == 'you (organizer)') {
      organizer = '';
    }

    final orgType = (programInfo['organization_type'] ??
            programInfo['organization_type_text'] ??
            json['organization_type'] ??
            json['organization_type_text'] ??
            programModel?.organizationType ??
            '')
        .toString()
        .trim();

    final orgTypeId = int.tryParse(
      '${programInfo['organization_type_id'] ?? json['organization_type_id'] ?? ''}',
    );

    final contactPerson = (programInfo['contact_person'] ??
            contact['person'] ??
            contact['contact_person'] ??
            json['contact_person'] ??
            programModel?.contactInfo.contactPerson ??
            '')
        .toString()
        .trim();

    final phone = (programInfo['contact_phone'] ??
            programInfo['phone'] ??
            contact['phone'] ??
            contact['contact_phone'] ??
            json['contact_phone'] ??
            json['phone'] ??
            programModel?.contactInfo.phone ??
            '')
        .toString()
        .trim();

    final email = (programInfo['contact_email'] ??
            programInfo['email'] ??
            contact['email'] ??
            contact['contact_email'] ??
            json['contact_email'] ??
            json['email'] ??
            programModel?.contactInfo.email ??
            '')
        .toString()
        .trim();

    final startDateStr = (programInfo['start_date'] ??
            eventDetails['start_date'] ??
            json['start_date'] ??
            programModel?.startDate ??
            '')
        .toString()
        .trim();

    final endDateStr = (programInfo['end_date'] ??
            eventDetails['end_date'] ??
            json['end_date'] ??
            programModel?.endDate ??
            '')
        .toString()
        .trim();

    DateTime? parsedStart;
    if (startDateStr.isNotEmpty) {
      try {
        parsedStart = DateTime.tryParse(startDateStr);
      } catch (_) {}
    }

    DateTime? parsedEnd;
    if (endDateStr.isNotEmpty) {
      try {
        parsedEnd = DateTime.tryParse(endDateStr);
      } catch (_) {}
    }

    final country = (programInfo['country'] ??
            programInfo['country_text'] ??
            eventDetails['country'] ??
            json['country_text'] ??
            json['country'] ??
            programModel?.country ??
            '')
        .toString()
        .trim();

    final countryId = int.tryParse(
      '${programInfo['country_id'] ?? json['country_id'] ?? ''}',
    );

    final region = (programInfo['region'] ??
            programInfo['region_text'] ??
            programInfo['region_state'] ??
            programInfo['state'] ??
            eventDetails['region'] ??
            json['region_text'] ??
            json['region_state'] ??
            json['state'] ??
            json['region'] ??
            '')
        .toString()
        .trim();

    final regionId = int.tryParse(
      '${programInfo['region_id'] ?? json['region_id'] ?? ''}',
    );

    final city = (programInfo['city'] ??
            programInfo['city_text'] ??
            eventDetails['city'] ??
            json['city_text'] ??
            json['city'] ??
            programModel?.city ??
            '')
        .toString()
        .trim();

    final cityId = int.tryParse(
      '${programInfo['city_id'] ?? json['city_id'] ?? ''}',
    );

    final pincode = (programInfo['pincode'] ??
            programInfo['postal_code'] ??
            programInfo['zip_code'] ??
            eventDetails['pincode'] ??
            json['pincode'] ??
            json['postal_code'] ??
            json['zip_code'] ??
            '')
        .toString()
        .trim();

    final venue = (programInfo['venue'] ??
            programInfo['venue_address'] ??
            eventDetails['venue'] ??
            json['venue'] ??
            json['venue_address'] ??
            programModel?.venue ??
            '')
        .toString()
        .trim();

    final regInstructions = (programInfo['registration_instructions'] ??
            registration['registration_instructions'] ??
            json['registration_instructions'] ??
            programModel?.registrationInstructions ??
            '')
        .toString()
        .trim();

    final regLink = (programInfo['registration_link'] ??
            registration['registration_link'] ??
            json['registration_link'] ??
            programModel?.registrationLink ??
            '')
        .toString()
        .trim();

    final rawBanner = ApiConfig.extractBannerUrl(json) ??
        ApiConfig.extractBannerUrl(progObj) ??
        ApiConfig.extractBannerUrl(programInfo) ??
        ApiConfig.extractBannerUrl(eventDetails) ??
        ApiConfig.extractBannerUrl(dataObj) ??
        ApiConfig.extractBannerUrl(appObj) ??
        ApiConfig.extractBannerUrl(root) ??
        (programModel?.imageUrl?.isNotEmpty == true ? programModel!.imageUrl : null);
    final resolvedBanner = rawBanner != null && rawBanner.isNotEmpty ? ApiConfig.resolveMediaUrl(rawBanner) : null;

    final dynamic rawAgenda = programInfo['agenda'] ??
        programInfo['schedule'] ??
        json['agenda'] ??
        json['schedule'] ??
        json['program_agenda_schedule'] ??
        eventDetails['agenda'];

    final List<Map<String, String>> agendaItems = [];
    if (rawAgenda is List) {
      for (final a in rawAgenda) {
        if (a is Map) {
          final t = (a['start_time'] ?? a['time'] ?? '09:00').toString().trim();
          final itemTitle = (a['title'] ?? '').toString().trim();
          if (t.isNotEmpty || itemTitle.isNotEmpty) {
            agendaItems.add({
              'start_time': t.isNotEmpty ? t : '09:00',
              'time': t.isNotEmpty ? t : '09:00',
              'title': itemTitle,
            });
          }
        } else if (a is String && a.trim().isNotEmpty) {
          agendaItems.add({
            'start_time': '09:00',
            'time': '09:00',
            'title': a.trim(),
          });
        }
      }
    } else if (rawAgenda is String && rawAgenda.trim().isNotEmpty) {
      final lines = rawAgenda.split('\n').where((l) => l.trim().isNotEmpty);
      for (final line in lines) {
        final match = RegExp(r'^(\d{1,2}:\d{2}(?:\s*[AaPp][Mm])?)\s*[-:]?\s*(.*)$').firstMatch(line.trim());
        if (match != null) {
          agendaItems.add({
            'start_time': match.group(1)!.trim(),
            'time': match.group(1)!.trim(),
            'title': match.group(2)!.trim(),
          });
        } else {
          agendaItems.add({
            'start_time': '09:00',
            'time': '09:00',
            'title': line.trim(),
          });
        }
      }
    } else if (programModel != null && programModel.agenda.isNotEmpty) {
      for (final a in programModel.agenda) {
        agendaItems.add({
          'start_time': a.time.isNotEmpty ? a.time : '09:00',
          'time': a.time.isNotEmpty ? a.time : '09:00',
          'title': a.title,
        });
      }
    }

    final List<Map<String, dynamic>> materials = [];
    final List<String> fileNames = [];
    final List<int> fileIds = [];

    void addMaterial(dynamic m) {
      if (m is Map) {
        final map = Map<String, dynamic>.from(m);
        materials.add(map);
        final name = (map['name'] ?? map['file_name'] ?? map['title'] ?? '').toString().trim();
        if (name.isNotEmpty && !fileNames.contains(name)) {
          fileNames.add(name);
        }
        final idVal = map['file_id'] ?? map['id'] ?? map['file']?['id'];
        if (idVal != null) {
          final parsed = int.tryParse(idVal.toString());
          if (parsed != null && !fileIds.contains(parsed)) {
            fileIds.add(parsed);
          }
        }
      } else if (m is String && m.trim().isNotEmpty) {
        final name = m.trim();
        if (!fileNames.contains(name)) fileNames.add(name);
        materials.add({
          'name': name,
          'url': ApiConfig.resolveMediaUrl(name),
        });
      }
    }

    if (json['materials'] is List) {
      for (final m in json['materials'] as List) {
        addMaterial(m);
      }
    }
    if (json['supporting_material'] is List) {
      for (final m in json['supporting_material'] as List) {
        addMaterial(m);
      }
    }
    if (programInfo['materials'] is List) {
      for (final m in programInfo['materials'] as List) {
        addMaterial(m);
      }
    }
    if (programModel != null && programModel.materials.isNotEmpty) {
      for (final m in programModel.materials) {
        if (!fileNames.contains(m.name)) fileNames.add(m.name);
        materials.add({
          'name': m.name,
          'url': m.url,
          'mime_type': m.mimeType,
        });
      }
    }

    final refNo = (submissionDetails['application_id'] ??
            submissionDetails['program_no'] ??
            json['program_no'] ??
            json['application_id'] ??
            programModel?.programNo ??
            '')
        .toString()
        .trim();

    final status = (submissionDetails['review_status'] ??
            submissionDetails['status'] ??
            json['review_status'] ??
            json['status'] ??
            programModel?.reviewStatus ??
            'submitted')
        .toString()
        .trim();

    final model = ProgramSubmissionModel(
      programName: title,
      programType: progType,
      programTypeId: progTypeId,
      description: desc,
      programDescription: desc,
      organizingEntityName: organizer,
      organizationType: orgType,
      organizationTypeId: orgTypeId,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      startDate: parsedStart,
      endDate: parsedEnd,
      country: country,
      countryId: countryId,
      regionState: region,
      regionId: regionId,
      city: city,
      cityId: cityId,
      pincode: pincode,
      venueAddress: venue,
      agenda: agendaItems.map((a) => '${a['start_time']}: ${a['title']}').join('\n'),
      agendaItems: agendaItems,
      registrationInstructions: regInstructions,
      registrationLink: regLink,
      bannerUrl: resolvedBanner,
      bannerFileName: rawBanner?.split('/').last,
      materials: materials,
      uploadedFileNames: fileNames,
      supportingFileIds: fileIds,
      referenceNumber: refNo.isNotEmpty ? refNo : null,
      status: status,
    );

    model.applyUserOrgFallback();
    return model;
  }

  /// Builds a prefilled model from a ProgramModel
  factory ProgramSubmissionModel.fromProgramModel(ProgramModel model) {
    return ProgramSubmissionModel.fromDetailJson({}, programModel: model);
  }

  /// Builds a prefilled model from a ProgramApplicationItem for editing & resubmitting
  factory ProgramSubmissionModel.fromProgramApplicationItem(ProgramApplicationItem item) {
    if (item.rawJson != null && item.rawJson!.isNotEmpty) {
      final fromJsonModel = ProgramSubmissionModel.fromDetailJson(item.rawJson!);
      if (item.programName.isNotEmpty) fromJsonModel.programName = item.programName;
      if (item.programType.isNotEmpty) fromJsonModel.programType = item.programType;
      if (item.organizer.isNotEmpty && item.organizer.toLowerCase() != 'you (organizer)') {
        fromJsonModel.organizingEntityName = item.organizer;
      }
      if (item.description != null && item.description!.isNotEmpty) {
        fromJsonModel.description = item.description!;
        fromJsonModel.programDescription = item.description!;
      }
      if (item.country.isNotEmpty) fromJsonModel.country = item.country;
      if (item.countryId != null) fromJsonModel.countryId = item.countryId;
      if (item.region.isNotEmpty) fromJsonModel.regionState = item.region;
      if (item.regionId != null) fromJsonModel.regionId = item.regionId;
      if (item.city.isNotEmpty) fromJsonModel.city = item.city;
      if (item.cityId != null) fromJsonModel.cityId = item.cityId;
      if (item.pincode.isNotEmpty) fromJsonModel.pincode = item.pincode;
      if (item.venue != null && item.venue!.isNotEmpty) fromJsonModel.venueAddress = item.venue!;
      if (item.referenceNumber.isNotEmpty) fromJsonModel.referenceNumber = item.referenceNumber;
      if (item.status.isNotEmpty) fromJsonModel.status = item.status;
      if (item.banner != null && item.banner!.isNotEmpty) {
        final res = ApiConfig.resolveMediaUrl(item.banner);
        fromJsonModel.bannerUrl = res.isNotEmpty ? res : item.banner;
        fromJsonModel.bannerFileName = item.banner?.split('/').last;
      }
      fromJsonModel.applyUserOrgFallback();
      return fromJsonModel;
    }

    DateTime? parsedStart;
    try {
      parsedStart = DateTime.tryParse(item.startDate.trim());
    } catch (_) {}

    DateTime? parsedEnd;
    try {
      if (item.endDate != null && item.endDate!.trim().isNotEmpty) {
        parsedEnd = DateTime.tryParse(item.endDate!.trim());
      }
    } catch (_) {}

    final fileIds = <int>[];
    for (final m in item.materials) {
      final idVal = m['file_id'] ?? m['id'] ?? m['file']?['id'];
      if (idVal != null) {
        final parsedId = int.tryParse(idVal.toString());
        if (parsedId != null && !fileIds.contains(parsedId)) {
          fileIds.add(parsedId);
        }
      }
    }

    final fileNames = <String>[];
    for (final f in item.supportingMaterials) {
      if (f.isNotEmpty && !fileNames.contains(f)) {
        fileNames.add(f);
      }
    }
    for (final m in item.materials) {
      final name = (m['name'] ?? m['file_name'] ?? m['title'] ?? '').toString();
      if (name.isNotEmpty && !fileNames.contains(name)) {
        fileNames.add(name);
      }
    }

    final realAgenda = item.agenda.map((a) => {
      'start_time': (a['start_time'] ?? a['time'] ?? '09:00').toString(),
      'time': (a['time'] ?? a['start_time'] ?? '09:00').toString(),
      'title': (a['title'] ?? '').toString(),
    }).toList();

    final model = ProgramSubmissionModel(
      programName: item.programName,
      programType: item.programType,
      description: item.description ?? '',
      programDescription: item.description ?? '',
      organizingEntityName: item.organizer,
      contactPerson: item.contactPerson ?? '',
      phone: item.contactPhone ?? '',
      email: item.contactEmail ?? '',
      startDate: parsedStart,
      endDate: parsedEnd,
      venueAddress: item.venue ?? '',
      country: item.country,
      countryId: item.countryId,
      regionState: item.region,
      regionId: item.regionId,
      city: item.city,
      cityId: item.cityId,
      pincode: item.pincode,
      agenda: realAgenda.map((a) => '${a['start_time']}: ${a['title']}').join('\n'),
      agendaItems: realAgenda,
      bannerUrl: item.banner != null && item.banner!.isNotEmpty
          ? ApiConfig.resolveMediaUrl(item.banner)
          : null,
      bannerFileName: item.banner?.split('/').last,
      materials: item.materials,
      uploadedFileNames: fileNames,
      supportingFileIds: fileIds,
      referenceNumber: item.referenceNumber,
      status: item.status,
    );

    model.applyUserOrgFallback();
    return model;
  }

  /// True if no supporting materials or documents have been uploaded
  bool get hasMissingSupportingDocuments =>
      uploadedFileNames.isEmpty && supportingFileIds.isEmpty && materials.isEmpty;

  /// True if core data or supporting documents are missing
  bool get hasMissingDataOrDocs =>
      hasMissingSupportingDocuments ||
      programName.trim().isEmpty ||
      (description.trim().isEmpty && programDescription.trim().isEmpty) ||
      organizingEntityName.trim().isEmpty;
}
