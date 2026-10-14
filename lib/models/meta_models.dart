class OrganizationType {
  final int id;
  final String name;

  const OrganizationType({
    required this.id,
    required this.name,
  });

  factory OrganizationType.fromJson(Map<String, dynamic> json) {
    return OrganizationType(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => name;
}

class Country {
  final int id;
  final String isoCode;
  final String name;
  final String phoneCode;

  const Country({
    required this.id,
    required this.isoCode,
    required this.name,
    required this.phoneCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      isoCode: json['iso_code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phoneCode: json['phone_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'iso_code': isoCode,
        'name': name,
        'phone_code': phoneCode,
      };

  @override
  String toString() => name;
}

class Region {
  final int id;
  final String name;

  const Region({
    required this.id,
    required this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => name;
}

class City {
  final int id;
  final String name;

  const City({
    required this.id,
    required this.name,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => name;
}

class LegalDocument {
  final String docType;
  final String version;
  final String content;
  final String effectiveFrom;

  const LegalDocument({
    required this.docType,
    required this.version,
    required this.content,
    required this.effectiveFrom,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      docType: json['doc_type'] as String? ?? '',
      version: json['version'] as String? ?? '',
      content: json['content'] as String? ?? '',
      effectiveFrom: json['effective_from'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'doc_type': docType,
        'version': version,
        'content': content,
        'effective_from': effectiveFrom,
      };
}

class ProgramTypeItem {
  final int id;
  final String name;

  const ProgramTypeItem({
    required this.id,
    required this.name,
  });

  factory ProgramTypeItem.fromJson(Map<String, dynamic> json) {
    return ProgramTypeItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? json['title'] as String? ?? json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => name;
}

