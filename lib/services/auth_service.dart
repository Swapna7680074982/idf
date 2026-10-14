import '../models/auth_models.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'token_storage.dart';

class AuthService {
  /// 1. Signup - Start (Account & Organization)
  /// POST /api/auth/register/start
  static Future<RegisterStartResponse> registerStart({
    required String fullName,
    required String email,
    required String phoneCountryCode,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
    required String organizationName,
    int? organizationTypeId,
    int? countryId,
    int? regionId,
    int? cityId,
    String? address,
    String? contactPerson,
    String? contactEmail,
    String? contactPhoneCode,
    String? contactPhone,
  }) async {
    final body = {
      'account': {
        'full_name': fullName,
        'email': email,
        'phone_country_code': phoneCountryCode,
        'phone_number': phoneNumber,
        'password': password,
        'confirm_password': confirmPassword,
      },
      'organization': {
        'name': organizationName,
        'organization_type_id': organizationTypeId,
        'country_id': countryId,
        'region_id': regionId,
        'city_id': cityId,
        'address': address ?? '',
        'contact_person': contactPerson ?? fullName,
        'contact_email': contactEmail ?? email,
        'contact_phone_code': contactPhoneCode ?? phoneCountryCode,
        'contact_phone': contactPhone ?? phoneNumber,
      },
    };

    final response = await ApiClient.post(
      ApiConfig.registerStart,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return RegisterStartResponse.fromJson(response);
    }

    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Unexpected response from registration service',
      statusCode: 500,
    );
  }

  /// 2. Signup - Verify Email
  /// POST /api/auth/register/verify-email
  static Future<VerifyEmailResponse> verifyEmail({
    required String email,
    required String code,
  }) async {
    final body = {
      'email': email,
      'code': code,
    };

    final response = await ApiClient.post(
      ApiConfig.registerVerifyEmail,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final result = VerifyEmailResponse.fromJson(response);
      await TokenStorage.saveRegistrationToken(result.registrationToken);
      return result;
    }

    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Unexpected response from verification service',
      statusCode: 500,
    );
  }

  /// 3. Resend Code
  /// POST /api/auth/resend-code
  static Future<Map<String, dynamic>> resendCode({
    required String email,
    String purpose = 'signup',
  }) async {
    final body = {
      'email': email,
      'purpose': purpose,
    };

    final response = await ApiClient.post(
      ApiConfig.resendCode,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return {};
  }

  /// 4. Signup - Change Pending Email
  /// POST /api/auth/register/change-email
  static Future<Map<String, dynamic>> changeEmail({
    required String email,
    required String password,
    required String newEmail,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'new_email': newEmail,
    };

    final response = await ApiClient.post(
      ApiConfig.registerChangeEmail,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    return {};
  }

  /// 5. Signup - Complete (Terms & Consent)
  /// POST /api/auth/register/complete
  static Future<AuthSuccessResponse> registerComplete({
    required String registrationToken,
    required bool acceptTerms,
    required bool confirmAccuracy,
    String? deviceName,
    String? pushToken,
  }) async {
    final body = <String, dynamic>{
      'accept_terms': acceptTerms,
      'confirm_accuracy': confirmAccuracy,
      'device_name': deviceName ?? 'Mobile App',
    };
    if (pushToken != null) {
      body['push_token'] = pushToken;
    }

    final response = await ApiClient.post(
      ApiConfig.registerComplete,
      token: registrationToken,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final result = AuthSuccessResponse.fromJson(response);
      await TokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await TokenStorage.saveUser(result.user);
      return result;
    }

    throw const ApiException(
      code: 'UNEXPECTED_RESPONSE',
      message: 'Failed to complete registration',
      statusCode: 500,
    );
  }

  /// 6. Login (Mobile App)
  /// POST /api/auth/login
  static Future<AuthSuccessResponse> login({
    required String email,
    required String password,
    String? deviceName,
    String? pushToken,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
      'device_name': deviceName ?? 'Mobile App',
    };
    if (pushToken != null) {
      body['push_token'] = pushToken;
    }

    final response = await ApiClient.post(
      ApiConfig.login,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final result = AuthSuccessResponse.fromJson(response);
      await TokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await TokenStorage.saveUser(result.user);
      return result;
    }

    throw const ApiException(
      code: 'LOGIN_FAILED',
      message: 'Unable to authenticate with provided credentials',
      statusCode: 401,
    );
  }

  /// 7. Admin Login
  /// POST /api/auth/admin/login
  static Future<AuthSuccessResponse> adminLogin({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'device_name': deviceName ?? 'Portal',
    };

    final response = await ApiClient.post(
      ApiConfig.adminLogin,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final result = AuthSuccessResponse.fromJson(response);
      await TokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await TokenStorage.saveUser(result.user);
      return result;
    }

    throw const ApiException(
      code: 'ADMIN_LOGIN_FAILED',
      message: 'Admin authentication failed',
      statusCode: 401,
    );
  }

  /// 8. Refresh Token
  /// POST /api/auth/refresh
  static Future<TokenRefreshResponse> refreshToken({
    required String refreshToken,
    String? deviceName,
  }) async {
    final body = {
      'refresh_token': refreshToken,
      'device_name': deviceName ?? 'Mobile App',
    };

    final response = await ApiClient.post(
      ApiConfig.refresh,
      body: body,
      retryOn401: false,
    );

    if (response is Map<String, dynamic>) {
      final result = TokenRefreshResponse.fromJson(response);
      await TokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result;
    }

    throw const ApiException(
      code: 'REFRESH_FAILED',
      message: 'Token refresh failed',
      statusCode: 401,
    );
  }

  /// 9. Logout (Current Device)
  /// POST /api/auth/logout
  static Future<void> logout() async {
    final rToken = TokenStorage.refreshToken;
    try {
      if (rToken != null && rToken.isNotEmpty) {
        await ApiClient.post(
          ApiConfig.logout,
          body: {'refresh_token': rToken},
          retryOn401: false,
        );
      }
    } catch (_) {}
    await TokenStorage.clearAuth();
  }

  /// 10. Logout All Devices
  /// POST /api/auth/logout-all
  static Future<void> logoutAll() async {
    try {
      await ApiClient.post(
        ApiConfig.logoutAll,
        retryOn401: false,
      );
    } catch (_) {}
    await TokenStorage.clearAuth();
  }

  /// 11. Get Current Profile (Me)
  /// GET /api/auth/me
  static Future<AuthUser> getMe() async {
    final response = await ApiClient.get(ApiConfig.me);
    if (response is Map<String, dynamic>) {
      if (response['user'] != null && response['user'] is Map<String, dynamic>) {
        final user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
        await TokenStorage.saveUser(user);
        return user;
      } else if (response.containsKey('id') || response.containsKey('email')) {
        final user = AuthUser.fromJson(response);
        await TokenStorage.saveUser(user);
        return user;
      }
    }
    throw const ApiException(
      code: 'USER_NOT_FOUND',
      message: 'Failed to retrieve profile from server',
      statusCode: 404,
    );
  }

  /// 12. Change Password (Authenticated)
  /// POST /api/auth/change-password
  static Future<TokenRefreshResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    String? deviceName,
  }) async {
    final body = {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
      'device_name': deviceName ?? 'Mobile App',
    };

    final response = await ApiClient.post(
      ApiConfig.changePassword,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final result = TokenRefreshResponse.fromJson(response);
      await TokenStorage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result;
    }

    throw const ApiException(
      code: 'PASSWORD_CHANGE_FAILED',
      message: 'Failed to update password',
      statusCode: 400,
    );
  }

  /// 13. Forgot Password - Request Code
  /// POST /api/auth/forgot-password
  static Future<ForgotPasswordResponse> forgotPassword({
    required String email,
  }) async {
    final body = {'email': email};

    final response = await ApiClient.post(
      ApiConfig.forgotPassword,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return ForgotPasswordResponse.fromJson(response);
    }

    throw const ApiException(
      code: 'FORGOT_PASSWORD_FAILED',
      message: 'Failed to request password reset code',
      statusCode: 500,
    );
  }

  /// 14. Forgot Password - Verify Code
  /// POST /api/auth/verify-reset-code
  static Future<VerifyResetCodeResponse> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final body = {
      'email': email,
      'code': code,
    };

    final response = await ApiClient.post(
      ApiConfig.verifyResetCode,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final result = VerifyResetCodeResponse.fromJson(response);
      await TokenStorage.saveResetToken(result.resetToken);
      return result;
    }

    throw const ApiException(
      code: 'VERIFY_RESET_CODE_FAILED',
      message: 'Failed to verify reset code',
      statusCode: 400,
    );
  }

  /// 15. Forgot Password - Reset Password
  /// POST /api/auth/reset-password
  static Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final body = {
      'reset_token': resetToken,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };

    final response = await ApiClient.post(
      ApiConfig.resetPassword,
      body: body,
    );

    if (response is Map<String, dynamic>) {
      return response['message'] as String? ?? 'Password reset successful. Please log in.';
    }

    return 'Password reset successful. Please log in with your new password.';
  }
}
