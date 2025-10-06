import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Request notification permission
  static Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print("✅ Notification Permission: ${settings.authorizationStatus}");
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      print("✅ FCM Token: $token");

      // Subscribe to topic shamra
      await _messaging.subscribeToTopic("shamra");
      print("✅ Subscribed to topic: shamra");

      return token;
    } catch (e) {
      print("❌ Error getting FCM token: $e");
      return null;
    }
  }

  /// Initialize notification handlers
  static Future<void> initialize(BuildContext context) async {
    await requestPermission();
    await getToken();

    // Handle notification when app is opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationNavigation(context, message);
      }
    });

    // Handle notification when app is in background and user taps on it
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationNavigation(context, message);
    });

    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      print("📩 Foreground Notification: ${message.notification?.title}");
      // You can show a dialog or local notification here
    });
  }

  /// Handle navigation based on notification data
  static void _handleNotificationNavigation(
    BuildContext context,
    RemoteMessage message,
  ) {
    final data = message.data;
    print("🔔 Notification Data: $data");

    if (data.containsKey('productId')) {
      final productId = data['productId'];
      Navigator.pushNamed(context, '/product-details', arguments: productId);
    } else if (data.containsKey('categoryId')) {
      final categoryId = data['categoryId'];
      Navigator.pushNamed(context, '/category-details', arguments: categoryId);
    } else if (data.containsKey('orderId')) {
      final orderId = data['orderId'];
      Navigator.pushNamed(context, '/order-details', arguments: orderId);
    }
  }
}