import '../services/api_config.dart';

class VerificationDetails {
  final String channel;
  final int codeLength;
  final int expiresInMinutes;
  final int resendAfterSeconds;

  const VerificationDetails({
    required this.channel,
    required this.codeLength,
    required this.expiresInMinutes,
    required this.resendAfterSeconds,
  });

  factory VerificationDetails.fromJson(Map<String, dynamic> json) {
    return VerificationDetails(
      channel: json['channel'] as String? ?? 'email',
      codeLength: json['code_length'] is int
          ? json['code_length']
          : int.tryParse('${json['code_length']}') ?? 8,
      expiresInMinutes: json['expires_in_minutes'] is int
          ? json['expires_in_minutes']
          : int.tryParse('${json['expires_in_minutes']}') ?? 10,
      resendAfterSeconds: json['resend_after_seconds'] is int
          ? json['resend_after_seconds']
          : int.tryParse('${json['resend_after_seconds']}') ?? 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'code_length': codeLength,
        'expires_in_minutes': expiresInMinutes,
        'resend_after_seconds': resendAfterSeconds,
      };
}

class RegisterStartResponse {
  final String email;
  final VerificationDetails verification;

  const RegisterStartResponse({
    required this.email,
    required this.verification,
  });

  factory RegisterStartResponse.fromJson(Map<String, dynamic> json) {
    return RegisterStartResponse(
      email: json['email'] as String? ?? '',
      verification: VerificationDetails.fromJson(
        json['verification'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class VerifyEmailResponse {
  final String registrationToken;
  final String nextStep;

  const VerifyEmailResponse({
    required this.registrationToken,
    required this.nextStep,
  });

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      registrationToken: json['registration_token'] as String? ?? '',
      nextStep: json['next_step'] as String? ?? 'terms_and_consent',
    );
  }
}

class AuthOrganization {
  final int id;
  final String name;
  final int? organizationTypeId;
  final String? organizationType;
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
  final String? memberRole;

  const AuthOrganization({
    required this.id,
    required this.name,
    this.organizationTypeId,
    this.organizationType,
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
    this.memberRole,
  });

  factory AuthOrganization.fromJson(Map<String, dynamic> json) {
    return AuthOrganization(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] as String? ?? '',
      organizationTypeId: json['organization_type_id'] is int
          ? json['organization_type_id']
          : int.tryParse('${json['organization_type_id']}'),
      organizationType: json['organization_type'] as String?,
      countryId: json['country_id'] is int
          ? json['country_id']
          : int.tryParse('${json['country_id']}'),
      country: json['country'] as String?,
      regionId: json['region_id'] is int
          ? json['region_id']
          : int.tryParse('${json['region_id']}'),
      region: json['region'] as String?,
      cityId: json['city_id'] is int
          ? json['city_id']
          : int.tryParse('${json['city_id']}'),
      city: json['city'] as String?,
      address: json['address'] as String?,
      contactPerson: json['contact_person'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhoneCode: json['contact_phone_code'] as String?,
      contactPhone: json['contact_phone'] as String?,
      memberRole: json['member_role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'organization_type_id': organizationTypeId,
        'organization_type': organizationType,
        'country_id': countryId,
        'country': country,
        'region_id': regionId,
        'region': region,
        'city_id': cityId,
        'city': city,
        'address': address,
        'contact_person': contactPerson,
        'contact_email': contactEmail,
        'contact_phone_code': contactPhoneCode,
        'contact_phone': contactPhone,
        'member_role': memberRole,
      };
}

class AuthUser {
  final int id;
  final String fullName;
  final String email;
  final String role;
  final String? phoneCountryCode;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String status;
  final AuthOrganization? organization;

  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'user',
    this.phoneCountryCode,
    this.phoneNumber,
    this.profileImageUrl,
    this.status = 'active',
    this.organization,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      phoneCountryCode: json['phone_country_code'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profileImageUrl: ApiConfig.resolveImageUrl(json['profile_image_url'] as String?),
      status: json['status'] as String? ?? 'active',
      organization: json['organization'] != null
          ? AuthOrganization.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'phone_country_code': phoneCountryCode,
        'phone_number': phoneNumber,
        'profile_image_url': profileImageUrl,
        'status': status,
        'organization': organization?.toJson(),
      };
}

class AuthSuccessResponse {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthSuccessResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthSuccessResponse.fromJson(Map<String, dynamic> json) {
    return AuthSuccessResponse(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse('${json['expires_in']}') ?? 900,
    );
  }
}

class TokenRefreshResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const TokenRefreshResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] is int
          ? json['expires_in']
          : int.tryParse('${json['expires_in']}') ?? 900,
    );
  }
}

class ForgotPasswordResponse {
  final String email;
  final VerificationDetails verification;

  const ForgotPasswordResponse({
    required this.email,
    required this.verification,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      email: json['email'] as String? ?? '',
      verification: VerificationDetails.fromJson(
        json['verification'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class VerifyResetCodeResponse {
  final String resetToken;
  final String nextStep;

  const VerifyResetCodeResponse({
    required this.resetToken,
    required this.nextStep,
  });

  factory VerifyResetCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResetCodeResponse(
      resetToken: json['reset_token'] as String? ?? '',
      nextStep: json['next_step'] as String? ?? 'new_password',
    );
  }
}
