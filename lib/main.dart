// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/dio_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart' hide InitialBinding;
import 'routes/app_routes.dart';
import 'core/bindings/initial_binding.dart';

/// Background message handler for Firebase Cloud Messaging.
/// Must be a top-level function for the @pragma annotation.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("📩 [Background Handler] Message received");
  debugPrint("📩 [Background] Title: ${message.notification?.title}");
  debugPrint("📩 [Background] Body: ${message.notification?.body}");
  debugPrint("📩 [Background] Data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize GetStorage for local persistence
  await GetStorage.init();

  // Initialize Dio service with interceptors
  DioService.initialize();

  runApp(const ShamraApp());
}

class ShamraApp extends StatefulWidget {
  const ShamraApp({super.key});

  @override
  State<ShamraApp> createState() => _ShamraAppState();
}

class _ShamraAppState extends State<ShamraApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  /// Initialize notification service and listen for notification taps.
  Future<void> _initializeNotifications() async {
    // Initialize notification service
    await NotificationService.initialize();

    // Listen to notification taps and navigate accordingly
    NotificationService.onNotificationTap.listen((RemoteMessage message) {
      debugPrint("🎯 Notification tap detected! Navigating...");
      NotificationService.navigateFromNotification(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Shamra Electronics',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightMode,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      // Localization (Arabic by default)
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling for unknown routes
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const Scaffold(
          body: Center(
            child: Text('Page Not Found', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}