import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class DioService {
  static final Dio _dio = Dio();

  static Dio get instance => _dio;

  static void initialize() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _addInterceptors();
  }

  static void _addInterceptors() {
    // Add Pretty Dio Logger (only in debug mode)
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false,
          error: true,
          compact: false,
          maxWidth: 90,
          enabled: kDebugMode,
          filter: (options, args) {
            return !options.path.contains('/auth/refresh');
          },
        ),
      );
    }

    // Add authentication + branchId interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token if available
          final token = StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add branchId if available
          final branchId = StorageService.getBranchId();
          if (branchId != null && branchId.isNotEmpty) {
            options.headers['x-branch-id'] = branchId;
          }

          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            StorageService.removeToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  static Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  static Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  static Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  static Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
