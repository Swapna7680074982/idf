import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  static bool _localNotificationsInitialized = false;

  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications while app is active.',
    importance: Importance.high,
  );

  /// Cached Firebase (FCM) push token
  static String? get token => _token;

  /// Initializes Local Notifications for foreground notifications
  static Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized || kIsWeb) return;

    try {
      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      const DarwinInitializationSettings iosInitSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
        iOS: iosInitSettings,
      );

      await _localNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final dynamic decoded = jsonDecode(payload);
              if (decoded is Map<String, dynamic>) {
                handleNotificationNavigation(decoded);
              }
            } catch (e) {
              developer.log('Error decoding notification payload: $e', name: 'FirebaseService');
            }
          }
        },
      );

      final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
          _localNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlatform?.createNotificationChannel(_androidChannel);
      _localNotificationsInitialized = true;
      developer.log('Local notifications channel initialized', name: 'FirebaseService');
    } catch (e) {
      developer.log('Failed to initialize local notifications: $e', name: 'FirebaseService');
    }
  }

  /// Displays a heads-up notification when a push notification arrives while app is open
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      final RemoteNotification? notification = message.notification;
      final String title = notification?.title ??
          message.data['title']?.toString() ??
          'MDRF Activate';
      final String body = notification?.body ??
          message.data['body']?.toString() ??
          message.data['message']?.toString() ??
          '';

      if (notification == null && (title.isEmpty || title == 'MDRF Activate') && body.isEmpty) {
        return;
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Used for important notifications while app is active.',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotificationsPlugin.show(
        id: notification?.hashCode ?? message.hashCode,
        title: title,
        body: body,
        notificationDetails: details,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
    } catch (e) {
      developer.log('Error showing foreground notification: $e', name: 'FirebaseService');
    }
  }

  /// Initializes Firebase, retrieves the FCM token, and sets up notification listeners
  static Future<String?> initializeAndGetToken() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Register background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Initialize local notifications for foreground alerts
      await _initializeLocalNotifications();

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions (required for iOS and Android 13+)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      developer.log('Firebase permissions granted: ${settings.authorizationStatus}', name: 'FirebaseService');

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
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final RemoteNotification? notification = message.notification;
        developer.log(
          'Foreground message received: data=${message.data}, '
          'title=${notification?.title}, body=${notification?.body}',
          name: 'FirebaseService',
        );
        // On Android, show local notification banner; on iOS, setForegroundNotificationPresentationOptions handles it
        if (Platform.isAndroid) {
          await _showForegroundNotification(message);
        }
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

      // Check if app was opened via local notification
      final launchDetails = await _localNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final dynamic decoded = jsonDecode(payload);
            if (decoded is Map<String, dynamic>) {
              handleNotificationNavigation(decoded);
            }
          } catch (_) {}
        }
      }

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
}
