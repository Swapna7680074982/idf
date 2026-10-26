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

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions (required for iOS and Android 13+)
      await messaging.requestPermission(
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
}
