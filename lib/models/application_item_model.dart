class ProgramApplicationItem {
  final String id;
  final String programName;
  final String programType;
  final String category;
  final String referenceNumber;
  final String startDate;
  final String location;
  final String organizer;
  final String submittedDate;
  final String lastUpdatedDate;
  final String status; // 'In Review', 'Submitted', 'Approved', 'Completed'
  final List<String> supportingMaterials;

  const ProgramApplicationItem({
    required this.id,
    required this.programName,
    required this.programType,
    required this.category,
    required this.referenceNumber,
    required this.startDate,
    required this.location,
    required this.organizer,
    required this.submittedDate,
    required this.lastUpdatedDate,
    required this.status,
    this.supportingMaterials = const ['Program flyer.pdf', 'Schedule 2026.pdf'],
  });

  static List<ProgramApplicationItem> sampleItems() {
    return const [
      ProgramApplicationItem(
        id: '1',
        programName: 'Diabetes Awareness Walk 2026',
        programType: 'Campaign',
        category: 'Campaign',
        referenceNumber: 'PRG-2026-00124',
        startDate: '14 Nov 2026',
        location: 'Nairobi, Kenya',
        organizer: 'IDF Africa Region',
        submittedDate: '18 Sep 2026',
        lastUpdatedDate: '21 Sep 2026',
        status: 'In Review',
      ),
      ProgramApplicationItem(
        id: '2',
        programName: 'Youth Fitness Drive – Lagos',
        programType: 'Activity Drive',
        category: 'Activity Drive',
        referenceNumber: 'PRG-2026-00089',
        startDate: '05 Dec 2026',
        location: 'Lagos, Nigeria',
        organizer: 'Lagos State Sports Council',
        submittedDate: '10 Sep 2026',
        lastUpdatedDate: '11 Sep 2026',
        status: 'Submitted',
      ),
      ProgramApplicationItem(
        id: '3',
        programName: 'Marathon for Health 2025',
        programType: 'Activity Drive',
        category: 'Activity Drive',
        referenceNumber: 'PRG-2025-00031',
        startDate: '12 Oct 2025',
        location: 'Bangkok, Thailand',
        organizer: 'IDF Western Pacific',
        submittedDate: '15 Jul 2025',
        lastUpdatedDate: '20 Aug 2025',
        status: 'Approved',
      ),
      ProgramApplicationItem(
        id: '4',
        programName: 'Community Cycling Campaign 2025',
        programType: 'Campaign',
        category: 'Campaign',
        referenceNumber: 'PRG-2025-00015',
        startDate: '01 Jun 2025',
        location: 'Hyderabad, India',
        organizer: 'IDF South-East Asia',
        submittedDate: '01 Jun 2025',
        lastUpdatedDate: '02 Sep 2025',
        status: 'Completed',
      ),
    ];
  }
}

class CertificateApplicationItem {
  final String id;
  final String institutionName;
  final String institutionType;
  final String certificateId;
  final String issuedDate;
  final String expiresDate;
  final String status; // 'Active', 'Changes Required', 'Expired', 'Submitted'
  final String score;
  final String emoji;

  const CertificateApplicationItem({
    required this.id,
    required this.institutionName,
    required this.institutionType,
    required this.certificateId,
    required this.issuedDate,
    required this.expiresDate,
    required this.status,
    required this.score,
    this.emoji = '🏅',
  });

  static List<CertificateApplicationItem> sampleItems() {
    return const [
      CertificateApplicationItem(
        id: '1',
        institutionName: 'ABC Healthcare Institute',
        institutionType: 'Health Facility',
        certificateId: 'IDF-ACT-2026-00125',
        issuedDate: '20 Sep 2026',
        expiresDate: '20 Sep 2028',
        status: 'Active',
        score: '8/10',
        emoji: '🏥',
      ),
      CertificateApplicationItem(
        id: '2',
        institutionName: 'Lagos State University',
        institutionType: 'College / University',
        certificateId: 'APP-CERT-2025-0018',
        issuedDate: '01 Sep 2025',
        expiresDate: '01 Sep 2027',
        status: 'Changes Required',
        score: '7/10',
        emoji: '🏫',
      ),
      CertificateApplicationItem(
        id: '3',
        institutionName: 'Green Valley Workplace',
        institutionType: 'Workplace / Worksite',
        certificateId: 'IDF-ACT-2024-00041',
        issuedDate: '15 Feb 2024',
        expiresDate: '15 Feb 2026',
        status: 'Expired',
        score: '74%',
        emoji: '🏢',
      ),
    ];
  }
}
