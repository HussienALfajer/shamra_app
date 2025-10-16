// lib/core/bindings/initial_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/app_controller.dart';

/// Wires app-wide singletons only.
/// Route-specific controllers are provided by route bindings.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AppController>(AppController(), permanent: true);
  }
}