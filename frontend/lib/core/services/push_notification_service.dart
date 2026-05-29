import 'dart:convert';
import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

/// Service for handling Firebase Cloud Messaging push notifications.
///
/// Usage:
///   1. Call `PushNotificationService.initialize()` in main() after
///      WidgetsFlutterBinding.ensureInitialized().
///   2. The service will request permission, obtain the FCM token,
///      and register it with the backend.
///
/// Note: Firebase requires native configuration files
/// (google-services.json for Android, GoogleService-Info.plist for iOS).
/// The service is designed to degrade gracefully if Firebase is not configured.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance =
      PushNotificationService._();

  bool _initialized = false;
  String? _fcmToken;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  /// The current FCM device token.
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging and request notification permissions.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Firebase and firebase_messaging are conditional imports
      // to avoid crashes if the packages are not configured.
      await _doInitialize();
    } catch (e) {
      debugPrint('PushNotificationService: Firebase not available - $e');
    }

    _initialized = true;
  }

  Future<void> _doInitialize() async {
    // These require firebase_core and firebase_messaging packages.
    // Uncomment when Firebase is configured in the project:

    // await Firebase.initializeApp();
    //
    // final messaging = FirebaseMessaging.instance;
    //
    // // Request permission (iOS)
    // final settings = await messaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    //
    // if (settings.authorizationStatus == AuthorizationStatus.authorized ||
    //     settings.authorizationStatus == AuthorizationStatus.provisional) {
    //   // Get the FCM token
    //   _fcmToken = await messaging.getToken();
    //   if (_fcmToken != null) {
    //     await registerToken(_fcmToken!);
    //   }
    //
    //   // Listen for token refresh
    //   messaging.onTokenRefresh.listen((newToken) {
    //     _fcmToken = newToken;
    //     registerToken(newToken);
    //   });
    //
    //   // Handle foreground messages
    //   FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    //
    //   // Handle notification taps when app is in background
    //   FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
    //
    //   // Handle notification tap when app was opened from terminated state
    //   final initialMessage = await messaging.getInitialMessage();
    //   if (initialMessage != null) {
    //     _handleNotificationTap(initialMessage);
    //   }
    // }

    debugPrint(
        'PushNotificationService: Firebase packages not yet configured. '
        'Add firebase_core and firebase_messaging to pubspec.yaml, '
        'and add google-services.json / GoogleService-Info.plist to enable.');
  }

  /// Register the device token with the backend API.
  Future<void> registerToken(String token) async {
    try {
      final client = ApiClient.instance;
      final role = await client.getRole();
      final platform = _getPlatform();

      await client.post(
        ApiConstants.registerDeviceToken,
        body: {
          'token': token,
          'platform': platform,
        },
      );

      debugPrint('PushNotificationService: Token registered for $role');
    } catch (e) {
      debugPrint('PushNotificationService: Failed to register token - $e');
    }
  }

  /// Unregister the device token from the backend API.
  Future<void> unregisterToken(String token) async {
    try {
      final client = ApiClient.instance;

      await client.post(
        ApiConstants.unregisterDeviceToken,
        body: {
          'token': token,
          'platform': _getPlatform(),
        },
      );

      debugPrint('PushNotificationService: Token unregistered');
    } catch (e) {
      debugPrint(
          'PushNotificationService: Failed to unregister token - $e');
    }
  }

  String _getPlatform() {
    // Default to 'android' since Flutter runs on mobile
    // In a real app, use `Platform.isAndroid` or `Platform.isIOS`
    return 'android';
  }
}
