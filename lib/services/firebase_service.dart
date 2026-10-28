import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../models/program_model.dart';
import '../screens/certification/certification_details_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/programs/program_details_screen.dart';
import 'notification_service.dart';
import 'token_storage.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  developer.log('Background FCM message received: ${message.messageId}', name: 'FirebaseService');
}

class FirebaseService {
  static String? _token;

  /// Cached Firebase (FCM) push token
  static String? get token => _token;

  /// Initializes Firebase, retrieves the FCM token, and sets up notification listeners
  static Future<String?> initializeAndGetToken() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Register background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions (required for iOS and Android 13+)
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Enable foreground display options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Generate the Firebase FCM token
      // ignore: deprecated_member_use
      _token = await messaging.getToken();
      developer.log('Firebase Token: $_token', name: 'FirebaseService');

      // Keep token updated if refreshed by Firebase & sync with backend
      // ignore: deprecated_member_use
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _token = newToken;
        developer.log('Firebase Token Refreshed: $_token', name: 'FirebaseService');
        syncTokenWithBackend();
      });

      // Handle foreground notifications (when app is actively open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Foreground notification received: ${message.notification?.title}', name: 'FirebaseService');
        // _showForegroundNotification(message);
      });

      // Handle notification opened while app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('Notification clicked from background: ${message.data}', name: 'FirebaseService');
        handleNotificationNavigation(message.data);
      });

      // Handle notification opened that launched the app from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          developer.log('Notification launched app: ${message.data}', name: 'FirebaseService');
          handleNotificationNavigation(message.data);
        }
      });

      // If already logged in, automatically sync token with backend on launch
      if (TokenStorage.isAuthenticated) {
        syncTokenWithBackend();
      }

      return _token;
    } catch (e) {
      developer.log('Error initializing Firebase or generating token: $e', name: 'FirebaseService');
      return null;
    }
  }

  /// Sends the current FCM token to the backend API (/api/notifications/fcm-token)
  /// Called on app launch, login, or when HomeScreen opens.
  static Future<bool> syncTokenWithBackend({String? deviceName}) async {
    try {
      if (!TokenStorage.isAuthenticated) {
        developer.log('Skipping FCM sync: User not authenticated', name: 'FirebaseService');
        return false;
      }

      final currentToken = _token ??
          // ignore: deprecated_member_use
          await FirebaseMessaging.instance.getToken();

      if (currentToken == null || currentToken.isEmpty) {
        developer.log('Skipping FCM sync: Token is null or empty', name: 'FirebaseService');
        return false;
      }

      _token = currentToken;

      final defaultDeviceName = Platform.isIOS
          ? 'Apple iOS Device'
          : (Platform.isAndroid ? 'Android Mobile Device' : 'Mobile App');

      final success = await NotificationService.registerFcmToken(
        pushToken: currentToken,
        deviceName: deviceName ?? defaultDeviceName,
      );

      developer.log('FCM token synced with backend: $success', name: 'FirebaseService');
      return success;
    } catch (e) {
      developer.log('Error syncing FCM token with backend: $e', name: 'FirebaseService');
      return false;
    }
  }

  /// Handles deep link navigation when user taps a push notification
  /// Supported screens: ProgramDetail, CertificationDetail, NotificationsCenter
  static void handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final navState = rootNavigatorKey.currentState;
    if (navState == null) {
      // If navigator is not ready yet, retry after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleNotificationNavigation(data);
      });
      return;
    }

    final screen = (data['screen'] ?? data['click_action'])?.toString().trim();
    final programIdStr = (data['program_id'] ?? data['id'])?.toString().trim();
    final certIdStr = (data['application_id'] ?? data['certificate_id'] ?? data['id'])?.toString().trim();

    if (screen == 'ProgramDetail' || (programIdStr != null && programIdStr.isNotEmpty && screen != 'CertificationDetail')) {
      if (programIdStr != null && programIdStr.isNotEmpty) {
        navState.push(
          MaterialPageRoute(
            builder: (_) => ProgramDetailsScreen(
              program: ProgramModel(
                id: programIdStr,
                title: 'Program Details',
                tag: '',
                type: ProgramType.activityDrive,
                status: ProgramStatus.upcoming,
                organizer: '',
                organizationType: '',
                venue: '',
                location: '',
                country: '',
                city: '',
                startDate: '',
                endDate: '',
                description: '',
                agenda: const [],
                contactInfo: const ProgramContactInfo(
                  contactPerson: '',
                  phone: '',
                  email: '',
                ),
                gradientColors: const [0xFF004B93, 0xFF0066B2],
              ),
            ),
          ),
        );
        return;
      }
    }

    if (screen == 'CertificationDetail' && certIdStr != null && certIdStr.isNotEmpty) {
      navState.push(
        MaterialPageRoute(
          builder: (_) => CertificationDetailsScreen(applicationId: certIdStr),
        ),
      );
      return;
    }

    if (screen == 'NotificationsCenter' || screen == 'NotificationsScreen') {
      navState.push(
        MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        ),
      );
      return;
    }

    // Default: Open NotificationsCenter if screen not specifically mapped
    navState.push(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );
  }

  /*
  /// Displays an interactive top banner/snackbar when a push notification arrives while app is open
  static void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? 'New Notification';
    final body = notification?.body ?? message.data['body']?.toString() ?? message.data['message']?.toString() ?? '';

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            handleNotificationNavigation(message.data);
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Color(0xFF0284C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        action: SnackBarAction(
          label: 'OPEN',
          textColor: const Color(0xFF38BDF8),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            handleNotificationNavigation(message.data);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  */
}
