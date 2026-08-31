import 'package:firebase_messaging/firebase_messaging.dart';
import 'api_client.dart';

/// Registers this device for real push notifications (Firebase
/// Cloud Messaging) - reaches the device even when the app is
/// closed or backgrounded, unlike NotificationService's in-app list,
/// which only refreshes when the screen is open.
class PushNotificationService {
  PushNotificationService._internal();
  static final PushNotificationService instance = PushNotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  bool _permissionRequested = false;

  /// Call after every session change (login/register) - the token
  /// itself must be re-sent to the backend every time, since a
  /// different account logging in on the same device needs this
  /// same device's token re-associated with the new user's id.
  Future<void> initialize() async {
    try {
      if (!_permissionRequested) {
        _permissionRequested = true;
        await _messaging.requestPermission(alert: true, badge: true, sound: true);
        _messaging.onTokenRefresh.listen(_registerToken);
      }

      final token = await _messaging.getToken();
      if (token != null) await _registerToken(token);
    } catch (_) {
      // Push registration failing (e.g. no Google Play Services on
      // this device) should never block the rest of the app.
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await ApiClient.instance.post('/api/users/fcm-token', body: {'fcmToken': token});
    } catch (_) {
      // Silent - the next app open (or token refresh) tries again.
    }
  }
}

/// Required top-level entry point for handling a push that arrives
/// while the app is fully closed or backgrounded.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
