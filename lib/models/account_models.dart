import '../services/api_config.dart';

class AccountOrganizationSummary {
  final int id;
  final String name;
  final int? organizationTypeId;
  final String organizationType;
  final int? countryId;
  final String? country;
  final int? regionId;
  final String? region;
  final int? cityId;
  final String? city;
  final String? address;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhoneCode;
  final String? contactPhone;

  const AccountOrganizationSummary({
    required this.id,
    required this.name,
    this.organizationTypeId,
    required this.organizationType,
    this.countryId,
    this.country,
    this.regionId,
    this.region,
    this.cityId,
    this.city,
    this.address,
    this.contactPerson,
    this.contactEmail,
    this.contactPhoneCode,
    this.contactPhone,
  });

  factory AccountOrganizationSummary.fromJson(Map<String, dynamic> json) {
    return AccountOrganizationSummary(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      organizationTypeId: json['organization_type_id'] is int
          ? json['organization_type_id'] as int
          : int.tryParse(json['organization_type_id']?.toString() ?? ''),
      organizationType: json['organization_type']?.toString() ?? '',
      countryId: json['country_id'] is int
          ? json['country_id'] as int
          : int.tryParse(json['country_id']?.toString() ?? ''),
      country: json['country']?.toString(),
      regionId: json['region_id'] is int
          ? json['region_id'] as int
          : int.tryParse(json['region_id']?.toString() ?? ''),
      region: json['region']?.toString() ?? json['region_name']?.toString() ?? json['state']?.toString(),
      cityId: json['city_id'] is int
          ? json['city_id'] as int
          : int.tryParse(json['city_id']?.toString() ?? ''),
      city: json['city']?.toString() ?? json['city_name']?.toString(),
      address: json['address']?.toString(),
      contactPerson: json['contact_person']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      contactPhoneCode: json['contact_phone_code']?.toString(),
      contactPhone: json['contact_phone']?.toString(),
    );
  }
}

class AccountOverviewResponse {
  final int id;
  final String fullName;
  final String email;
  final String phoneCountryCode;
  final String phoneNumber;
  final String? profileImageUrl;
  final String status;
  final AccountOrganizationSummary? organization;

  const AccountOverviewResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneCountryCode,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.status,
    this.organization,
  });

  factory AccountOverviewResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : json;
    final org = user['organization'] is Map<String, dynamic>
        ? AccountOrganizationSummary.fromJson(user['organization'] as Map<String, dynamic>)
        : null;

    return AccountOverviewResponse(
      id: user['id'] is int ? user['id'] as int : int.tryParse(user['id']?.toString() ?? '0') ?? 0,
      fullName: user['full_name']?.toString() ?? '',
      email: user['email']?.toString() ?? '',
      phoneCountryCode: user['phone_country_code']?.toString() ?? '',
      phoneNumber: user['phone_number']?.toString() ?? '',
      profileImageUrl: ApiConfig.resolveImageUrl(user['profile_image_url']?.toString()),
      status: user['status']?.toString() ?? '',
      organization: org,
    );
  }
}

class OrganizationDetails {
  final int id;
  final String name;
  final int? organizationTypeId;
  final String organizationType;
  final int? countryId;
  final String country;
  final int? regionId;
  final String? region;
  final int? cityId;
  final String? city;
  final String address;
  final String contactPerson;
  final String contactEmail;
  final String contactPhoneCode;
  final String contactPhone;

  const OrganizationDetails({
    required this.id,
    required this.name,
    this.organizationTypeId,
    required this.organizationType,
    this.countryId,
    required this.country,
    this.regionId,
    this.region,
    this.cityId,
    this.city,
    required this.address,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhoneCode,
    required this.contactPhone,
  });

  factory OrganizationDetails.fromJson(Map<String, dynamic> json) {
    final org = json['organization'] is Map<String, dynamic> ? json['organization'] as Map<String, dynamic> : json;
    return OrganizationDetails(
      id: org['id'] is int ? org['id'] as int : int.tryParse(org['id']?.toString() ?? '0') ?? 0,
      name: org['name']?.toString() ?? '',
      organizationTypeId: org['organization_type_id'] is int
          ? org['organization_type_id'] as int
          : int.tryParse(org['organization_type_id']?.toString() ?? ''),
      organizationType: org['organization_type']?.toString() ?? '',
      countryId: org['country_id'] is int
          ? org['country_id'] as int
          : int.tryParse(org['country_id']?.toString() ?? ''),
      country: org['country']?.toString() ?? '',
      regionId: org['region_id'] is int
          ? org['region_id'] as int
          : int.tryParse(org['region_id']?.toString() ?? ''),
      region: org['region']?.toString() ?? org['region_name']?.toString() ?? org['state']?.toString(),
      cityId: org['city_id'] is int
          ? org['city_id'] as int
          : int.tryParse(org['city_id']?.toString() ?? ''),
      city: org['city']?.toString() ?? org['city_name']?.toString(),
      address: org['address']?.toString() ?? '',
      contactPerson: org['contact_person']?.toString() ?? '',
      contactEmail: org['contact_email']?.toString() ?? '',
      contactPhoneCode: org['contact_phone_code']?.toString() ?? '',
      contactPhone: org['contact_phone']?.toString() ?? '',
    );
  }
}

class AccountSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool allowMarketing;

  const AccountSettings({
    required this.pushNotifications,
    required this.emailNotifications,
    required this.allowMarketing,
  });

  factory AccountSettings.fromJson(Map<String, dynamic> json) {
    final settings = json['settings'] is Map<String, dynamic> ? json['settings'] as Map<String, dynamic> : json;
    return AccountSettings(
      pushNotifications: settings['push_notifications'] == true,
      emailNotifications: settings['email_notifications'] == true,
      allowMarketing: settings['allow_marketing'] == true,
    );
  }
}
