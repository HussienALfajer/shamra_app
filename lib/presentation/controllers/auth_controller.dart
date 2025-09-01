import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  // Check if user is logged in
  void checkLoginStatus() {
    _isLoggedIn.value = _authRepository.isLoggedIn();
    if (_isLoggedIn.value) {
      _currentUser.value = _authRepository.getCurrentUser();
    }
  }

  // Login
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

        Get.snackbar(
          'Success',
          'Welcome back, ${_currentUser.value?.firstName}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      }

      return false;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Login Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Register
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

        Get.snackbar(
          'Success',
          'Account created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        return true;
      }

      return false;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Registration Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get Profile
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

  // Update Profile
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

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Update Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Change Password
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

      Get.snackbar(
        'Success',
        'Password changed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading.value = true;
      await _authRepository.logout();

      _currentUser.value = null;
      _isLoggedIn.value = false;
      _errorMessage.value = '';

      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );

      // Navigate to login page
      Get.offAllNamed('/login');
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }
}
