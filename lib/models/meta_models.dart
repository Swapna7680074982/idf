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

  String get flagEmoji {
    if (isoCode.length != 2) return '🌐';
    final code = isoCode.toUpperCase();
    final first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    if (first < 0x1F1E6 || first > 0x1F1FF || second < 0x1F1E6 || second > 0x1F1FF) {
      return '🌐';
    }
    return String.fromCharCode(first) + String.fromCharCode(second);
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isoCode == other.isoCode;

  @override
  int get hashCode => id.hashCode ^ isoCode.hashCode;
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
  final String? pincode;

  const City({
    required this.id,
    required this.name,
    this.pincode,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '',
      pincode: json['pincode']?.toString() ??
          json['postal_code']?.toString() ??
          json['zip_code']?.toString() ??
          json['pin_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (pincode != null) 'pincode': pincode,
      };

  @override
  String toString() => name;
}

class LegalDocument {
  final int id;
  final String docType;
  final String title;
  final String slug;
  final String version;
  final String content;
  final String contentHtml;
  final String effectiveFrom;
  final bool isActive;
  final String updatedAt;

  const LegalDocument({
    this.id = 0,
    required this.docType,
    this.title = '',
    this.slug = '',
    required this.version,
    required this.content,
    this.contentHtml = '',
    required this.effectiveFrom,
    this.isActive = true,
    this.updatedAt = '',
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      docType: json['doc_type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      version: json['version'] as String? ?? '',
      content: json['content'] as String? ?? '',
      contentHtml: json['content_html'] as String? ?? '',
      effectiveFrom: json['effective_from'] as String? ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'doc_type': docType,
        'title': title,
        'slug': slug,
        'version': version,
        'content': content,
        'content_html': contentHtml,
        'effective_from': effectiveFrom,
        'is_active': isActive ? 1 : 0,
        'updated_at': updatedAt,
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

