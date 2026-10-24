import 'package:flutter/foundation.dart';
import '../models/certification_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class CertificationService {
  /// In-memory cache for categories and configs to ensure snappy UX
  static List<CertificationCategory>? _cachedCategories;
  static final Map<int, CertificationCategoryConfig> _cachedConfigs = {};

  static String get _categoriesUrl =>
      '${ApiConfig.baseUrl}/api/certification/categories';
  static String get _categoryConfigUrl =>
      '${ApiConfig.baseUrl}/api/certification/categories/config';

  /// Fetch all certification categories
  /// GET /api/certification/categories
  static Future<List<CertificationCategory>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCategories != null && _cachedCategories!.isNotEmpty) {
      return _cachedCategories!;
    }

    try {
      final response = await ApiClient.get(_categoriesUrl);
      List<dynamic>? list;

      if (response is List) {
        list = response;
      } else if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          list = response['data'] as List;
        } else if (response['categories'] is List) {
          list = response['categories'] as List;
        }
      }

      if (list != null) {
        final categories = list
            .whereType<Map<String, dynamic>>()
            .map((item) => CertificationCategory.fromJson(item))
            .toList();

        _cachedCategories = categories;
        return categories;
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] Failed to fetch categories from API: $e');
      rethrow;
    }

    return [];
  }

  /// Fetch category configuration with dynamic detail fields, sections, and evidence
  /// POST /api/certification/categories/config
  /// Body: { "id": categoryId }
  static Future<CertificationCategoryConfig> getCategoryConfig(int categoryId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedConfigs.containsKey(categoryId)) {
      return _cachedConfigs[categoryId]!;
    }

    try {
      final response = await ApiClient.post(
        _categoryConfigUrl,
        body: {'id': categoryId},
      );

      Map<String, dynamic>? dataMap;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('category') || response.containsKey('sections')) {
          dataMap = response;
        } else if (response['data'] is Map<String, dynamic>) {
          dataMap = response['data'] as Map<String, dynamic>;
        }
      }

      if (dataMap != null) {
        final config = CertificationCategoryConfig.fromJson(dataMap);
        _cachedConfigs[categoryId] = config;
        return config;
      }
    } catch (e) {
      debugPrint('⚠️ [CERTIFICATION SERVICE] Failed to fetch config for category $categoryId: $e');
      rethrow;
    }

    throw ApiException(
      code: 'INVALID_CONFIG_RESPONSE',
      message: 'Failed to load configuration for category $categoryId from server',
      statusCode: 500,
    );
  }

  /// Clear in-memory caches
  static void clearCache() {
    _cachedCategories = null;
    _cachedConfigs.clear();
  }
}
