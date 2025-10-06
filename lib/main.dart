import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/dio_service.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart' hide InitialBinding;
import 'routes/app_routes.dart';
import 'core/bindings/initial_binding.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("📩 [Background] Title: ${message.notification?.title}");
  print("📩 [Background] Body: ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  await FirebaseMessaging.instance.subscribeToTopic("shamra");
  print("✅ Subscribed to topic: shamra");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print("🔔 User granted permission: ${settings.authorizationStatus}");


  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Dio service
  DioService.initialize();

  runApp(const ShamraApp());
}

class ShamraApp extends StatelessWidget {
  const ShamraApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 [OpenedApp] Notification clicked!");

    });


    return GetMaterialApp(
      title: 'Shamra Electronics',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightMode,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      initialRoute: Routes.splash,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      // Localization
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling
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
