import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/product.dart';

class ProductService {
  // Get all products with pagination and filters
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? branchId,
    String? search,
    String sort = '-createdAt',
  }) async {
    try {
      final response = await DioService.get(
        ApiConstants.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
          if (branchId != null) 'branchId': branchId,
          if (search != null) 'search': search,
          'sort': sort,
        },
      );

      final data = response.data;
      return {
        'products': (data['data'] as List)
            .map((item) => Product.fromJson(item))
            .toList(),
        'totalPages': data['pagination']['pages'] ?? 1,
        'currentPage': data['pagination']['page'] ?? 1,
        'totalItems': data['pagination']['total'] ?? 0,
        'hasNextPage': data['pagination']['hasNext'] ?? false,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get featured products
  static Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await DioService.get(
        ApiConstants.featuredProducts,
        queryParameters: {'limit': limit},
      );

      return (response.data['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get products on sale
  static Future<List<Product>> getOnSaleProducts({int limit = 20}) async {
    try {
      final response = await DioService.get(
        ApiConstants.onSaleProducts,
        queryParameters: {'limit': limit},
      );

      return (response.data['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get product by ID
  static Future<Product> getProductById(String productId) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.products}/$productId',
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get product by SKU
  static Future<Product> getProductBySku(String sku) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.products}/sku/$sku',
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get product by slug
  static Future<Product> getProductBySlug(String slug) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.products}/slug/$slug',
      );
      return Product.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Search products
  static Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    try {
      final response = await DioService.get(
        ApiConstants.products,
        queryParameters: {
          'search': query,
          'page': page,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );

      return (response.data['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await DioService.get(
        ApiConstants.products,
        queryParameters: {
          'categoryId': categoryId,
          'page': page,
          'limit': limit,
        },
      );

      return (response.data['data'] as List)
          .map((item) => Product.fromJson(item))
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
