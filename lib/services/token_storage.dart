import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class TokenStorage {
  static const _keyAccessToken = 'idf_access_token';
  static const _keyRefreshToken = 'idf_refresh_token';
  static const _keyRegistrationToken = 'idf_registration_token';
  static const _keyResetToken = 'idf_reset_token';
  static const _keyUserData = 'idf_user_data';

  // In-memory cache for fast access
  static String? _accessToken;
  static String? _refreshToken;
  static String? _registrationToken;
  static String? _resetToken;
  static AuthUser? _currentUser;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static String? get registrationToken => _registrationToken;
  static String? get resetToken => _resetToken;
  static AuthUser? get currentUser => _currentUser;

  static bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  /// Initialize tokens and cached user from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_keyAccessToken);
      _refreshToken = prefs.getString(_keyRefreshToken);
      _registrationToken = prefs.getString(_keyRegistrationToken);
      _resetToken = prefs.getString(_keyResetToken);

      final userJson = prefs.getString(_keyUserData);
      if (userJson != null && userJson.isNotEmpty) {
        _currentUser = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      }
    } catch (_) {
      // Graceful fallback if SharedPreferences isn't available
    }
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
    } catch (_) {}
  }

  static Future<void> saveRegistrationToken(String token) async {
    _registrationToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRegistrationToken, token);
    } catch (_) {}
  }

  static Future<void> saveResetToken(String token) async {
    _resetToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyResetToken, token);
    } catch (_) {}
  }

  static Future<void> saveUser(AuthUser user) async {
    _currentUser = user;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserData, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  static Future<void> clearAuth() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRefreshToken);
      await prefs.remove(_keyUserData);
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    _accessToken = null;
    _refreshToken = null;
    _registrationToken = null;
    _resetToken = null;
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
