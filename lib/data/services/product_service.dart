/////////////////////////////////////
// lib/data/services/product_service.dart  (updated)
import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/product.dart';

class ProductService {
  /// Fetch products with pagination and filters.
  /// Returns a map containing pagination info and `products: List<Product>`
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? subCategoryId,
    String? search,
    String sort = '-createdAt',
    bool? isFeatured,
    bool? isOnSale,
  }) async {
    try {
      final branchId = StorageService.getBranchId();
      final response = await DioService.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
          if (subCategoryId != null) 'subCategoryId': subCategoryId,
          if (search != null) 'search': search,
          if (isFeatured != null) 'isFeatured': isFeatured, // keep booleans
          if (isOnSale != null) 'isOnSale': isOnSale,       // keep booleans
          'sort': sort,
          if (branchId != null && branchId.isNotEmpty)
            'selectedBranchId': branchId,
        },
      );

      final data = response.data;
      return {
        'products': (data['data'] as List)
            .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        'totalPages': data['pagination']?['pages'] ?? 1,
        'currentPage': data['pagination']?['page'] ?? 1,
        'totalItems': data['pagination']?['total'] ?? 0,
        'hasNextPage': data['pagination']?['hasNext'] ?? false,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      return await getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: search,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      return await getProducts(
        page: page,
        limit: limit,
        subCategoryId: subCategoryId,
        search: search,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Featured products (supports category/subCategory filters)
  static Future<Map<String, dynamic>> getFeaturedProducts({
    int limit = 10,
    int page = 1,
    String? search,
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      return await getProducts(
        page: page,
        limit: limit,
        isFeatured: true,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        search: search,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// On-sale products (supports category/subCategory filters)
  static Future<Map<String, dynamic>> getOnSaleProducts({
    int limit = 20,
    int page = 1,
    String? search,
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      return await getProducts(
        page: page,
        limit: limit,
        isOnSale: true,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        search: search,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Product> getProductById(String productId) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.products}/$productId',
      );
      return Product.fromJson(Map<String, dynamic>.from(response.data['data']));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    try {
      final result = await getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: query,
      );

      return (result['products'] as List<Product>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static String _handleError(DioException error) {
    if (error.response?.data != null) {
      try {
        final data = error.response!.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
      } catch (_) {}
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
