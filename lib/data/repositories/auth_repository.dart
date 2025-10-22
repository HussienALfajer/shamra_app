// lib/data/repositories/auth_repository.dart
import 'package:shamra_app/data/models/auth_res.dart';
import '../../core/services/notification_service.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {
  /// Request password reset OTP.
  Future<void> requestPasswordReset({required String phoneNumber}) async {
    await AuthService.requestPasswordReset(phoneNumber: phoneNumber);
  }

  /// Reset password with OTP verification.
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String otp,
  }) async {
    await AuthService.resetPassword(
      phoneNumber: phoneNumber,
      newPassword: newPassword,
      otp: otp,
    );
  }

  /// Verify phone number with OTP (used after registration).
  Future<AuthResponseApi> verifyPhoneNumber({
    required String phoneNumber,
    required String otp,
  }) async {
    final res = await AuthService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    if (res.data.token.isNotEmpty) {
      await StorageService.saveToken(res.data.token);
    }
    if (res.data.refreshToken.isNotEmpty) {
      await StorageService.saveRefreshToken(res.data.refreshToken);
    }

    await StorageService.saveUserData(res.data.user.toJson());
    return res;
  }

  /// Login with phone number and password.
  Future<AuthResponseApi> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await AuthService.login(
      phoneNumber: phoneNumber,
      password: password,
    );

    await StorageService.saveToken(response.data.token);
    await StorageService.saveRefreshToken(response.data.refreshToken);
    await StorageService.saveUserData(response.data.user.toJson());

    return response;
  }

  Future<void> sendOtpForRegistration({required String phoneNumber}) async {
    await AuthService.sendOtpForRegistration(phoneNumber: phoneNumber);
  }

  Future<String> verifyOtpForRegistration({
    required String phoneNumber,
    required String otp,
  }) async {
    return await AuthService.verifyOtpForRegistration(phoneNumber: phoneNumber, otp: otp);
  }

  Future<AuthResponseApi> registerAfterOtp({
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String branchId,
    required String registrationToken,
  }) async {
    final res = await AuthService.register(
      firstName: firstName,
      lastName: lastName,
      password: password,
      phoneNumber: phoneNumber,
      branchId: branchId,
      registrationToken: registrationToken,
    );
    await StorageService.saveToken(res.data.token);
    await StorageService.saveRefreshToken(res.data.refreshToken);
    await StorageService.saveUserData(res.data.user.toJson());
    return res;
  }

  /// Select branch for authenticated user.
  Future<AuthResponseApi> selectBranch({required String branchId}) async {
    final response = await AuthService.selectBranch(branchId: branchId);

    await StorageService.saveToken(response.data.token);
    await StorageService.saveRefreshToken(response.data.refreshToken);
    await StorageService.saveUserData(response.data.user.toJson());
    await StorageService.saveBranchId(branchId);

    await StorageService.saveBranchAuth(
      branchId,
      token: response.data.token,
      refreshToken: response.data.refreshToken,
    );

    return response;
  }

  /// Get current user profile.
  Future<User> getProfile() async {
    final user = await AuthService.getProfile();
    await StorageService.saveUserData(user.toJson());
    return user;
  }

  /// Update user profile.
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final user = await AuthService.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
    await StorageService.saveUserData(user.toJson());
    return user;
  }

  /// Change user password.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await AuthService.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  /// Verify OTP for password reset flow only (no auth state side-effects).
  Future<bool> verifyOtpForReset({
    required String phoneNumber,
    required String otp,
  }) async {
    // We call the same verify endpoint but intentionally do NOT persist tokens.
    await AuthService.verifyPhoneNumber(phoneNumber: phoneNumber, otp: otp);
    return true;
  }

  /// Verify OTP for password reset flow only (no auth state side-effects).
  Future<bool> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    await AuthService.verifyResetOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );
    return true;
  }

  /// Submit merchant request.
  Future<void> addMerchantRequest({
    required String storeName,
    required String address,
    required String phoneNumber,
  }) async {
    await AuthService.addMerchantRequest(
      address: address,
      phoneNumber: phoneNumber,
      storeName: storeName,
    );
  }

  /// Get current user's merchant request.
  Future<Map<String, dynamic>?> getMyMerchantRequest() {
    return AuthService.getMyMerchantRequest();
  }

  /// Logout current user.
  Future<void> logout() async {
    try {
      await AuthService.logout();
    } finally {
      await StorageService.clearAll();
    }
  }

  /// Check if user is logged in.
  bool isLoggedIn() => StorageService.isLoggedIn();

  /// Get current user from storage.
  User? getCurrentUser() {
    final data = StorageService.getUserData();
    return data == null ? null : User.fromJson(data);
  }

  /// Get access token from storage.
  String? getToken() => StorageService.getToken();
}
