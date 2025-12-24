import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/sub_sub_category.dart';

class SubSubCategoryService {
  // Get all sub-sub-categories with optional filtering
  static Future<List<SubSubCategory>> getSubSubCategories({
    int page = 1,
    int limit = 50,
    String? subCategoryId,
    bool? isActive,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (subCategoryId != null) queryParams['subCategoryId'] = subCategoryId;
      if (isActive != null) queryParams['isActive'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await DioService.get(
        ApiConstants.subSubCategories,
        queryParameters: queryParams,
      );

      return (response.data as List)
          .map((item) => SubSubCategory.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get sub-sub-categories by sub-category ID
  static Future<List<SubSubCategory>> getSubSubCategoriesBySubCategory(
    String subCategoryId,
  ) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.subSubCategories}/sub-category/$subCategoryId',
      );
      return (response.data as List)
          .map((item) => SubSubCategory.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get sub-sub-category by ID
  static Future<SubSubCategory> getSubSubCategoryById(String id) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.subSubCategories}/$id',
      );

      return SubSubCategory.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get active sub-sub-categories only
  static Future<List<SubSubCategory>> getActiveSubSubCategories({
    int page = 1,
    int limit = 50,
    String? subCategoryId,
  }) async {
    return getSubSubCategories(
      page: page,
      limit: limit,
      subCategoryId: subCategoryId,
      isActive: true,
    );
  }

  // Search sub-sub-categories
  static Future<List<SubSubCategory>> searchSubSubCategories({
    required String query,
    int page = 1,
    int limit = 50,
    String? subCategoryId,
  }) async {
    return getSubSubCategories(
      page: page,
      limit: limit,
      subCategoryId: subCategoryId,
      search: query,
      isActive: true,
    );
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
