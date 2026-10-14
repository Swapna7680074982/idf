import '../models/support_models.dart';
import 'api_client.dart';
import 'api_config.dart';

class SupportService {
  /// GET /api/support/issue-types - Get Support Issue Types (Public)
  static Future<List<SupportIssueType>> getIssueTypes() async {
    final response = await ApiClient.get(ApiConfig.supportIssueTypes);
    if (response is List) {
      return response
          .map((item) => SupportIssueType.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => SupportIssueType.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw const ApiException(
      code: 'INVALID_DATA',
      message: 'Failed to load support issue types.',
      statusCode: 500,
    );
  }

  /// POST /api/support/tickets - Create Support Ticket
  static Future<CreateTicketResult> createTicket({
    required int issueTypeId,
    required String message,
  }) async {
    final response = await ApiClient.post(
      ApiConfig.supportTickets,
      body: {
        'issue_type_id': issueTypeId,
        'message': message,
      },
    );

    if (response is Map<String, dynamic>) {
      return CreateTicketResult.fromJson(response);
    }

    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to submit support ticket.',
      statusCode: 500,
    );
  }
}
