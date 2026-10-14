import 'package:flutter/foundation.dart';
import '../models/meta_models.dart';
import 'api_client.dart';
import 'api_config.dart';

class MetadataService {
  /// Check system and database health
  /// GET /health
  static Future<Map<String, dynamic>> checkHealth() async {
    final response = await ApiClient.get(ApiConfig.health);
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ApiException(
      code: 'INVALID_HEALTH_RESPONSE',
      message: 'Invalid health check response received from server',
      statusCode: 500,
    );
  }

  /// Get organization types for dropdowns
  /// GET /api/meta/organization-types
  static Future<List<OrganizationType>> getOrganizationTypes() async {
    final response = await ApiClient.get(ApiConfig.orgTypes);
    if (response is List) {
      return response
          .map((item) => OrganizationType.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load organization types from server',
      statusCode: 500,
    );
  }

  /// Get program types for dropdowns
  /// GET /api/meta/program-types (with fallback to /api/programs/types if needed)
  static Future<List<ProgramTypeItem>> getProgramTypes() async {
    try {
      final response = await ApiClient.get(ApiConfig.programTypes);
      if (response is List) {
        return response
            .map((item) => ProgramTypeItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      try {
        final alt = await ApiClient.get('${ApiConfig.baseUrl}/api/programs/types');
        if (alt is List) {
          return alt
              .map((item) => ProgramTypeItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
      rethrow;
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load program types from server',
      statusCode: 500,
    );
  }

  /// Get countries list
  /// GET /api/meta/countries
  static Future<List<Country>> getCountries() async {
    final response = await ApiClient.get(ApiConfig.countries);
    if (response is List) {
      return response
          .map((item) => Country.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load countries from server',
      statusCode: 500,
    );
  }

  /// Get regions by country ID
  /// GET /api/meta/regions?country_id=:id
  static Future<List<Region>> getRegions(int countryId) async {
    final response = await ApiClient.get(
      ApiConfig.regions,
      queryParams: {'country_id': countryId},
    );
    if (response is List) {
      return response
          .map((item) => Region.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load regions from server',
      statusCode: 500,
    );
  }

  /// Get cities by region ID
  /// GET /api/meta/cities?region_id=:id
  static Future<List<City>> getCities(int regionId) async {
    debugPrint('🏙️ [METADATA] Calling Cities API: ${ApiConfig.cities}?region_id=$regionId');
    final response = await ApiClient.get(
      ApiConfig.cities,
      queryParams: {'region_id': regionId},
    );
    debugPrint('🏙️ [METADATA] Cities API raw response: $response');
    if (response is List) {
      final cities = response
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList();
      debugPrint('🏙️ [METADATA] Successfully parsed ${cities.length} cities.');
      return cities;
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load cities from server',
      statusCode: 500,
    );
  }

  /// Get near / nearby cities
  /// GET /api/meta/cities/near or GET /api/meta/cities
  static Future<List<City>> getNearCities({double? lat, double? lng, int? regionId}) async {
    final params = <String, dynamic>{};
    if (lat != null) params['lat'] = lat;
    if (lng != null) params['lng'] = lng;
    if (regionId != null) params['region_id'] = regionId;

    debugPrint('🏙️ [NEAR CITY API] Calling: ${ApiConfig.cities}/near with params: $params');
    try {
      final response = await ApiClient.get(
        '${ApiConfig.cities}/near',
        queryParams: params,
      );
      debugPrint('🏙️ [NEAR CITY API] Response: $response');
      if (response is List) {
        return response
            .map((item) => City.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      final fallbackResponse = await ApiClient.get(
        ApiConfig.cities,
        queryParams: params,
      );
      debugPrint('🏙️ [NEAR CITY API] Response: $fallbackResponse');
      if (fallbackResponse is List) {
        return fallbackResponse
            .map((item) => City.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Get active legal documents (Terms of Service, Privacy Policy)
  /// GET /api/meta/legal
  static Future<List<LegalDocument>> getLegalDocuments() async {
    final response = await ApiClient.get(ApiConfig.legal);
    if (response is List) {
      return response
          .map((item) => LegalDocument.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load legal documents from server',
      statusCode: 500,
    );
  }
}
