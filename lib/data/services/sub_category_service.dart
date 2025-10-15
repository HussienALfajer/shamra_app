import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/sub_category.dart';

class SubCategoryService {
  // Get all sub-categories with optional filtering
  static Future<List<SubCategory>> getSubCategories({
    int page = 1,
    int limit = 50,
    String? categoryId,
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isActive != null) queryParams['isActive'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await DioService.get(
        ApiConstants.subCategories,
        queryParameters: queryParams,
      );
      // print(response.data);
      return (response.data as List)
          .map((item) => SubCategory.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get sub-categories by category ID
  static Future<List<SubCategory>> getSubCategoriesByCategory(
      String categoryId,
      ) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.subCategories}/category/$categoryId',
      );
      return (response.data as List)
          .map((item) => SubCategory.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get sub-category by ID
  static Future<SubCategory> getSubCategoryById(String subCategoryId) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.subCategories}/$subCategoryId',
      );

      return SubCategory.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get active sub-categories only
  static Future<List<SubCategory>> getActiveSubCategories({
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    return getSubCategories(
      page: page,
      limit: limit,
      categoryId: categoryId,
      isActive: true,
    );
  }

  // Search sub-categories
  static Future<List<SubCategory>> searchSubCategories({
    required String query,
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    return getSubCategories(
      page: page,
      limit: limit,
      categoryId: categoryId,
      search: query,
      isActive: true,
    );
  }

  // Get sub-categories by type
  static Future<List<SubCategory>> getSubCategoriesByType({
    required SubCategoryType type,
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'type': type.value,
        'isActive': true,
      };

      if (categoryId != null) queryParams['categoryId'] = categoryId;

      final response = await DioService.get(
        ApiConstants.subCategories,
        queryParameters: queryParams,
      );

      return (response.data['data'] as List)
          .map((item) => SubCategory.fromJson(item))
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