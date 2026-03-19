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

  // Observables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxString _registrationToken = ''.obs;

  final Rx<Map<String, dynamic>?> _merchantRequest = Rx<Map<String, dynamic>?>(
    null,
  );

  // Getters
  Rx<User?> get currentUserRx => _currentUser;

  User? get currentUser => _currentUser.value;

  bool get isLoading => _isLoading.value;

  bool get isLoggedIn => _isLoggedIn.value;

  String get errorMessage => _errorMessage.value;

  String get registrationToken => _registrationToken.value;

  Map<String, dynamic>? get merchantRequest => _merchantRequest.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
    getMerchantRequest();
  }

  /// Check if user is logged in and load current user from storage.
  void checkLoginStatus() {
    _isLoggedIn.value = _authRepository.isLoggedIn();
    _currentUser.value = _authRepository.getCurrentUser();
  }

  /// Login with phone (E.164) + password.
  /// After successful login, checks if user has a selected branch:
  /// - If yes → navigate to Main
  /// - If no → navigate to Branch Selection
  /// If [navigateOnSuccess] is false, it executes the optional [onLoginSuccess] callback and skips standard navigation.
  Future<bool> login(
      String phoneNumber, 
      String password, {
      bool navigateOnSuccess = true,
      VoidCallback? onLoginSuccess,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      _currentUser.value = User.fromJson(response.data.user.toJson());
      _isLoggedIn.value = true;

      // Save branch ID if user has selected branch
      if (_currentUser.value!.hasSelectedBranch) {
        final branchId = _currentUser.value!.selectedBranch.isNotEmpty
            ? _currentUser.value!.selectedBranch
            : _currentUser.value!.branchId;

        if (branchId.isNotEmpty) {
          await StorageService.saveBranchId(branchId);
        }
      }

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم تسجيل الدخول بنجاح',
        type: SnackBarType.success,
      );
      
      if (navigateOnSuccess) {
         // Navigate based on branch selection status
        try {
          final appController = Get.find<AppController>();
          appController.recheckAuthStatus();
        } catch (_) {
          // Fallback navigation if AppController not found
          if (_currentUser.value!.hasSelectedBranch) {
            Get.offAllNamed<void>(Routes.main);
          } else {
            Get.offAllNamed<void>(Routes.branchSelection);
          }
        }
      } else {
        if (onLoginSuccess != null) {
          onLoginSuccess();
        }
      }

      return true;
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

  Future<bool> sendOtpForRegistration(String phoneNumber) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      await _authRepository.sendOtpForRegistration(phoneNumber: phoneNumber);
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إرسال رمز التحقق',
        type: SnackBarType.success,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: e.toString(),
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> verifyOtpForRegistration({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final token = await _authRepository.verifyOtpForRegistration(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      if (token.isEmpty) throw Exception('فشل استلام رمز التسجيل');
      _registrationToken.value = token;
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

  Future<bool> registerAfterOtp({
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String branchId,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final response = await _authRepository.registerAfterOtp(
        firstName: firstName,
        lastName: lastName,
        password: password,
        phoneNumber: phoneNumber,
        branchId: branchId,
        registrationToken: _registrationToken.value,

      );
      _currentUser.value = response.data.user;
      _isLoggedIn.value = true;
      await selectBranchSilent(branchId);
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إنشاء الحساب بنجاح 🎉',
        type: SnackBarType.success,
      );
      return true;
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

  /// Verify phone number with OTP (used after registration).
  /// Note: Navigation is handled by the calling page, not here.
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

  /// Get current user profile from server.
  Future<void> getProfile() async {
    try {
      _isLoading.value = true;
      final user = await _authRepository.getProfile();
      _currentUser.value = user;
      await StorageService.saveUserData(user.toJson());
      update();
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Update user profile.
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
      await StorageService.saveUserData(user.toJson());

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

  /// Change user password.
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

  /// Logout user and clear all data.
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
        Get.offAllNamed<void>(Routes.welcome);
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
        Get.offAllNamed<void>(Routes.welcome);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Delete user account and clear all data.
  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      await _authRepository.deleteAccount();

      _currentUser.value = null;
      _isLoggedIn.value = false;
      _errorMessage.value = '';

      try {
        final appController = Get.find<AppController>();
        await appController.logout();
      } catch (_) {
        await StorageService.clearAll();
        Get.offAllNamed<void>(Routes.welcome);
      }

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم حذف الحساب بنجاح',
        type: SnackBarType.success,
      );
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل حذف الحساب: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Toggle password visibility.
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Clear error message.
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  /// Select branch silently (without navigation or snackbar).
  /// Used during registration flow.
  Future<bool> selectBranchSilent(String branchId) async {
    try {
      _isLoading.value = true;
      final response = await _authRepository.selectBranch(branchId: branchId);

      final updatedUser = User.fromJson(response.data.user.toJson());
      _currentUser.value = updatedUser;

      await StorageService.saveUserData(updatedUser.toJson());
      await StorageService.saveBranchId(branchId);

      update();
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Select branch with navigation and snackbar feedback.
  Future<bool> selectBranch(String branchId) async {
    try {
      _isLoading.value = true;
      final response = await _authRepository.selectBranch(branchId: branchId);

      final updatedUser = User.fromJson(response.data.user.toJson());
      _currentUser.value = updatedUser;

      await StorageService.saveUserData(updatedUser.toJson());
      await StorageService.saveBranchId(branchId);

      update();

      try {
        final appController = Get.find<AppController>();
        appController.recheckAuthStatus();
      } catch (_) {
        Get.offAllNamed<void>(Routes.main);
      }

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم اختيار الفرع بنجاح 🏬',
        type: SnackBarType.success,
      );
      return true;
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

  /// Get merchant request for current user.
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

  /// Request password reset OTP (forgot-password).
  Future<bool> requestPasswordReset(String phoneNumber) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      await _authRepository.requestPasswordReset(phoneNumber: phoneNumber);
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إرسال رمز التحقق إلى رقمك',
        type: SnackBarType.success,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: e.toString(),
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Reset password (consumes OTP on server).
  Future<bool> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String otp,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      await _authRepository.resetPassword(
        phoneNumber: phoneNumber,
        newPassword: newPassword,
        otp: otp,
      );
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم تغيير كلمة المرور بنجاح',
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

  /// Verify OTP specifically for reset flow (no tokens saved, no login state changes).
  Future<bool> verifyOtpForReset({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final ok = await _authRepository.verifyResetOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      if (ok) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم التحقق من الرمز ✅',
          type: SnackBarType.success,
        );
        return true;
      }
      _errorMessage.value = 'رمز التحقق غير صحيح';
      return false;
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

  /// Submit merchant request.
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

  /// Update current user object.
  void updateCurrentUser(User user) {
    _currentUser.value = user;
  }

  /// Validate password strength.
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Reset form flags (no controllers here).
  void resetForm() {
    isPasswordVisible.value = false;
    _errorMessage.value = '';
  }

  /// Check if user has valid session.
  bool get hasValidSession {
    final token = StorageService.getToken();
    final userData = StorageService.getUserData();
    return token != null && userData != null;
  }

  /// Get saved branch ID from storage.
  String? get savedBranchId => StorageService.getBranchId();

  /// Check if branch is selected.
  bool get hasBranchSelected => savedBranchId != null;

  /// Reload user data from storage.
  Future<void> reloadFromStorage() async {
    final data = StorageService.getUserData();
    if (data != null) {
      _currentUser.value = User.fromJson(data);
      update();
    }
  }
}
