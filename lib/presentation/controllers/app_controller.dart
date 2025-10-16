// lib/presentation/controllers/app_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

/// App-wide controller responsible for:
/// - Checking authentication and branch selection status on startup
/// - Routing the user to the appropriate page based on their status
/// - Handling logout across the app
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

  /// Checks auth status and navigates to the appropriate page.
  /// Flow: Splash → Welcome (if not logged in)
  ///              → Branch Selection (if logged in but no branch selected)
  ///              → Main (if logged in and branch selected)
  Future<void> checkAuthStatus() async {
    try {
      _isCheckingAuth.value = true;

      // Small delay to keep splash visible for better UX
      await Future.delayed(const Duration(seconds: 2));

      final token = StorageService.getToken();
      final userData = StorageService.getUserData();
      final branchId = StorageService.getBranchId();

      _isLoggedIn.value = token != null && userData != null;
      _hasBranchSelected.value = branchId != null;

      // Navigate based on auth status
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

  /// Re-checks auth status (useful after login/logout).
  void recheckAuthStatus() {
    checkAuthStatus();
  }

  /// Logs out the user and clears all local data.
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