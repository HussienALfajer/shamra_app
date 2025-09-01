import 'package:shamra_app/data/models/auth_res.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {
  // Login user
  Future<AuthResponseApi> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      // Save token if login successf ul
      if (response.data.token != null) {
        await StorageService.saveToken(response.data.token);
      }
      if (response.data.refreshToken != null) {
        await StorageService.saveRefreshToken(response.data.refreshToken);
      }

      // Save user data if available
      if (response.data.user != null) {
        await StorageService.saveUserData(response.data.user.toJson());
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Register user
  Future<AuthResponseApi> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final response = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      // Save token if registration successful
      if (response.data.token != null) {
        await StorageService.saveToken(response.data.token);
      }
      if (response.data.refreshToken != null) {
        await StorageService.saveRefreshToken(response.data.refreshToken);
      }

      // Save user data if available
      if (response.data.user != null) {
        await StorageService.saveUserData(response.data.user.toJson());
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final user = await AuthService.getProfile();
      // Update stored user data
      await StorageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Update profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final user = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      // Update stored user data
      await StorageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await AuthService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      // Clear local storage
      await StorageService.clearAll();
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }

  // Get current user from storage
  User? getCurrentUser() {
    final userData = StorageService.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // Get token from storage
  String? getToken() {
    return StorageService.getToken();
  }
}
