import 'dart:io';
import '../models/account_models.dart';
import 'api_client.dart';
import 'api_config.dart';

class AccountService {
  /// GET /api/account - Get Account Overview
  static Future<AccountOverviewResponse> getAccountOverview() async {
    final response = await ApiClient.get(ApiConfig.account);
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return AccountOverviewResponse.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load account overview.',
      statusCode: 200,
    );
  }

  /// PATCH /api/account/profile - Update Profile Details
  static Future<AccountOverviewResponse> updateProfile({
    required String fullName,
    required String phoneCountryCode,
    required String phoneNumber,
  }) async {
    final response = await ApiClient.patch(
      ApiConfig.accountProfile,
      body: {
        'full_name': fullName,
        'phone_country_code': phoneCountryCode,
        'phone_number': phoneNumber,
      },
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return AccountOverviewResponse.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to update profile.',
      statusCode: 200,
    );
  }

  /// POST /api/account/profile/photo - Upload Profile Photo
  static Future<String?> uploadProfilePhoto(File photoFile) async {
    final response = await ApiClient.multipartPost(
      ApiConfig.accountPhoto,
      fileField: 'photo',
      file: photoFile,
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return ApiConfig.resolveImageUrl(data['profile_image_url']?.toString());
    }
    return null;
  }

  /// GET /api/account/organization - Get Organization Details
  static Future<OrganizationDetails> getOrganizationDetails() async {
    final response = await ApiClient.get(ApiConfig.accountOrganization);
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return OrganizationDetails.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load organization details.',
      statusCode: 200,
    );
  }

  /// PATCH /api/account/organization - Update Organization Details
  static Future<void> updateOrganizationDetails({
    String? name,
    String? address,
    String? contactPerson,
    String? contactEmail,
    String? contactPhone,
    int? organizationTypeId,
    int? countryId,
    int? regionId,
    int? cityId,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (address != null) body['address'] = address;
    if (contactPerson != null) body['contact_person'] = contactPerson;
    if (contactEmail != null) body['contact_email'] = contactEmail;
    if (contactPhone != null) body['contact_phone'] = contactPhone;
    if (organizationTypeId != null) body['organization_type_id'] = organizationTypeId;
    if (countryId != null) body['country_id'] = countryId;
    if (regionId != null) body['region_id'] = regionId;
    if (cityId != null) body['city_id'] = cityId;

    await ApiClient.patch(
      ApiConfig.accountOrganization,
      body: body,
    );
  }

  /// GET /api/account/settings - Get Settings & Privacy Toggles
  static Future<AccountSettings> getSettings() async {
    final response = await ApiClient.get(ApiConfig.accountSettings);
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return AccountSettings.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load account settings.',
      statusCode: 200,
    );
  }

  /// PATCH /api/account/settings - Update Settings & Privacy Toggles
  static Future<AccountSettings> updateSettings({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? allowMarketing,
  }) async {
    final body = <String, dynamic>{};
    if (pushNotifications != null) body['push_notifications'] = pushNotifications;
    if (emailNotifications != null) body['email_notifications'] = emailNotifications;
    if (allowMarketing != null) body['allow_marketing'] = allowMarketing;

    final response = await ApiClient.patch(
      ApiConfig.accountSettings,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return AccountSettings.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to update settings.',
      statusCode: 200,
    );
  }
}
