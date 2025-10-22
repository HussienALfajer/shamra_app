import 'package:dio/dio.dart';
import 'package:shamra_app/data/utils/phone_utils.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../models/user.dart';
import '../models/auth_res.dart';

class AuthService {
  /// Request password reset OTP.
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String phoneNumber,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      final response = await DioService.post(
        '/auth/forgot-password',
        data: {'phoneNumber': normalized},
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reset password with OTP verification.
  static Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String otp,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      await DioService.post(
        '/auth/reset-password',
        data: {
          'phoneNumber': normalized,
          'newPassword': newPassword,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify phone number with OTP (used after registration).
  static Future<AuthResponseApi> verifyPhoneNumber({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      final response = await DioService.post(
        '/auth/verify-otp',
        data: {'phoneNumber': normalized, 'otp': otp},
      );
      return AuthResponseApi.fromJson(
        Map<String, dynamic>.from(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with phone number and password.
  static Future<AuthResponseApi> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final fcmToken = await NotificationService.getToken();
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      final response = await DioService.post(
        ApiConstants.login,
        data: {
          'phoneNumber': normalized,
          'password': password,
          'fcmToken': fcmToken,
        },
      );
      return AuthResponseApi.fromJson(
        Map<String, dynamic>.from(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send OTP for registration (you already have send-otp generic).
  static Future<void> sendOtpForRegistration({
    required String phoneNumber,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      await DioService.post(
        '/auth/send-otp',
        data: {'phoneNumber': normalized},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify OTP for registration -> returns registrationToken
  static Future<String> verifyOtpForRegistration({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      final res = await DioService.post(
        '/auth/register/verify-otp',
        data: {'phoneNumber': normalized, 'otp': otp},
      );
      // Expecting { success, data: { registrationToken } }
      return (res.data?['data']?['registrationToken'] ??
              res.data?['data']?['registration_token'] ??
              '')
          as String;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register WITH registrationToken
  static Future<AuthResponseApi> register({
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String branchId,
    required String registrationToken, // <-- NEW required
  }) async {
    try {
      final fcmToken = await NotificationService.getToken();
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      final response = await DioService.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'branchId': branchId,
          'phoneNumber': normalized,
          'registrationToken': registrationToken, // <-- pass token
          'fcmToken': fcmToken,
        },
      );
      return AuthResponseApi.fromJson(
        Map<String, dynamic>.from(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Select branch for authenticated user.
  static Future<AuthResponseApi> selectBranch({
    required String branchId,
  }) async {
    try {
      final response = await DioService.post(
        ApiConstants.selectBranch,
        data: {'branchId': branchId},
      );
      return AuthResponseApi.fromJson(
        Map<String, dynamic>.from(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user profile.
  static Future<User> getProfile() async {
    try {
      final response = await DioService.get(ApiConstants.profile);
      return User.fromJson(
        Map<String, dynamic>.from(response.data['data'] ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile.
  static Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phoneNumber != null) {
        data['phoneNumber'] = PhoneUtils.normalizeToE164(phoneNumber);
      }

      final response = await DioService.patch('/users/profile', data: data);
      return User.fromJson(
        Map<String, dynamic>.from(response.data['data'] ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Change user password.
  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await DioService.patch(
        '/users/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout current user.
  static Future<void> logout() async {
    try {
      await DioService.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit merchant request.
  static Future<Map<String, dynamic>> addMerchantRequest({
    required String storeName,
    required String address,
    required String phoneNumber,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      final response = await DioService.post(
        '/merchants/request',
        data: {
          'storeName': storeName,
          'address': address,
          'phoneNumber': normalized,
        },
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Verify reset OTP without consuming (server-side check only).
  static Future<void> verifyResetOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final normalized = PhoneUtils.normalizeToE164(phoneNumber);
      await DioService.post(
        '/auth/reset-password/verify-otp',
        data: {'phoneNumber': normalized, 'otp': otp},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get current user's merchant request.
  static Future<Map<String, dynamic>?> getMyMerchantRequest() async {
    try {
      final response = await DioService.get('/merchants/my-request');
      return response.data['data'] == null
          ? null
          : Map<String, dynamic>.from(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to user-friendly messages.
  static String _handleError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is String && data.trim().isNotEmpty) return data;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error. Please check your internet connection.';
    }
  }
}
