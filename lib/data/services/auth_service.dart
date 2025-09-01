import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';
import '../models/auth_res.dart';

class AuthService {
  // Login
  static Future<AuthResponseApi> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      return AuthResponseApi.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Register
  static Future<AuthResponseApi> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final response = await DioService.post(
        ApiConstants.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      return AuthResponseApi.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // selecte branch return new access_token and refresh_token
  static Future<AuthResponseApi> selectBranch({
    required String branchId,
  }) async {
    try {
      final response = await DioService.post(
        ApiConstants.selectBranch,
        data: {'branchId': branchId},
      );
      return AuthResponseApi.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get Profile
  static Future<User> getProfile() async {
    try {
      final response = await DioService.get(ApiConstants.profile);
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update Profile
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

      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Change Password
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

  // Logout
  static Future<void> logout() async {
    try {
      await DioService.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  static String _handleError(DioException error) {
    if (error.response?.data != null) {
      return error.response!.data['message'] ?? 'Something went wrong';
    }

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
