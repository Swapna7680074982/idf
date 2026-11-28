import '../services/api_config.dart';
import 'program_api_models.dart';
import 'program_model.dart';

class ProgramApplicationItem {
  final String id;
  final String programName;
  final String programType;
  final String category;
  final String referenceNumber;
  final String startDate;
  final String? endDate;
  final String location;
  final String? venue;
  final String organizer;
  final String submittedDate;
  final String lastUpdatedDate;
  final String status; // 'In Review', 'Submitted', 'Approved', 'Completed', 'Draft'
  final String reviewStatus;
  final String? description;
  final String? banner;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
  final String country;
  final int? countryId;
  final String region;
  final int? regionId;
  final String city;
  final int? cityId;
  final String pincode;
  final bool editable;
  final bool canResubmit;
  final String? rejectionReason;
  final Map<String, dynamic>? rawJson;
  final List<String> supportingMaterials;
  final List<Map<String, dynamic>> materials;
  final List<Map<String, dynamic>> agenda;

  const ProgramApplicationItem({
    required this.id,
    required this.programName,
    required this.programType,
    required this.category,
    required this.referenceNumber,
    required this.startDate,
    this.endDate,
    required this.location,
    this.venue,
    required this.organizer,
    required this.submittedDate,
    required this.lastUpdatedDate,
    required this.status,
    this.reviewStatus = '',
    this.description,
    this.banner,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.country = '',
    this.countryId,
    this.region = '',
    this.regionId,
    this.city = '',
    this.cityId,
    this.pincode = '',
    this.editable = false,
    this.canResubmit = false,
    this.rejectionReason,
    this.rawJson,
    this.supportingMaterials = const [],
    this.materials = const [],
    this.agenda = const [],
  });

  /// True if the user can edit & resubmit the program application
  bool get isEditableOrResubmittable {
    if (editable || canResubmit) return true;
    final r = reviewStatus.trim().toLowerCase();
    final s = status.trim().toLowerCase();
    return r == 'changes_required' ||
        r == 'changes required' ||
        r == 'rejected' ||
        s == 'changes_required' ||
        s == 'changes required' ||
        s == 'rejected';
  }

  /// Program ID for editing or resubmitting in SubmitProgramWizardScreen
  String get editProgramId {
    final progId = rawJson?['program_id']?.toString() ?? rawJson?['program']?['id']?.toString();
    if (progId != null && progId.isNotEmpty && progId != '0' && progId != 'null') {
      return progId;
    }
    if (id.isNotEmpty && id != '0' && id != 'null') return id;
    if (referenceNumber.isNotEmpty && referenceNumber != 'null') return referenceNumber;
    return id;
  }

  factory ProgramApplicationItem.fromJson(Map<String, dynamic> json) {
    final rawMaterials = <Map<String, dynamic>>[];
    final dynamic matSource = json['materials'] ?? json['supporting_material'] ?? json['supporting_materials'];
    if (matSource is List) {
      for (final m in matSource) {
        if (m is Map) rawMaterials.add(Map<String, dynamic>.from(m));
      }
    }

    final rawAgenda = <Map<String, dynamic>>[];
    final dynamic agendaSource = json['program_agenda_schedule'] ?? json['agenda'] ?? json['schedule'];
    if (agendaSource is List) {
      for (final a in agendaSource) {
        if (a is Map) rawAgenda.add(Map<String, dynamic>.from(a));
      }
    }

    final materialNames = rawMaterials
        .map((m) => (m['name'] ?? m['file_name'] ?? 'Document').toString())
        .toList();

    final decisionStr = (json['decision'] ?? json['decision_text'] ?? '').toString().trim().toLowerCase();
    final statusStr = (json['review_status'] ?? json['current_status'] ?? json['status'] ?? json['display_status'] ?? 'Submitted').toString();
    String normalizedStatus = (decisionStr == 'rejected' || statusStr.toLowerCase() == 'rejected')
        ? 'Rejected'
        : _normalizeStatus(statusStr);

    String parsedCountry = (json['country'] ?? json['country_text'] ?? json['country_name'] ?? '').toString();
    int? parsedCountryId = json['country_id'] is int ? json['country_id'] as int : int.tryParse(json['country_id']?.toString() ?? '');
    String parsedRegion = (json['region'] ??
            json['region_state'] ??
            json['region_text'] ??
            json['region_name'] ??
            json['state'] ??
            json['state_name'] ??
            json['province'] ??
            '')
        .toString();
    int? parsedRegionId = json['region_id'] is int
        ? json['region_id'] as int
        : int.tryParse((json['region_id'] ?? json['state_id'])?.toString() ?? '');
    String parsedCity = (json['city_text'] ?? json['city_name'] ?? json['city'] ?? '').toString();
    int? parsedCityId = json['city_id'] is int ? json['city_id'] as int : int.tryParse(json['city_id']?.toString() ?? '');
    String parsedPincode = (json['pincode'] ?? json['postal_code'] ?? json['zip_code'] ?? '').toString();
    final rawLocationStr = (json['location'] ?? json['city_text'] ?? json['city'] ?? '').toString();

    // If city contains commas or country/region are empty, parse combined location parts
    if (parsedCity.contains(',') || (rawLocationStr.contains(',') && (parsedCountry.isEmpty || parsedRegion.isEmpty))) {
      final locToParse = parsedCity.contains(',') ? parsedCity : rawLocationStr;
      final parts = locToParse.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (parts.length >= 4) {
        if (parsedCity.isEmpty || parsedCity.contains(',')) parsedCity = parts[0];
        if (parsedRegion.isEmpty) parsedRegion = parts[1];
        if (parsedCountry.isEmpty) parsedCountry = parts[2];
        if (parsedPincode.isEmpty) parsedPincode = parts[3];
      } else if (parts.length == 3) {
        if (parsedCity.isEmpty || parsedCity.contains(',')) parsedCity = parts[0];
        if (parsedRegion.isEmpty) parsedRegion = parts[1];
        if (parsedCountry.isEmpty) parsedCountry = parts[2];
      } else if (parts.length == 2) {
        if (parsedCity.isEmpty || parsedCity.contains(',')) parsedCity = parts[0];
        if (parsedCountry.isEmpty) parsedCountry = parts[1];
      }
    }

    return ProgramApplicationItem(
      id: (json['id'] ?? '').toString(),
      programName: (json['title'] ?? json['program_name'] ?? '').toString(),
      programType: (json['program_type'] ?? '').toString(),
      category: (json['program_type'] ?? '').toString(),
      referenceNumber: (json['program_no'] ?? json['application_id'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: json['end_date']?.toString(),
      location: (json['city_text'] ?? json['city'] ?? json['location'] ?? '').toString(),
      venue: json['venue']?.toString(),
      organizer: (json['organizer_name'] ?? json['organizer'] ?? json['organization_entity_name'] ?? '').toString(),
      submittedDate: (json['submitted_at'] ?? json['submitted'] ?? json['registered_at'] ?? '').toString(),
      lastUpdatedDate: (json['last_updated'] ?? json['updated_at'] ?? json['registered_at'] ?? '').toString(),
      status: normalizedStatus,
      reviewStatus: (json['review_status'] ?? '').toString(),
      description: (json['description'] ?? json['about'] ?? '').toString(),
      banner: ApiConfig.resolveImageUrl(ApiConfig.extractBannerUrl(json)),
      contactPerson: json['contact_person']?.toString(),
      contactPhone: json['phone']?.toString(),
      contactEmail: json['email']?.toString(),
      country: parsedCountry,
      countryId: parsedCountryId,
      region: parsedRegion,
      regionId: parsedRegionId,
      city: parsedCity,
      cityId: parsedCityId,
      pincode: parsedPincode,
      editable: json['editable'] == true,
      canResubmit: json['can_resubmit'] == true || json['canResubmit'] == true,
      rejectionReason: (json['rejection_reason'] ?? json['reviewer_comment'] ?? json['reason'] ?? json['comment'])?.toString(),
      rawJson: json,
      supportingMaterials: materialNames,
      materials: rawMaterials,
      agenda: rawAgenda,
    );
  }

  factory ProgramApplicationItem.fromProgramApiItem(ProgramApiItem item) {
    final statusStr = (item.reviewStatus != null && item.reviewStatus!.isNotEmpty)
        ? item.reviewStatus!
        : (item.status ?? 'Submitted');
    final normalizedStatus = _normalizeStatus(statusStr);

    final loc = [item.cityText, item.countryText].where((s) => s != null && s.isNotEmpty).join(', ');

    return ProgramApplicationItem(
      id: item.id.toString(),
      programName: item.programName ?? item.title,
      programType: item.programType,
      category: item.programType,
      referenceNumber: item.programNo ?? (item.id > 0 ? item.id.toString() : ''),
      startDate: item.startDate ?? '',
      endDate: item.endDate ?? item.startDate,
      location: loc,
      country: item.countryText ?? '',
      city: item.cityText ?? '',
      organizer: item.organizerName,
      submittedDate: item.registeredAt ?? item.startDate ?? '',
      lastUpdatedDate: item.registeredAt ?? item.startDate ?? '',
      status: normalizedStatus,
      reviewStatus: item.reviewStatus ?? '',
      banner: ApiConfig.resolveImageUrl(
        ApiConfig.extractBannerUrl({
          'cover_image_url': item.coverImageUrl,
          'banner_image_url': item.bannerImageUrl,
          'banner': item.banner,
        }) ?? item.coverImageUrl ?? item.bannerImageUrl ?? item.banner,
      ),
      supportingMaterials: const [],
      materials: const [],
      agenda: const [],
    );
  }

  factory ProgramApplicationItem.fromProgramModel(ProgramModel model) {
    final statusStr = (model.reviewStatus != null && model.reviewStatus!.isNotEmpty)
        ? model.reviewStatus!
        : (model.status == ProgramStatus.completed ? 'Completed' : 'Submitted');
    final normalizedStatus = _normalizeStatus(statusStr);

    final matNames = model.materials.map((m) => m.name).toList();
    final matMaps = model.materials
        .map((m) => {'name': m.name, 'url': m.url, 'mime_type': m.mimeType})
        .toList();
    final agendaMaps = model.agenda
        .map((a) => {'start_time': a.time, 'title': a.title})
        .toList();

    return ProgramApplicationItem(
      id: model.id,
      programName: model.title,
      programType: model.tag,
      category: model.category ?? model.tag,
      referenceNumber: model.programNo ?? model.id,
      startDate: model.startDate,
      endDate: model.endDate,
      location: model.location,
      venue: model.venue,
      country: model.country,
      city: model.city,
      organizer: model.organizer,
      submittedDate: model.startDate,
      lastUpdatedDate: model.startDate,
      status: normalizedStatus,
      reviewStatus: model.reviewStatus ?? '',
      description: model.description,
      banner: model.imageUrl,
      contactPerson: model.contactInfo.contactPerson,
      contactPhone: model.contactInfo.phone,
      contactEmail: model.contactInfo.email,
      supportingMaterials: matNames,
      materials: matMaps,
      agenda: agendaMaps,
    );
  }

  static String _normalizeStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'in review' ||
        lower == 'in_review' ||
        lower == 'under_review') {
      return 'In Review';
    }
    if (lower == 'submitted') {
      return 'Submitted';
    }
    if (lower == 'manual_review' ||
        lower == 'manual review' ||
        lower == 'review') {
      return 'Manual Review';
    }
    if (lower == 'approved' || lower == 'completed' || lower == 'complete') return 'Approved';
    if (lower == 'rejected' || lower == 'cancelled' || lower == 'canceled') return 'Rejected';
    if (lower == 'changes_required' || lower == 'changes required' || lower.contains('changes')) {
      return 'Changes Required';
    }
    if (lower == 'draft') return 'Draft';
    return raw;
  }

  /// Empty list by default — no static fallback or dummy data
  static List<ProgramApplicationItem> sampleItems() => const [];
}

class CertificateApplicationItem {
  final String id;
  final String institutionName;
  final String institutionType;
  final String certificateId;
  final String applicationNo;
  final String issuedDate;
  final String expiresDate;
  final String status; // 'Active', 'Changes Required', 'Expired', 'Submitted', 'Renew Certificate'
  final String reviewStatus;
  final String displayStatus;
  final String score;
  final String emoji;
  final String? rejectionReason;
  final bool canRenew;
  final bool isExpiredStatus;
  final bool editable;
  final bool canResubmit;
  final String? certificateRecordId;
  final String? renewalApplicationId;
  final String address;
  final String region;
  final int? regionId;
  final String country;
  final int? countryId;
  final String city;
  final int? cityId;
  final String pincode;
  final Map<String, dynamic>? rawJson;

  const CertificateApplicationItem({
    required this.id,
    required this.institutionName,
    required this.institutionType,
    required this.certificateId,
    this.applicationNo = '',
    required this.issuedDate,
    required this.expiresDate,
    required this.status,
    this.reviewStatus = '',
    this.displayStatus = '',
    required this.score,
    this.emoji = '🏅',
    this.rejectionReason,
    this.canRenew = false,
    this.isExpiredStatus = false,
    this.editable = false,
    this.canResubmit = false,
    this.certificateRecordId,
    this.renewalApplicationId,
    this.address = '',
    this.region = '',
    this.regionId,
    this.country = '',
    this.countryId,
    this.city = '',
    this.cityId,
    this.pincode = '',
    this.rawJson,
  });

  /// True if the user can edit & resubmit the application
  bool get isEditableOrResubmittable {
    if (editable || canResubmit) return true;
    final r = reviewStatus.trim().toLowerCase();
    final d = displayStatus.trim().toLowerCase();
    final s = status.trim().toLowerCase();
    return r == 'changes_required' ||
        r == 'changes required' ||
        r == 'rejected' ||
        d == 'changes_required' ||
        d == 'changes required' ||
        d == 'rejected' ||
        s == 'changes_required' ||
        s == 'changes required' ||
        s == 'rejected';
  }

  /// Application identifier for editing or resubmitting in CertificationWizardScreen
  String get editApplicationId {
    if (id.isNotEmpty && id != '0' && id != 'null') return id;
    if (applicationNo.isNotEmpty && applicationNo != 'null') return applicationNo;
    return id;
  }

  /// Primary certificate identifier for the renewal endpoint /api/certification/certificates/:id/renew
  String get effectiveCertificateId {
    if (certificateRecordId != null && certificateRecordId!.isNotEmpty) {
      return certificateRecordId!;
    }
    if (int.tryParse(id) != null && int.parse(id) > 0) {
      return id;
    }
    if (int.tryParse(certificateId) != null && int.parse(certificateId) > 0) {
      return certificateId;
    }
    if (id.isNotEmpty) return id;
    if (certificateId.isNotEmpty) return certificateId;
    return applicationNo;
  }

  bool get isRenewInProgress {
    final s = status.trim().toLowerCase();
    final d = displayStatus.trim().toLowerCase();
    final r = reviewStatus.trim().toLowerCase();
    return s == 'renew in progress' ||
        s == 'renew_in_progress' ||
        d == 'renew in progress' ||
        d == 'renew_in_progress' ||
        r == 'renew in progress' ||
        r == 'renew_in_progress' ||
        (renewalApplicationId != null &&
            renewalApplicationId!.isNotEmpty &&
            renewalApplicationId != '0' &&
            renewalApplicationId != 'null');
  }

  bool get isAiAudit {
    final s = status.trim().toLowerCase();
    final d = displayStatus.trim().toLowerCase();
    final r = reviewStatus.trim().toLowerCase();
    return s == 'ai audit in progress' ||
        s == 'ai_audit_in_progress' ||
        s == 'ai_audit' ||
        s == 'ai audit' ||
        d == 'ai audit in progress' ||
        d == 'ai_audit_in_progress' ||
        d == 'ai_audit' ||
        d == 'ai audit' ||
        r == 'ai_audit' ||
        r == 'ai audit' ||
        r == 'ai audit in progress' ||
        r == 'ai_audit_in_progress';
  }

  bool get isExpiredOrRenewable {
    if (isRenewInProgress || isAiAudit) return false;
    if (canRenew || isExpiredStatus) return true;
    final s = status.trim().toLowerCase();
    final d = displayStatus.trim().toLowerCase();
    final r = reviewStatus.trim().toLowerCase();
    return s == 'expired' ||
        d == 'expired' ||
        r == 'expired' ||
        s == 'renew certificate' ||
        d == 'renew certificate' ||
        s == 'renewal' ||
        d == 'renewal' ||
        s.contains('renew') ||
        d.contains('renew');
  }

  bool get isApproved {
    if (isExpiredOrRenewable || isRenewInProgress || isAiAudit) return false;
    final s = status.trim().toLowerCase();
    final d = displayStatus.trim().toLowerCase();
    final r = reviewStatus.trim().toLowerCase();
    return s == 'approved' || s == 'certified' || s == 'active' ||
        d == 'approved' || d == 'certified' || d == 'active' ||
        r == 'approved' || r == 'certified' || r == 'active';
  }

  bool get hasCertificate {
    return certificateId.isNotEmpty && certificateId != 'null' && isApproved;
  }

  String get displayReviewStatus {
    if (isRenewInProgress) {
      return 'Renew in Progress';
    }
    if (isExpiredOrRenewable) {
      if (status.trim().toLowerCase().contains('renew') ||
          displayStatus.trim().toLowerCase().contains('renew')) {
        return 'Renewal';
      }
      return 'Expired';
    }
    if (isAiAudit) {
      return 'AI Audit In Progress';
    }
    if (displayStatus.isNotEmpty && displayStatus.toLowerCase() != 'null') {
      return formatReviewStatus(displayStatus);
    }
    if (reviewStatus.isNotEmpty) {
      return formatReviewStatus(reviewStatus);
    }
    return formatReviewStatus(status);
  }

  static String formatReviewStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'renew in progress' || lower == 'renew_in_progress') {
      return 'Renew in Progress';
    }
    if (lower == 'ai_audit' ||
        lower == 'ai audit' ||
        lower == 'ai audit in progress' ||
        lower == 'ai_audit_in_progress') {
      return 'AI Audit In Progress';
    }
    if (lower == 'manual_review' ||
        lower == 'manual review' ||
        lower == 'under_review' ||
        lower == 'in review' ||
        lower == 'in_review' ||
        lower == 'submitted') {
      return 'Manual Review';
    }
    if (lower == 'approved' || lower == 'certified' || lower == 'active') return 'Approved';
    if (lower == 'scoring') return 'Scoring';
    if (lower == 'rejected') return 'Rejected';
    if (lower == 'expired') return 'Expired';
    if (lower == 'renew certificate' || lower == 'renewal' || lower == 'renew') return 'Renewal';
    if (lower == 'changes_required' || lower == 'changes required') return 'Changes Required';
    return raw.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  factory CertificateApplicationItem.fromJson(Map<String, dynamic> json) {
    final rawCertId = json['certificate_no'] ?? json['certificate_code'] ?? json['certificate_number'] ?? json['certificate_id'];
    final certIdStr = (rawCertId != null && rawCertId.toString() != 'null') ? rawCertId.toString().trim() : '';
    final appNoStr = (json['application_no'] ?? json['application_id'] ?? json['id'] ?? '').toString().trim();
    final revStatus = (json['review_status'] ?? json['reviewStatus'] ?? json['application_status'] ?? '').toString().trim();
    final dispStatus = (json['display_status'] ?? json['displayStatus'] ?? json['current_status'] ?? '').toString().trim();
    final rawStatus = (json['status'] ?? json['application_status'] ?? 'Submitted').toString().trim();
    final reason = json['rejection_reason']?.toString() ??
        json['reason']?.toString() ??
        json['reviewer_comment']?.toString() ??
        json['comment']?.toString();
    final canRenewVal = json['can_renew'] == true ||
        (json['certificate'] is Map && (json['certificate'] as Map)['can_renew'] == true);
    final expiredVal = json['expired'] == true ||
        (json['certificate'] is Map && (json['certificate'] as Map)['expired'] == true);
    final editableVal = json['editable'] == true;
    final canResubmitVal = json['can_resubmit'] == true || json['canResubmit'] == true;

    final certMap = json['certificate'] is Map ? json['certificate'] as Map : null;
    final dynamic rawCertDbId = certMap?['id'] ??
        certMap?['certificate_id'] ??
        json['certificate_id'] ??
        json['renewal_of_certificate_id'];
    final certRecordIdStr = (rawCertDbId != null && rawCertDbId.toString() != 'null')
        ? rawCertDbId.toString().trim()
        : null;

    final rawRenewalAppId = json['renewal_application_id'];
    final renewalAppIdStr = (rawRenewalAppId != null && rawRenewalAppId.toString() != 'null')
        ? rawRenewalAppId.toString().trim()
        : null;

    final instMap = json['institution'] is Map ? json['institution'] as Map : null;
    final detailsMap = json['details'] is Map ? json['details'] as Map : null;
    final rawAddress = (json['address'] ?? instMap?['address'] ?? detailsMap?['address'] ?? '').toString();
    final rawRegion = (json['region'] ??
            json['region_text'] ??
            json['region_state'] ??
            json['region_name'] ??
            json['state'] ??
            json['state_name'] ??
            json['province'] ??
            instMap?['region'] ??
            instMap?['region_text'] ??
            instMap?['region_state'] ??
            instMap?['region_name'] ??
            instMap?['state'] ??
            instMap?['state_name'] ??
            instMap?['province'] ??
            detailsMap?['region'] ??
            detailsMap?['region_text'] ??
            detailsMap?['region_state'] ??
            detailsMap?['region_name'] ??
            detailsMap?['state'] ??
            detailsMap?['state_name'] ??
            detailsMap?['province'] ??
            '')
        .toString();
    final dynamic rawRegionId = json['region_id'] ??
        json['state_id'] ??
        instMap?['region_id'] ??
        instMap?['state_id'] ??
        detailsMap?['region_id'] ??
        detailsMap?['state_id'];
    final parsedRegionId = rawRegionId is int
        ? rawRegionId
        : int.tryParse(rawRegionId?.toString() ?? '');

    final rawCountry = (json['country'] ??
            json['country_text'] ??
            json['country_name'] ??
            instMap?['country'] ??
            instMap?['country_text'] ??
            instMap?['country_name'] ??
            detailsMap?['country'] ??
            detailsMap?['country_text'] ??
            detailsMap?['country_name'] ??
            '')
        .toString();
    final dynamic rawCountryId = json['country_id'] ??
        instMap?['country_id'] ??
        detailsMap?['country_id'];
    final parsedCountryId = rawCountryId is int
        ? rawCountryId
        : int.tryParse(rawCountryId?.toString() ?? '');

    final rawCity = (json['city'] ??
            json['city_text'] ??
            json['city_name'] ??
            instMap?['city'] ??
            instMap?['city_text'] ??
            instMap?['city_name'] ??
            detailsMap?['city'] ??
            detailsMap?['city_text'] ??
            detailsMap?['city_name'] ??
            '')
        .toString();
    final dynamic rawCityId = json['city_id'] ??
        instMap?['city_id'] ??
        detailsMap?['city_id'];
    final parsedCityId = rawCityId is int
        ? rawCityId
        : int.tryParse(rawCityId?.toString() ?? '');

    final rawPincode = (json['pincode'] ??
            json['postal_code'] ??
            json['zip_code'] ??
            instMap?['pincode'] ??
            instMap?['postal_code'] ??
            detailsMap?['pincode'] ??
            detailsMap?['postal_code'] ??
            '')
        .toString();

    final decisionStr = (json['decision'] ?? json['decision_text'] ?? '').toString().trim().toLowerCase();
    final isCertRejected = decisionStr == 'rejected' ||
        rawStatus.toLowerCase() == 'rejected' ||
        revStatus.toLowerCase() == 'rejected' ||
        dispStatus.toLowerCase() == 'rejected';

    return CertificateApplicationItem(
      id: (json['id'] ?? json['application_id'] ?? '').toString(),
      institutionName: (json['institution_name'] ?? '').toString(),
      institutionType: (json['institution_type'] ?? json['category'] ?? '').toString(),
      certificateId: certIdStr,
      applicationNo: appNoStr,
      issuedDate: (json['issued_on'] ?? json['issued_date'] ?? json['applied_at'] ?? '').toString(),
      expiresDate: (json['expires_on'] ?? json['expires_date'] ?? '').toString(),
      status: isCertRejected ? 'Rejected' : rawStatus,
      reviewStatus: isCertRejected ? 'rejected' : revStatus,
      displayStatus: isCertRejected
          ? 'Rejected'
          : (dispStatus.isNotEmpty ? dispStatus : rawStatus),
      score: (json['score'] ?? '').toString(),
      emoji: (json['emoji'] ?? '🏅').toString(),
      rejectionReason: reason,
      canRenew: canRenewVal,
      isExpiredStatus: expiredVal,
      editable: editableVal,
      canResubmit: canResubmitVal,
      certificateRecordId: certRecordIdStr,
      renewalApplicationId: renewalAppIdStr,
      address: rawAddress,
      region: rawRegion,
      regionId: parsedRegionId,
      country: rawCountry,
      countryId: parsedCountryId,
      city: rawCity,
      cityId: parsedCityId,
      pincode: rawPincode,
      rawJson: json,
    );
  }

  /// Empty list by default — no static fallback or dummy data
  static List<CertificateApplicationItem> sampleItems() => const [];
}
