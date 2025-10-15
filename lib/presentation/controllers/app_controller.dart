// lib/presentation/controllers/app_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

/// AppController:
/// - Checks auth/branch status on startup.
/// - Routes the user accordingly.
class AppController extends GetxController {
  final RxBool _isCheckingAuth = true.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _hasBranchSelected = false.obs;

  bool get isCheckingAuth => _isCheckingAuth.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get hasBranchSelected => _hasBranchSelected.value;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      _isCheckingAuth.value = true;

      // Small delay to keep splash visible a bit.
      await Future.delayed(const Duration(seconds: 2));

      final token = StorageService.getToken();
      final userData = StorageService.getUserData();
      final branchId = StorageService.getBranchId();

      _isLoggedIn.value = token != null && userData != null;
      _hasBranchSelected.value = branchId != null;

      if (_isLoggedIn.value && _hasBranchSelected.value) {
        Get.offAllNamed(Routes.main);
      } else if (_isLoggedIn.value && !_hasBranchSelected.value) {
        Get.offAllNamed(Routes.branchSelection);
      } else {
        Get.offAllNamed(Routes.welcome);
      }
    } catch (e) {
      debugPrint('checkAuthStatus error: $e');
      Get.offAllNamed(Routes.welcome);
    } finally {
      _isCheckingAuth.value = false;
    }
  }

  void recheckAuthStatus() {
    checkAuthStatus();
  }

  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      _isLoggedIn.value = false;
      _hasBranchSelected.value = false;
      Get.offAllNamed(Routes.welcome);
    } catch (e) {
      debugPrint('logout error: $e');
    }
  }
}
