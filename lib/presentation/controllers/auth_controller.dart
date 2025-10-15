import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shamra_app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/common_widgets.dart';
import 'app_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final Rx<User?> _currentUser = Rx<User?>(null);
  Rx<User?> get currentUserRx => _currentUser;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool isPasswordVisible = false.obs;

  final Rx<Map<String, dynamic>?> _merchantRequest = Rx<Map<String, dynamic>?>(null);
  Map<String, dynamic>? get merchantRequest => _merchantRequest.value;

  final passwordController = TextEditingController();

  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    getMerchantRequest();
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }

  void checkLoginStatus() {
    _isLoggedIn.value = _authRepository.isLoggedIn();
    _currentUser.value = _authRepository.getCurrentUser();
  }

  /// Login with phone (E.164) + password
  Future<bool> login(String phoneNumber, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      if (response.data.user != null) {
        _currentUser.value = User.fromJson(response.data.user.toJson());
        _isLoggedIn.value = true;

        try {
          final appController = Get.find<AppController>();
          appController.recheckAuthStatus();
        } catch (_) {
          Get.offAllNamed(Routes.branchSelection);
        }

        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم تسجيل الدخول بنجاح',
          type: SnackBarType.success,
        );

        passwordController.clear();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'خطأ أثناء تسجيل الدخول: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register without email; phoneNumber is REQUIRED
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber, // إلزامي
    required dynamic branch,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        password: password,
        phoneNumber: phoneNumber,
        branchId: branch.id,
      );

      if (response.data.user != null) {
        _currentUser.value = User.fromJson(response.data.user.toJson());
        _isLoggedIn.value = true;

        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم إنشاء الحساب بنجاح 🎉',
          type: SnackBarType.success,
        );
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل إنشاء الحساب: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }


  Future<bool> verifyPhoneWithOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final res = await _authRepository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      _currentUser.value = res.data.user;
      _isLoggedIn.value = true;

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم التحقق من الرقم بنجاح ✅',
        type: SnackBarType.success,
      );

      // ✅ توجيه مركزي بعد التحقق
      Get.offAllNamed(Routes.main);

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل التحقق: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getProfile() async {
    try {
      _isLoading.value = true;
      final user = await _authRepository.getProfile();
      _currentUser.value = user;
      update();
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final user = await _authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      _currentUser.value = user;

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم تحديث الملف الشخصي بنجاح ✅',
        type: SnackBarType.success,
      );

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل تحديث الملف الشخصي: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم تغيير كلمة المرور بنجاح 🔒',
        type: SnackBarType.success,
      );

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل تغيير كلمة المرور: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authRepository.logout();

      _currentUser.value = null;
      _isLoggedIn.value = false;
      _errorMessage.value = '';

      try {
        final appController = Get.find<AppController>();
        await appController.logout();
      } catch (_) {
        await StorageService.clearAll();
        Get.offAllNamed(Routes.welcome);
      }

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم تسجيل الخروج بنجاح 👋',
        type: SnackBarType.success,
      );
    } catch (e) {
      _errorMessage.value = e.toString();
      try {
        final appController = Get.find<AppController>();
        await appController.logout();
      } catch (_) {
        await StorageService.clearAll();
        Get.offAllNamed(Routes.welcome);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  Future<bool> selectBranchSilent(String branchId) async {
    try {
      _isLoading.value = true;
      final response = await _authRepository.selectBranch(branchId: branchId);

      if (response.data.user != null) {
        final updatedUser = User.fromJson(response.data.user.toJson());
        _currentUser.value = updatedUser;

        await StorageService.saveUserData(updatedUser.toJson());
        await StorageService.saveBranchId(branchId);

        update();
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> selectBranch(String branchId) async {
    try {
      _isLoading.value = true;
      final response = await _authRepository.selectBranch(branchId: branchId);

      if (response.data.user != null) {
        final updatedUser = User.fromJson(response.data.user.toJson());
        _currentUser.value = updatedUser;

        await StorageService.saveUserData(updatedUser.toJson());
        await StorageService.saveBranchId(branchId);

        update();

        try {
          final appController = Get.find<AppController>();
          appController.recheckAuthStatus();
        } catch (_) {
          Get.offAllNamed(Routes.main);
        }

        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم اختيار الفرع بنجاح 🏬',
          type: SnackBarType.success,
        );
        return true;
      }

      return false;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل اختيار الفرع: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> getMerchantRequest() async {
    try {
      _isLoading.value = true;
      final request = await _authRepository.getMyMerchantRequest();
      _merchantRequest.value = request;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> submitMerchantRequest({
    required String storeName,
    required String address,
    required String phoneNumber,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _authRepository.addMerchantRequest(
        storeName: storeName,
        address: address,
        phoneNumber: phoneNumber,
      );

      await getMerchantRequest();

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إرسال طلب التاجر بنجاح',
        type: SnackBarType.success,
      );

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل إرسال طلب التاجر: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void updateCurrentUser(User user) {
    _currentUser.value = user;
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  void resetForm() {
    passwordController.clear();
    isPasswordVisible.value = false;
    _errorMessage.value = '';
  }

  bool get hasValidSession {
    final token = StorageService.getToken();
    final userData = StorageService.getUserData();
    return token != null && userData != null;
  }

  String? get savedBranchId => StorageService.getBranchId();
  bool get hasBranchSelected => savedBranchId != null;

  Future<void> reloadFromStorage() async {
    final data = StorageService.getUserData();
    if (data != null) {
      _currentUser.value = User.fromJson(data);
      update();
    }
  }
}
