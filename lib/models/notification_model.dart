enum NotificationType {
  changesRequired,
  programSubmitted,
  aiAuditCompleted,
  programApproved,
  info,
}

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  final bool isUnread;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    this.isUnread = false,
  });

  AppNotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    NotificationType? type,
    bool? isUnread,
  }) {
    return AppNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  static List<AppNotificationItem> sampleNotifications() {
    return const [
      AppNotificationItem(
        id: 'notif-1',
        title: 'Changes Required',
        message:
            'Your certification application for Lagos State University requires additional evidence for the Infrastructure section.',
        timeAgo: '2 hours ago',
        type: NotificationType.changesRequired,
        isUnread: true,
      ),
      AppNotificationItem(
        id: 'notif-2',
        title: 'Program Submitted',
        message:
            'Your program "Youth Fitness Drive – Lagos" has been received and is under AI review.',
        timeAgo: '1 day ago',
        type: NotificationType.programSubmitted,
        isUnread: true,
      ),
      AppNotificationItem(
        id: 'notif-3',
        title: 'AI Audit Completed',
        message:
            'AI audit for your certification application APP-CERT-2025-0018 is complete. Manual review has started.',
        timeAgo: '3 days ago',
        type: NotificationType.aiAuditCompleted,
        isUnread: false,
      ),
      AppNotificationItem(
        id: 'notif-4',
        title: 'Program Approved',
        message:
            'Congratulations! Your program "Marathon for Health 2025" has been approved and is now live.',
        timeAgo: '1 month ago',
        type: NotificationType.programApproved,
        isUnread: false,
      ),
    ];
  }
}
