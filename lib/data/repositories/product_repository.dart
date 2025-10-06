import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {
  // Get products with pagination and filters
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? subCategoryId,
    String? search,
    String sort = '-createdAt',
  }) async {
    try {
      return await ProductService.getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        search: search,
        sort: sort,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ✅ إصلاح: Get products by category يجب أن يعيد Map وليس List
  Future<Map<String, dynamic>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? search
  }) async {
    try {
      return await ProductService.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        search: search
      );
    } catch (e) {
      rethrow;
    }
  }

  // ✅ إضافة: Get products by subcategory
  Future<Map<String, dynamic>> getProductsBySubCategory({
    required String subCategoryId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      return await ProductService.getProductsBySubCategory(
        subCategoryId: subCategoryId,
        page: page,
        limit: limit,
        search: search,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get featured products
  Future<Map<String, dynamic>> getFeaturedProducts({
    int limit = 20,
    int page = 1,
    String? search,
  }) async {
    try {
      return await ProductService.getFeaturedProducts(
        limit: limit,
        page: page,
        search: search,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get products on sale (directly from API)
  Future<Map<String, dynamic>> getOnSaleProducts({
    int limit = 20,
    int page = 1,
    String? search,
  }) async {
    try {
      return await ProductService.getOnSaleProducts(
        limit: limit,
        page: page,
        search: search,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get product by ID
  Future<Product> getProductById(String productId) async {
    try {
      return await ProductService.getProductById(productId);
    } catch (e) {
      rethrow;
    }
  }

  // Search products
  Future<List<Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    try {
      return await ProductService.searchProducts(
        query: query,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
