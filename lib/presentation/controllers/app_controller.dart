import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

/// AppController
/// مسؤول عن فحص حالة تسجيل الدخول وتوجيه المستخدم للصفحة المناسبة
class AppController extends GetxController {
  final RxBool _isCheckingAuth = true.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxBool _hasBranchSelected = false.obs;

  // Getters
  bool get isCheckingAuth => _isCheckingAuth.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get hasBranchSelected => _hasBranchSelected.value;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  /// فحص حالة المصادقة وتوجيه المستخدم
  Future<void> checkAuthStatus() async {
    try {
      _isCheckingAuth.value = true;

      // تأخير قصير لعرض الـ splash
      await Future.delayed(const Duration(seconds: 2));

      // فحص إذا كان المستخدم مسجل دخول
      final token = StorageService.getToken();
      final userData = StorageService.getUserData();
      final branchId = StorageService.getBranchId();

      _isLoggedIn.value = token != null && userData != null;
      _hasBranchSelected.value = branchId != null;

      // توجيه المستخدم بناءً على حالته
      if (_isLoggedIn.value && _hasBranchSelected.value) {
        // مستخدم مسجل دخول وقد اختار فرع
        Get.offAllNamed(Routes.main);
      } else if (_isLoggedIn.value && !_hasBranchSelected.value) {
        // مستخدم مسجل دخول لكن لم يختر فرع
        Get.offAllNamed(Routes.branchSelection);
      } else {
        // مستخدم غير مسجل دخول
        Get.offAllNamed(Routes.welcome);
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // في حالة خطأ، اذهب للترحيب
      Get.offAllNamed(Routes.welcome);
    } finally {
      _isCheckingAuth.value = false;
    }
  }

  /// إعادة فحص حالة المصادقة (يمكن استدعاؤها من controllers أخرى)
  void recheckAuthStatus() {
    checkAuthStatus();
  }

  /// تسجيل خروج وإعادة توجيه
  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      _isLoggedIn.value = false;
      _hasBranchSelected.value = false;
      Get.offAllNamed(Routes.welcome);
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
