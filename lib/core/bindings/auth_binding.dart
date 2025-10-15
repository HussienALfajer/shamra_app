// lib/core/bindings/auth_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
