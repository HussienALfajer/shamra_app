import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/banner.dart';

class BannerService {
  // Get all banners
  static Future<Map<String, dynamic>> getBanners({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioService.get(
        '/banners',
        queryParameters: {'page': page, 'limit': limit},
      );

      final banners = (response.data['data'] as List)
          .map((item) => Banner.fromJson(item))
          .toList();

      final pagination = response.data['pagination'] as Map<String, dynamic>?;

      return {
        'banners': banners,
        'hasNextPage': pagination?['hasNext'] ?? false,
        'hasPrevPage': pagination?['hasPrev'] ?? false,
        'totalPages': pagination?['pages'] ?? 1,
        'totalItems': pagination?['total'] ?? banners.length,
        'currentPage': pagination?['page'] ?? page,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get active banners only
  static Future<Map<String, dynamic>> getActiveBanners({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioService.get(
        '/banners',
        queryParameters: {
          'page': page,
          'limit': limit,
          'isActive': true,
        },
      );

      final banners = (response.data['data'] as List)
          .map((item) => Banner.fromJson(item))
          .where((banner) => banner.isActive)
          .toList();

      final pagination = response.data['pagination'] as Map<String, dynamic>?;

      return {
        'banners': banners,
        'hasNextPage': pagination?['hasNext'] ?? false,
        'hasPrevPage': pagination?['hasPrev'] ?? false,
        'totalPages': pagination?['pages'] ?? 1,
        'totalItems': pagination?['total'] ?? banners.length,
        'currentPage': pagination?['page'] ?? page,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get banner by ID
  static Future<Banner> getBannerById(String bannerId) async {
    try {
      final response = await DioService.get(
        '/banners/$bannerId',
      );

      return Banner.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get banners by product ID
  static Future<List<Banner>> getBannersByProduct(String productId) async {
    try {
      final response = await DioService.get(
        '/banners',
        queryParameters: {'productId': productId},
      );

      return (response.data['data'] as List)
          .map((item) => Banner.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get banners by category ID
  static Future<List<Banner>> getBannersByCategory(String categoryId) async {
    try {
      final response = await DioService.get(
        '/banners',
        queryParameters: {'categoryId': categoryId},
      );

      return (response.data['data'] as List)
          .map((item) => Banner.fromJson(item))
          .toList();
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