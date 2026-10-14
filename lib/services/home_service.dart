import '../models/home_models.dart';
import 'api_client.dart';
import 'api_config.dart';

class HomeService {
  /// GET /api/home - Get Home Summary
  static Future<HomeSummaryResponse> getHomeSummary() async {
    final response = await ApiClient.get(ApiConfig.home);
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return HomeSummaryResponse.fromJson(data);
    }
    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to parse home summary from server.',
      statusCode: 200,
    );
  }
}
