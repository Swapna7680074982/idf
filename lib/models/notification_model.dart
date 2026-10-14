enum NotificationType {
  changesRequired,
  programSubmitted,
  applicationSubmitted,
  aiAuditCompleted,
  programApproved,
  info,
}

class AppNotificationItem {
  final int id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  final String rawType;
  final int? programId;
  final int? applicationId;
  final int? certificateId;
  final bool isRead;
  final DateTime? createdAt;

  bool get isUnread => !isRead;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    required this.rawType,
    this.programId,
    this.applicationId,
    this.certificateId,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().toLowerCase() ?? 'info';
    NotificationType parsedType;
    if (rawType.contains('change') || rawType.contains('require')) {
      parsedType = NotificationType.changesRequired;
    } else if (rawType.contains('application') || rawType.contains('submit')) {
      parsedType = NotificationType.applicationSubmitted;
    } else if (rawType.contains('program') && rawType.contains('submit')) {
      parsedType = NotificationType.programSubmitted;
    } else if (rawType.contains('audit')) {
      parsedType = NotificationType.aiAuditCompleted;
    } else if (rawType.contains('approv') || rawType.contains('certif')) {
      parsedType = NotificationType.programApproved;
    } else {
      parsedType = NotificationType.info;
    }

    final createdAtStr = json['created_at']?.toString();
    DateTime? dt;
    if (createdAtStr != null && createdAtStr.isNotEmpty) {
      dt = DateTime.tryParse(createdAtStr);
    }

    final readVal = json['is_read'];
    final bool isRead = readVal == true || readVal == 1 || readVal == '1' || readVal == 'true';

    return AppNotificationItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timeAgo: _calculateTimeAgo(dt),
      type: parsedType,
      rawType: rawType,
      programId: json['program_id'] is int ? json['program_id'] as int : int.tryParse(json['program_id']?.toString() ?? ''),
      applicationId: json['application_id'] is int ? json['application_id'] as int : int.tryParse(json['application_id']?.toString() ?? ''),
      certificateId: json['certificate_id'] is int ? json['certificate_id'] as int : int.tryParse(json['certificate_id']?.toString() ?? ''),
      isRead: isRead,
      createdAt: dt,
    );
  }

  AppNotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    String? timeAgo,
    NotificationType? type,
    String? rawType,
    int? programId,
    int? applicationId,
    int? certificateId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      rawType: rawType ?? this.rawType,
      programId: programId ?? this.programId,
      applicationId: applicationId ?? this.applicationId,
      certificateId: certificateId ?? this.certificateId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _calculateTimeAgo(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date.toLocal());

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hrs = difference.inHours;
      return '$hrs ${hrs == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
}

class NotificationListResponse {
  final List<AppNotificationItem> items;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const NotificationListResponse({
    required this.items,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final itemsJson = data['items'] is List ? data['items'] as List : [];
    final pagination = data['pagination'] is Map<String, dynamic> ? data['pagination'] as Map<String, dynamic> : {};

    return NotificationListResponse(
      items: itemsJson
          .map((item) => AppNotificationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      unreadCount: data['unread_count'] is int
          ? data['unread_count'] as int
          : int.tryParse(data['unread_count']?.toString() ?? '0') ?? 0,
      page: pagination['page'] is int
          ? pagination['page'] as int
          : int.tryParse(pagination['page']?.toString() ?? '1') ?? 1,
      limit: pagination['limit'] is int
          ? pagination['limit'] as int
          : int.tryParse(pagination['limit']?.toString() ?? '20') ?? 20,
      total: pagination['total'] is int
          ? pagination['total'] as int
          : int.tryParse(pagination['total']?.toString() ?? '0') ?? 0,
      totalPages: pagination['total_pages'] is int
          ? pagination['total_pages'] as int
          : int.tryParse(pagination['total_pages']?.toString() ?? '1') ?? 1,
    );
  }
}
