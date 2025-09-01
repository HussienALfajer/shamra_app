import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/dio_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'core/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return GetMaterialApp(
      title: 'Shamra Electronics',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Navigation configuration
      initialRoute: Routes.main, // Changed to main for testing
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      // Localization (you can add this later)
      // locale: const Locale('en', 'US'),
      // fallbackLocale: const Locale('en', 'US'),

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
