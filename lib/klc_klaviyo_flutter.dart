library;

import 'package:flutter/services.dart';
import 'package:klc_klaviyo_flutter/models/index.dart';

/// Callback when APNs device token is received
typedef PushTokenCallback = void Function(String token);

/// Callback when push token registration fails on native side
typedef PushTokenErrorCallback = void Function(String error);

/// Callback when notification is tapped
typedef NotificationTappedCallback =
    void Function(Map<String, dynamic> payload);

/// Flutter Plugin for Klaviyo SDK
/// Provides integration with Klaviyo's marketing automation platform including:
/// - Profile management (email, phone, external ID)
/// - Event tracking
/// - Push notifications (iOS APNs, Android FCM)
/// - In-App Forms
/// - Rich Push (images, videos)
class KlcKlaviyoFlutter {
  static final KlcKlaviyoFlutter _instance = KlcKlaviyoFlutter();
  static KlcKlaviyoFlutter get ic => _instance;
  final MethodChannel _channel = MethodChannel(
    'com.klaviyo.flutter/klaviyo_sdk',
  );
  PushTokenCallback? _onPushTokenReceived;
  PushTokenErrorCallback? _onPushTokenRegistrationFailed;
  static NotificationTappedCallback? _onNotificationTapped;

  /// Set callback to receive push token from APNs (iOS) or FCM (Android)
  set onPushTokenReceived(PushTokenCallback? callback) {
    _onPushTokenReceived = callback;
    _setupMethodCallHandler();
  }

  /// Set callback for push token registration failures
  set onPushTokenRegistrationFailed(PushTokenErrorCallback? callback) {
    _onPushTokenRegistrationFailed = callback;
    _setupMethodCallHandler();
  }

  /// Set callback when user taps on notification
  set onNotificationTapped(NotificationTappedCallback? callback) {
    _onNotificationTapped = callback;
    _setupMethodCallHandler();
  }

  /// Setup callbacks to receive push token from native side
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPushTokenReceived':
          final token = (call.arguments as Map?)?['token'] as String?;
          if (token != null) _onPushTokenReceived?.call(token);
          break;
        case 'onPushTokenRegistrationFailed':
          final error = (call.arguments as Map?)?['error'] as String?;
          if (error != null) _onPushTokenRegistrationFailed?.call(error);
          break;
        case 'onNotificationTapped':
          if (call.arguments != null) {
            final payload = Map<String, dynamic>.from(call.arguments as Map);
            _onNotificationTapped?.call(payload);
          }
          break;
      }
    });
  }

  /// [INITIALIZATION]
  /// Initialize Klaviyo SDK with your public API key
  Future<void> initialize(String apiKey) async {
    await _channel.invokeMethod('initialize', {'apiKey': apiKey});
  }

  /// [PROFILE MANAGEMENT]
  /// Set user's email address
  Future<void> setEmail(String email) async {
    await _channel.invokeMethod('setEmail', {'email': email});
  }

  /// Set user's phone number in E.164 format (e.g., +15555551212)
  Future<void> setPhoneNumber(String phoneNumber) async {
    await _channel.invokeMethod('setPhoneNumber', {'phoneNumber': phoneNumber});
  }

  /// Set user's external ID from your system
  Future<void> setExternalId(String externalId) async {
    await _channel.invokeMethod('setExternalId', {'externalId': externalId});
  }

  /// Set complete user profile
  Future<void> setProfile(KlaviyoProfile profile) async {
    await _channel.invokeMethod('setProfile', profile.toMap());
  }

  /// Reset the current profile (call on logout)
  Future<void> resetProfile() async {
    await _channel.invokeMethod('resetProfile');
  }

  /// Get current user's email
  Future<String?> getEmail() async {
    return await _channel.invokeMethod<String>('getEmail');
  }

  /// Get current user's phone number
  Future<String?> getPhoneNumber() async {
    return await _channel.invokeMethod<String>('getPhoneNumber');
  }

  /// Get current user's external ID
  Future<String?> getExternalId() async {
    return await _channel.invokeMethod<String>('getExternalId');
  }

  /// [EVENT TRACKING]
  /// Create and track an event
  /// await KlcKlaviyoFlutter.createEvent(
  ///   KlaviyoEvent(
  ///     name: 'Added to Cart',
  ///     properties: {'product_id': '123', 'price': 29.99},
  ///     value: 29.99,
  ///   ),
  /// );
  /// ```
  Future<void> createEvent(KlaviyoEvent event) async {
    await _channel.invokeMethod('createEvent', event.toMap());
  }

  /// [PUSH NOTIFICATIONS]
  /// Request push notification permission
  /// On iOS: Requests APNs authorization
  /// On Android: Checks POST_NOTIFICATIONS permission (API 33+)
  /// Listen to [onPushTokenReceived] to get the device token.
  Future<void> requestPushPermission() async {
    await _channel.invokeMethod('requestPushPermission');
  }

  /// Get push notification permission status
  /// Returns: "not_determined", "denied", "authorized", "provisional",
  /// "ephemeral", "unavailable_simulator", "unknown"
  Future<String> getPushPermissionStatus() async {
    final status = await _channel.invokeMethod<String>(
      'getPushPermissionStatus',
    );
    return status ?? 'unknown';
  }

  /// Set push notification token manually
  Future<void> setPushToken(String token) async {
    await _channel.invokeMethod('setPushToken', {'token': token});
  }

  /// Get current push notification token
  Future<String?> getPushToken() async {
    return await _channel.invokeMethod<String>('getPushToken');
  }

  /// [IN-APP FORMS]
  /// Register for In-App Forms
  Future<void> registerForInAppForms() async {
    await _channel.invokeMethod('registerForInAppForms');
  }

  /// Unregister from In-App Forms
  Future<void> unregisterFromInAppForms() async {
    await _channel.invokeMethod('unregisterFromInAppForms');
  }
}
