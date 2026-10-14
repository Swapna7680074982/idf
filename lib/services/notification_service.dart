import '../models/notification_model.dart';
import 'api_client.dart';
import 'api_config.dart';

class NotificationService {
  /// GET /api/notifications - List Notifications
  static Future<NotificationListResponse> getNotifications({
    bool? unreadOnly,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (unreadOnly != null) {
      queryParams['unread_only'] = unreadOnly;
    }

    final response = await ApiClient.get(
      ApiConfig.notifications,
      queryParams: queryParams,
    );

    if (response is Map<String, dynamic>) {
      return NotificationListResponse.fromJson(response);
    }

    throw const ApiException(
      code: 'INVALID_RESPONSE',
      message: 'Failed to load notifications.',
      statusCode: 500,
    );
  }

  /// GET /api/notifications/unread-count - Get Unread Notification Count
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiClient.get(ApiConfig.notificationsUnreadCount);
      if (response is Map<String, dynamic>) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        if (data['unread_count'] is int) {
          return data['unread_count'] as int;
        }
        return int.tryParse(data['unread_count']?.toString() ?? '0') ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  /// PATCH /api/notifications/:id/read - Mark Single Notification as Read
  static Future<void> markAsRead(int id) async {
    await ApiClient.patch(
      ApiConfig.notificationRead(id),
    );
  }

  /// POST /api/notifications/read-all - Mark All Notifications as Read
  static Future<int> markAllAsRead() async {
    final response = await ApiClient.post(
      ApiConfig.notificationsReadAll,
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      if (data['updated'] is int) {
        return data['updated'] as int;
      }
      return int.tryParse(data['updated']?.toString() ?? '0') ?? 0;
    }
    return 0;
  }
}
