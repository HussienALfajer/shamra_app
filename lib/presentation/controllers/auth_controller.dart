import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shamra_app/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../widgets/common_widgets.dart';
import 'app_controller.dart';

/// 🔐 AuthController
/// -----------------
/// مسؤول عن:
/// - تسجيل الدخول / التسجيل.
/// - إدارة حالة المستخدم (currentUser).
/// - تحديث الملف الشخصي وتغيير كلمة المرور.
/// - اختيار الفرع (branch).
/// - التحكم في حالة التحميل (isLoading) ورسائل الخطأ.
/// - التحكم في رؤية كلمة المرور.
class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  /// ✅ Observables (قيم متغيرة تراقب من خلال GetX)
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool isPasswordVisible = false.obs;

  /// ✅ حقول الإدخال (مربوطة بـ TextField)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// ✅ Getters
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// ✅ التحقق من حالة تسجيل الدخول الحالية
  void checkLoginStatus() {
    _isLoggedIn.value = _authRepository.isLoggedIn();
    if (_isLoggedIn.value) {
      _currentUser.value = _authRepository.getCurrentUser();
    }
  }

  /// ✅ تسجيل الدخول (محدث)
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response.data.user != null) {
        _currentUser.value = User.fromJson(response.data.user.toJson());
        _isLoggedIn.value = true;

        // إشعار AppController بتحديث الحالة
        try {
          final appController = Get.find<AppController>();
          appController.recheckAuthStatus();
        } catch (e) {
          print('AppController not found: $e');
          // إذا لم يكن AppController موجود، اذهب لاختيار الفرع مباشرة
          Get.offAllNamed(Routes.branchSelection);
        }

        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم تسجيل الدخول بنجاح',
          type: SnackBarType.success,
        );

        // مسح حقول الإدخال
        emailController.clear();
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

  /// ✅ تسجيل حساب جديد (محدث)
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      if (response.data.user != null) {
        _currentUser.value = User.fromJson(response.data.user.toJson());
        _isLoggedIn.value = true;

        // إشعار AppController بتحديث الحالة
        try {
          final appController = Get.find<AppController>();
          appController.recheckAuthStatus();
        } catch (e) {
          print('AppController not found: $e');
          // إذا لم يكن AppController موجود، اذهب لاختيار الفرع مباشرة
          Get.offAllNamed(Routes.branchSelection);
        }

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

  /// ✅ جلب الملف الشخصي من السيرفر
  Future<void> getProfile() async {
    try {
      _isLoading.value = true;
      final user = await _authRepository.getProfile();
      _currentUser.value = user;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ تحديث الملف الشخصي
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

  /// ✅ تغيير كلمة المرور
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

  /// ✅ تسجيل الخروج (محدث)
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authRepository.logout();

      _currentUser.value = null;
      _isLoggedIn.value = false;
      _errorMessage.value = '';

      // استخدام AppController للخروج
      try {
        final appController = Get.find<AppController>();
        await appController.logout();
      } catch (e) {
        print('AppController not found during logout: $e');
        // إذا لم يكن AppController موجود، اذهب للترحيب مباشرة
        Get.offAllNamed(Routes.welcome);
      }

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم تسجيل الخروج بنجاح 👋',
        type: SnackBarType.success,
      );
    } catch (e) {
      _errorMessage.value = e.toString();

      // حتى لو فشل في السيرفر، امسح البيانات المحلية
      try {
        final appController = Get.find<AppController>();
        await appController.logout();
      } catch (e2) {
        await StorageService.clearAll();
        Get.offAllNamed(Routes.welcome);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ تبديل إظهار/إخفاء كلمة المرور
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// ✅ مسح رسالة الخطأ الحالية
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  /// ✅ اختيار الفرع (محدث)
  Future<bool> selectBranch(String branchId) async {
    try {
      _isLoading.value = true;
      final response = await _authRepository.selectBranch(branchId: branchId);

      if (response.data.user != null) {
        _currentUser.value = User.fromJson(response.data.user.toJson());
        await StorageService.saveUserData(_currentUser.value!.toJson());
        await StorageService.saveBranchId(branchId);

        print("✅ Branch selected: ${_currentUser.value!.selectedBranch}");

        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم اختيار الفرع بنجاح 🏬',
          type: SnackBarType.success,
        );

        // الذهاب للصفحة الرئيسية
        Get.offAllNamed(Routes.main);

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

  /// ✅ تحديث بيانات المستخدم محلياً
  void updateCurrentUser(User user) {
    _currentUser.value = user;
  }

  /// ✅ التحقق من صحة البريد الإلكتروني
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// ✅ التحقق من قوة كلمة المرور
  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// ✅ إعادة تعيين النموذج
  void resetForm() {
    emailController.clear();
    passwordController.clear();
    isPasswordVisible.value = false;
    _errorMessage.value = '';
  }

  /// ✅ التحقق من حالة المصادقة الحالية
  bool get hasValidSession {
    final token = StorageService.getToken();
    final userData = StorageService.getUserData();
    return token != null && userData != null;
  }

  /// ✅ الحصول على معرف الفرع المحفوظ
  String? get savedBranchId {
    return StorageService.getBranchId();
  }

  /// ✅ فحص ما إذا كان المستخدم قد اختار فرع
  bool get hasBranchSelected {
    return savedBranchId != null;
  }
}