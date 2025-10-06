import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/product.dart';

class ProductService {
  // Get all products with pagination and filters
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
          if(isFeatured!=null) 'isFeatured':isFeatured.toString(),
          if(isOnSale!=null) 'isOnSale':isOnSale.toString(),
          'sort': sort,
          if (branchId != null && branchId.isNotEmpty)
            'selectedBranchId': branchId,
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

  // Get products by category
  static Future<Map<String, dynamic>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? search
  }) async {
    try {
      return await getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: search
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //  Get products by subcategory
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
        search: search
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get featured products
  static Future<Map<String, dynamic>> getFeaturedProducts({int limit = 10,int page=1,    String? search,
  }) async {
    try {
      return await getProducts(
        page: page,
        limit: limit,
        isFeatured: true,
        search: search
      ) ;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get products on sale
  static Future<Map<String, dynamic>> getOnSaleProducts({int limit = 20,int page=1,    String? search,
  }) async {
    try {
      return await getProducts(
          page: page,
          limit: limit,
          isOnSale: true,
        search: search
      ) ;
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



  // Search products
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

      return result['products'] as List<Product>;
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