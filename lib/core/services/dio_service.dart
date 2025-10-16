// lib/core/services/dio_service.dart
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Centralized HTTP client using Dio with auth/branch interceptors
/// and a safe refresh-token flow.
class DioService {
  static final Dio _dio = Dio();

  // Single-flight refresh guard to prevent concurrent refresh calls.
  static Future<void>? _refreshFuture;

  static Dio get instance => _dio;

  static void initialize() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _addInterceptors();
  }

  static void _addInterceptors() {
    // Pretty logger in debug mode only.
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
          filter: (options, args) => !options.path.contains(ApiConstants.refresh),
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Attach access token if available
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Attach branch id if available
          final branchId = StorageService.getBranchId();
          if (branchId != null && branchId.isNotEmpty) {
            options.headers['x-branch-id'] = branchId;
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          // Skip refresh logic if it's the refresh endpoint itself.
          final isRefreshCall = error.requestOptions.path.contains(ApiConstants.refresh);

          // Attempt token refresh on 401 (unauthorized).
          if (error.response?.statusCode == 401 && !isRefreshCall) {
            try {
              // Run a single shared refresh for concurrent 401s.
              _refreshFuture ??= _refreshToken();
              await _refreshFuture;
              _refreshFuture = null;

              // Retry the original request with updated tokens.
              final clone = await _retry(error.requestOptions);
              return handler.resolve(clone);
            } catch (e) {
              // Refresh failed: clear tokens and propagate original error.
              await StorageService.removeToken();
              await StorageService.removeRefreshToken();
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  /// Retries a request using the same options after a successful refresh.
  static Future<Response<dynamic>> _retry(RequestOptions request) {
    final options = Options(
      method: request.method,
      headers: request.headers,
      responseType: request.responseType,
      followRedirects: request.followRedirects,
      validateStatus: request.validateStatus,
      receiveDataWhenStatusError: request.receiveDataWhenStatusError,
      contentType: request.contentType,
    );

    return _dio.request(
      request.path,
      data: request.data,
      queryParameters: request.queryParameters,
      options: options,
    );
  }

  /// Performs the refresh-token request and stores new tokens.
  static Future<void> _refreshToken() async {
    final refreshToken = StorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    // Use a clean request without auth header to avoid recursion.
    final response = await _dio.post(
      ApiConstants.refresh,
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {
          'Authorization': null, // Ensure no stale access token is sent
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Parse response defensively (handle different API shapes).
    final dynamic body = response.data;
    Map<String, dynamic> map;
    if (body is Map<String, dynamic>) {
      map = body;
    } else {
      map = <String, dynamic>{};
    }

    // Common shapes: {token, refreshToken} OR {data:{accessToken, refreshToken}}.
    final data = (map['data'] is Map) ? Map<String, dynamic>.from(map['data'] as Map) : map;

    final String? newAccess = (data['accessToken'] ?? data['token'])?.toString();
    final String? newRefresh = data['refreshToken']?.toString();

    if (newAccess == null || newAccess.isEmpty) {
      throw Exception('Invalid refresh response');
    }

    await StorageService.saveToken(newAccess);
    if (newRefresh != null && newRefresh.isNotEmpty) {
      await StorageService.saveRefreshToken(newRefresh);
    }
  }

  // HTTP verbs

  static Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (_) {
      rethrow;
    }
  }

  static Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (_) {
      rethrow;
    }
  }

  static Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (_) {
      rethrow;
    }
  }

  static Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (_) {
      rethrow;
    }
  }
}