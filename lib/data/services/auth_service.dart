import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../models/user.dart';
import '../models/auth_res.dart';

class AuthService {
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String phoneNumber,
  }) async {
    try {
      final response = await DioService.post(
        '/auth/forgot-password', // ✅ مطابق للباك-إند
        data: {'phoneNumber': phoneNumber},
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String otp,
  }) async {
    try {
      await DioService.post(
        '/auth/reset-password', // ✅ مطابق للباك-إند
        data: {
          'phoneNumber': phoneNumber,
          'newPassword': newPassword,
          'otp': otp,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AuthResponseApi> verifyPhoneNumber({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await DioService.post(
        '/auth/verify-otp',
        data: {'phoneNumber': phoneNumber, 'otp': otp},
      );
      return AuthResponseApi.fromJson(
        Map<String, dynamic>.from(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AuthResponseApi> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final fcmToken = await NotificationService.getToken();
      final response = await DioService.post(
        ApiConstants.login,
        data: {
          'phoneNumber': phoneNumber,
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

  static Future<AuthResponseApi> register({
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
    required String branchId,
    String? fcmToken,
  }) async {
    try {
      final response = await DioService.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'branchId': branchId,
          'phoneNumber': phoneNumber,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );
      return AuthResponseApi.fromJson(
        Map<String, dynamic>.from(response.data ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<AuthResponseApi> selectBranch({required String branchId}) async {
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

  static Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await DioService.patch(
        '/users/profile',
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );
      return User.fromJson(
        Map<String, dynamic>.from(response.data['data'] ?? {}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

  static Future<void> logout() async {
    try {
      await DioService.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> addMerchantRequest({
    required String storeName,
    required String address,
    required String phoneNumber,
  }) async {
    try {
      final response = await DioService.post(
        '/merchants/request',
        data: {
          'storeName': storeName,
          'address': address,
          'phoneNumber': phoneNumber,
        },
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

  static String _handleError(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
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
