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
  final String? description;
  final String? banner;
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;
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
    this.description,
    this.banner,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
    this.supportingMaterials = const [],
    this.materials = const [],
    this.agenda = const [],
  });

  factory ProgramApplicationItem.fromJson(Map<String, dynamic> json) {
    final rawMaterials = json['materials'] is List
        ? (json['materials'] as List).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final rawAgenda = json['agenda'] is List
        ? (json['agenda'] as List).whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];
    final materialNames = rawMaterials
        .map((m) => (m['name'] ?? m['file_name'] ?? 'Document').toString())
        .toList();

    final statusStr = (json['display_status'] ?? json['review_status'] ?? json['status'] ?? 'Submitted').toString();
    String normalizedStatus = _normalizeStatus(statusStr);

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
      description: (json['description'] ?? json['about'] ?? '').toString(),
      banner: (json['banner_image_url'] ?? json['cover_image_url'] ?? json['banner'])?.toString(),
      contactPerson: json['contact_person']?.toString(),
      contactPhone: json['phone']?.toString(),
      contactEmail: json['email']?.toString(),
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
      organizer: item.organizerName,
      submittedDate: item.registeredAt ?? item.startDate ?? '',
      lastUpdatedDate: item.registeredAt ?? item.startDate ?? '',
      status: normalizedStatus,
      banner: item.coverImageUrl ?? item.bannerImageUrl ?? item.banner,
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
      organizer: model.organizer,
      submittedDate: model.startDate,
      lastUpdatedDate: model.startDate,
      status: normalizedStatus,
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
    if (lower == 'submitted') return 'Submitted';
    if (lower == 'approved') return 'Approved';
    if (lower == 'draft') return 'Draft';
    if (lower == 'in review' || lower == 'in_review' || lower == 'review' || lower == 'manual_review') return 'In Review';
    if (lower == 'completed') return 'Completed';
    if (lower == 'changes_required' || lower == 'changes required') return 'Changes Required';
    if (lower == 'rejected') return 'Rejected';
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
  final String status; // 'Active', 'Changes Required', 'Expired', 'Submitted'
  final String reviewStatus;
  final String displayStatus;
  final String score;
  final String emoji;

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
  });

  bool get isApproved {
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
    if (reviewStatus.isNotEmpty) {
      return formatReviewStatus(reviewStatus);
    }
    return formatReviewStatus(status);
  }

  static String formatReviewStatus(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'manual_review' ||
        lower == 'manual review' ||
        lower == 'under_review' ||
        lower == 'in review' ||
        lower == 'in_review' ||
        lower == 'submitted' ||
        lower == 'ai_audit') {
      return 'Manual Review';
    }
    if (lower == 'approved' || lower == 'certified' || lower == 'active') return 'Approved';
    if (lower == 'scoring') return 'Scoring';
    if (lower == 'rejected') return 'Rejected';
    if (lower == 'expired') return 'Expired';
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
    final revStatus = (json['review_status'] ?? json['reviewStatus'] ?? '').toString().trim();
    final dispStatus = (json['display_status'] ?? json['displayStatus'] ?? '').toString().trim();
    final rawStatus = (json['status'] ?? 'Submitted').toString().trim();

    return CertificateApplicationItem(
      id: (json['id'] ?? json['application_id'] ?? '').toString(),
      institutionName: (json['institution_name'] ?? '').toString(),
      institutionType: (json['institution_type'] ?? json['category'] ?? '').toString(),
      certificateId: certIdStr,
      applicationNo: appNoStr,
      issuedDate: (json['issued_on'] ?? json['issued_date'] ?? json['applied_at'] ?? '').toString(),
      expiresDate: (json['expires_on'] ?? json['expires_date'] ?? '').toString(),
      status: rawStatus,
      reviewStatus: revStatus,
      displayStatus: dispStatus,
      score: (json['score'] ?? '').toString(),
      emoji: (json['emoji'] ?? '🏅').toString(),
    );
  }

  /// Empty list by default — no static fallback or dummy data
  static List<CertificateApplicationItem> sampleItems() => const [];
}
