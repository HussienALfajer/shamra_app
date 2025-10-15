// lib/core/services/notification_service.dart
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// FCM bootstrap with explicit streams:
/// - onNotificationTap: emits messages that opened the app (terminated/background).
/// - onForegroundMessage: emits messages received while the app is in foreground.
/// UI is handled in pages/controllers, not here.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final StreamController<RemoteMessage> _tapController =
  StreamController<RemoteMessage>.broadcast();
  static final StreamController<RemoteMessage> _foregroundController =
  StreamController<RemoteMessage>.broadcast();

  static Stream<RemoteMessage> get onNotificationTap => _tapController.stream;
  static Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundController.stream;

  /// Public initializer: requests permission, wires listeners, subscribes to topic.
  static Future<void> initialize() async {
    if (kDebugMode) debugPrint('🔔 Initializing Notification Service...');

    await _requestPermission();
    await _syncTokenAndTopic();

    // App opened from terminated state via a notification tap.
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) debugPrint('🚀 [TERMINATED] Opened by notification');
        // Delay ensures GetX is ready.
        Future.delayed(const Duration(milliseconds: 600), () {
          _tapController.add(message);
        });
      }
    });

    // App in background → user tapped a notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) debugPrint('🚀 [BACKGROUND] Opened by notification');
      _tapController.add(message);
    });

    // Notification received while app is in foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('📩 [FOREGROUND] Notification received');
        debugPrint('title=${message.notification?.title}');
        debugPrint('body=${message.notification?.body}');
        debugPrint('data=${message.data}');
      }
      _foregroundController.add(message);
    });

    if (kDebugMode) debugPrint('✅ Notification Service initialized');
  }

  /// Backward-compatible: request permission explicitly if needed by legacy code.
  static Future<void> requestPermission() => _requestPermission();

  /// Backward-compatible: expose FCM token getter (used by AuthService/Repository).
  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) debugPrint('✅ FCM Token: $token');
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Optional helper: Perform navigation based on message data using GetX.
  static void navigateFromNotification(RemoteMessage message) {
    final data = message.data;
    if (kDebugMode) {
      debugPrint('🧭 Navigation attempt with data: $data');
      debugPrint('🧭 Get context ready: ${Get.context != null}');
    }

    if (data.containsKey('orderId') && data['orderId'] != null) {
      final orderId = data['orderId'].toString();
      Get.toNamed('/order-details', arguments: orderId);
      return;
    }

    if (data.containsKey('productId') && data['productId'] != null) {
      final productId = data['productId'].toString();
      Get.toNamed('/product-details', arguments: productId);
      return;
    }

    if (data.containsKey('categoryId') && data['categoryId'] != null) {
      final categoryId = data['categoryId'].toString();
      Get.toNamed('/category-details', arguments: categoryId);
      return;
    }

    if (data.containsKey('route') && data['route'] != null) {
      final route = data['route'].toString();
      Get.toNamed(route, arguments: data);
      return;
    }

    if (kDebugMode) {
      debugPrint('⚠️ No navigation mapping found. Stay on current page.');
    }
  }

  /// Cleanup streams.
  static void dispose() {
    _tapController.close();
    _foregroundController.close();
  }

  // ========================== Internals ==========================
  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (kDebugMode) {
      debugPrint('Notification permission: ${settings.authorizationStatus}');
    }
  }

  /// Fetches/refreshes token and subscribes to topic. Internal only.
  static Future<void> _syncTokenAndTopic() async {
    try {
      final token = await _messaging.getToken();
      if (kDebugMode) debugPrint('✅ FCM Token (init): $token');

      await _messaging.subscribeToTopic('shamra');
      if (kDebugMode) debugPrint('✅ Subscribed to topic: shamra');

      _messaging.onTokenRefresh.listen((newToken) {
        if (kDebugMode) debugPrint('🔄 FCM Token refreshed: $newToken');
        // TODO: Send new token to backend if needed.
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error during FCM init: $e');
    }
  }
}
