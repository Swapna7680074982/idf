import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final int statusCode;
  final dynamic details;

  const ApiException({
    required this.code,
    required this.message,
    required this.statusCode,
    this.details,
  });

  @override
  String toString() => displayMessage;

  String get displayMessage {
    if (details is List && (details as List).isNotEmpty) {
      final first = (details as List).first;
      if (first is Map && first['message'] != null) {
        return first['message'].toString();
      }
    }
    return message;
  }
}

class ApiClient {
  static final http.Client _client = http.Client();
  static bool _isRefreshing = false;
  static void Function()? onSessionExpired;

  /// Default headers
  static Map<String, String> _buildHeaders({
    String? token,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final effectiveToken = token ?? TokenStorage.accessToken;
    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $effectiveToken';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// Print Request details
  static void _logRequest(String method, Uri uri, dynamic body, Map<String, String> headers) {
    final isCity = uri.toString().toLowerCase().contains('cit');
    if (isCity) {
      debugPrint('🏙️ >>>>>>>>>>>>>>>>>> [CITY API REQUEST] >>>>>>>>>>>>>>>>>>');
      debugPrint('--> $method ${uri.toString()}');
      debugPrint('Headers: $headers');
      if (body != null) debugPrint('Body: $body');
      debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    } else {
      debugPrint('====================== [API REQUEST] ======================');
      debugPrint('--> $method ${uri.toString()}');
      debugPrint('Headers: $headers');
      if (body != null) {
        try {
          final decoded = body is String ? jsonDecode(body) : body;
          final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
          debugPrint('Body:\n$pretty');
        } catch (_) {
          debugPrint('Body: $body');
        }
      }
      debugPrint('-----------------------------------------------------------');
    }
  }

  /// Print Response details
  static void _logResponse(http.Response response, {Uri? requestUri}) {
    final urlStr = requestUri?.toString() ?? response.request?.url.toString() ?? '';
    final isCity = urlStr.toLowerCase().contains('cit');

    if (isCity) {
      debugPrint('🏙️ <<<<<<<<<<<<<<<<<< [CITY API RESPONSE] <<<<<<<<<<<<<<<<<<');
      debugPrint('<-- Status: ${response.statusCode} | URL: $urlStr');
      debugPrint('Response Body:');
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
          debugPrint(pretty);
        } catch (_) {
          debugPrint(response.body);
        }
      } else {
        debugPrint('(empty response)');
      }
      debugPrint('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<');
    } else {
      debugPrint('====================== [API RESPONSE] =====================');
      debugPrint('<-- Status: ${response.statusCode} | URL: $urlStr');
      debugPrint('Response Body:');
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
          debugPrint(pretty);
        } catch (_) {
          debugPrint(response.body);
        }
      } else {
        debugPrint('(empty response)');
      }
      debugPrint('===========================================================');
    }
  }

  /// Generic GET request
  static Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParams,
    String? token,
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    Uri uri = Uri.parse(url);
    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      uri = uri.replace(queryParameters: stringParams);
    }

    final reqHeaders = _buildHeaders(token: token, extraHeaders: headers);
    _logRequest('GET', uri, null, reqHeaders);

    try {
      final response = await _client
          .get(
            uri,
            headers: reqHeaders,
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(
        response,
        requestUri: uri,
        retryAction: retryOn401
            ? () => get(
                  url,
                  queryParams: queryParams,
                  headers: headers,
                  retryOn401: false,
                )
            : null,
      );
    } on SocketException catch (e) {
      debugPrint('❌ [API NETWORK ERROR] Failed to connect to $uri: $e');
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to IDF server. Please check your network connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('❌ [API CLIENT ERROR] $uri: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message,
        statusCode: 0,
      );
    }
  }

  /// Generic POST request
  static Future<dynamic> post(
    String url, {
    dynamic body,
    String? token,
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    final uri = Uri.parse(url);
    final reqHeaders = _buildHeaders(token: token, extraHeaders: headers);
    _logRequest('POST', uri, body, reqHeaders);

    try {
      final response = await _client
          .post(
            uri,
            headers: reqHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(
        response,
        requestUri: uri,
        retryAction: retryOn401
            ? () => post(
                  url,
                  body: body,
                  headers: headers,
                  retryOn401: false,
                )
            : null,
      );
    } on SocketException catch (e) {
      debugPrint('❌ [API NETWORK ERROR] Failed to connect to $uri: $e');
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to IDF server. Please check your network connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('❌ [API CLIENT ERROR] $uri: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message,
        statusCode: 0,
      );
    }
  }

  /// Generic PUT request
  static Future<dynamic> put(
    String url, {
    dynamic body,
    String? token,
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    final uri = Uri.parse(url);
    final reqHeaders = _buildHeaders(token: token, extraHeaders: headers);
    _logRequest('PUT', uri, body, reqHeaders);

    try {
      final response = await _client
          .put(
            uri,
            headers: reqHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(
        response,
        requestUri: uri,
        retryAction: retryOn401
            ? () => put(
                  url,
                  body: body,
                  headers: headers,
                  retryOn401: false,
                )
            : null,
      );
    } on SocketException catch (e) {
      debugPrint('❌ [API NETWORK ERROR] Failed to connect to $uri: $e');
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to IDF server. Please check your network connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('❌ [API CLIENT ERROR] $uri: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message,
        statusCode: 0,
      );
    }
  }

  /// Generic PATCH request
  static Future<dynamic> patch(
    String url, {
    dynamic body,
    String? token,
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    final uri = Uri.parse(url);
    final reqHeaders = _buildHeaders(token: token, extraHeaders: headers);
    _logRequest('PATCH', uri, body, reqHeaders);

    try {
      final response = await _client
          .patch(
            uri,
            headers: reqHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(
        response,
        requestUri: uri,
        retryAction: retryOn401
            ? () => patch(
                  url,
                  body: body,
                  headers: headers,
                  retryOn401: false,
                )
            : null,
      );
    } on SocketException catch (e) {
      debugPrint('❌ [API NETWORK ERROR] Failed to connect to $uri: $e');
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to IDF server. Please check your network connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('❌ [API CLIENT ERROR] $uri: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message,
        statusCode: 0,
      );
    }
  }

  /// Multipart POST request (e.g., photo upload)
  static Future<dynamic> multipartPost(
    String url, {
    required String fileField,
    required File file,
    Map<String, String>? fields,
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    final effectiveToken = token ?? TokenStorage.accessToken;
    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $effectiveToken';
    }
    request.headers['Accept'] = 'application/json';
    if (headers != null) {
      request.headers.addAll(headers);
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final multipartFile = await http.MultipartFile.fromPath(fileField, file.path);
    request.files.add(multipartFile);

    debugPrint('================== [MULTIPART REQUEST] ==================');
    debugPrint('--> POST (multipart) $uri');
    debugPrint('Headers: ${request.headers}');
    debugPrint('File Field: $fileField (${file.path})');
    debugPrint('---------------------------------------------------------');

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return await _handleResponse(response, requestUri: uri);
    } on SocketException catch (e) {
      debugPrint('❌ [API NETWORK ERROR] Failed to connect to $uri: $e');
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to IDF server. Please check your network connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('❌ [API CLIENT ERROR] $uri: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message,
        statusCode: 0,
      );
    }
  }

  /// Generic DELETE request
  static Future<dynamic> delete(
    String url, {
    String? token,
    Map<String, String>? headers,
    bool retryOn401 = true,
  }) async {
    final uri = Uri.parse(url);
    final reqHeaders = _buildHeaders(token: token, extraHeaders: headers);
    _logRequest('DELETE', uri, null, reqHeaders);

    try {
      final response = await _client
          .delete(
            uri,
            headers: reqHeaders,
          )
          .timeout(const Duration(seconds: 15));

      return await _handleResponse(
        response,
        requestUri: uri,
        retryAction: retryOn401
            ? () => delete(
                  url,
                  headers: headers,
                  retryOn401: false,
                )
            : null,
      );
    } on SocketException catch (e) {
      debugPrint('❌ [API NETWORK ERROR] Failed to connect to $uri: $e');
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Unable to connect to IDF server. Please check your network connection.',
        statusCode: 0,
      );
    } on http.ClientException catch (e) {
      debugPrint('❌ [API CLIENT ERROR] $uri: $e');
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message,
        statusCode: 0,
      );
    }
  }

  /// Centralized response handler adhering to IDF standard response format
  static Future<dynamic> _handleResponse(
    http.Response response, {
    Uri? requestUri,
    Future<dynamic> Function()? retryAction,
  }) async {
    // Print response directly to stdout / debug console
    _logResponse(response, requestUri: requestUri);

    final statusCode = response.statusCode;

    // Check for 401 Unauthorized with token refresh possibility
    if (statusCode == 401 && retryAction != null && TokenStorage.refreshToken != null) {
      debugPrint('🔄 [API AUTH] 401 Unauthorized received. Attempting token rotation...');
      final refreshed = await _attemptTokenRefresh();
      if (refreshed) {
        debugPrint('✅ [API AUTH] Token refreshed successfully. Retrying original request...');
        return await retryAction();
      }
    }

    dynamic decoded;
    try {
      if (response.body.isNotEmpty) {
        decoded = jsonDecode(response.body);
      }
    } catch (_) {
      decoded = null;
    }

    // Health check returns {"status": "ok", "db": "up"}
    if (decoded is Map<String, dynamic> && decoded.containsKey('status') && !decoded.containsKey('success')) {
      if (statusCode >= 200 && statusCode < 300) {
        return decoded;
      } else {
        throw ApiException(
          code: 'HEALTH_CHECK_FAILED',
          message: decoded['status']?.toString() ?? 'Service Unavailable',
          statusCode: statusCode,
          details: decoded,
        );
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('data') && decoded['data'] != null) {
          return decoded['data'];
        }
        return decoded;
      }
      return decoded;
    }

    // Handle standard IDF error format
    // { "success": false, "error": { "code": "...", "message": "...", "details": [] } }
    if (decoded is Map<String, dynamic> && decoded['error'] is Map<String, dynamic>) {
      final errorMap = decoded['error'] as Map<String, dynamic>;
      throw ApiException(
        code: errorMap['code'] as String? ?? 'ERROR_$statusCode',
        message: errorMap['message'] as String? ?? 'An error occurred ($statusCode)',
        statusCode: statusCode,
        details: errorMap['details'],
      );
    }

    throw ApiException(
      code: 'HTTP_$statusCode',
      message: 'Request failed with status $statusCode',
      statusCode: statusCode,
      details: decoded,
    );
  }

  /// Attempts to rotate refresh token
  static Future<bool> _attemptTokenRefresh() async {
    if (_isRefreshing) return false;
    final rToken = TokenStorage.refreshToken;
    if (rToken == null || rToken.isEmpty) return false;

    _isRefreshing = true;
    try {
      final reqHeaders = {'Content-Type': 'application/json'};
      final body = {
        'refresh_token': rToken,
        'device_name': 'Mobile App',
      };
      final refreshUri = Uri.parse(ApiConfig.refresh);
      _logRequest('POST', refreshUri, body, reqHeaders);

      final response = await _client.post(
        refreshUri,
        headers: reqHeaders,
        body: jsonEncode(body),
      );

      _logResponse(response, requestUri: refreshUri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        if (data != null) {
          final newAccess = data['access_token'] as String? ?? '';
          final newRefresh = data['refresh_token'] as String? ?? '';
          if (newAccess.isNotEmpty && newRefresh.isNotEmpty) {
            await TokenStorage.saveTokens(
              accessToken: newAccess,
              refreshToken: newRefresh,
            );
            return true;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [API REFRESH ERROR] Failed to refresh token: $e');
    } finally {
      _isRefreshing = false;
    }

    // Clear auth on failed refresh to prompt re-login
    await TokenStorage.clearAuth();
    onSessionExpired?.call();
    return false;
  }
}
