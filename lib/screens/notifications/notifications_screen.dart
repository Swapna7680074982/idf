import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import 'widgets/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await NotificationService.getNotifications(page: 1, limit: 50);
      if (mounted) {
        setState(() {
          _notifications = res.items;
          _unreadCount = res.unreadCount;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    if (_isMarkingAll || _notifications.isEmpty) return;

    setState(() {
      _isMarkingAll = true;
    });

    try {
      await NotificationService.markAllAsRead();
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
          _unreadCount = 0;
          _isMarkingAll = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All notifications marked as read',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMarkingAll = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to mark all as read: $e',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(int index) async {
    final item = _notifications[index];
    if (item.isRead) return;

    // Optimistically update UI
    setState(() {
      _notifications[index] = item.copyWith(isRead: true);
      if (_unreadCount > 0) _unreadCount--;
    });

    try {
      await NotificationService.markAsRead(item.id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => n.isUnread);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (hasUnread)
            _isMarkingAll
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _markAllRead,
                    child: Text(
                      'Mark all read',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: AppColors.primaryBlue,
              child: _notifications.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_off_outlined,
                                  size: 36,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No notifications yet',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'We will notify you about updates to your programs and certification applications.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return NotificationCard(
                          notification: item,
                          onTap: () => _markAsRead(index),
                        );
                      },
                    ),
            ),
    );
  }
}
