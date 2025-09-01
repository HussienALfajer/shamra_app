import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/category.dart';

class CategoryService {
  // Get all categories
  static Future<List<Category>> getCategories({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await DioService.get(
        ApiConstants.categories,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return (response.data['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get category tree (hierarchical structure)
  static Future<List<Category>> getCategoryTree() async {
    try {
      final response = await DioService.get('${ApiConstants.categories}/tree');
      
      return (response.data['data'] as List)
          .map((item) => Category.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get category by ID
  static Future<Category> getCategoryById(String categoryId, {bool withChildren = false}) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.categories}/$categoryId',
        queryParameters: {
          'withChildren': withChildren,
        },
      );

      return Category.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get category by slug
  static Future<Category> getCategoryBySlug(String slug, {bool withChildren = false}) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.categories}/slug/$slug',
        queryParameters: {
          'withChildren': withChildren,
        },
      );

      return Category.fromJson(response.data['data']);
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