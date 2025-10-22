/////////////////////////////////
// lib/data/repositories/product_repository.dart  (updated)
import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {
  /// Fetch products with pagination and optional filters.
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

  /// Products by category (returns pagination map)
  Future<Map<String, dynamic>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      return await ProductService.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
        search: search,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Products by subcategory (returns pagination map)
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

  /// Featured products (paginated map) — supports category/subCategory filters
  Future<Map<String, dynamic>> getFeaturedProducts({
    int limit = 20,
    int page = 1,
    String? search,
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      return await ProductService.getFeaturedProducts(
        limit: limit,
        page: page,
        search: search,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// On-sale products (paginated map) — supports category/subCategory filters
  Future<Map<String, dynamic>> getOnSaleProducts({
    int limit = 20,
    int page = 1,
    String? search,
    String? categoryId,
    String? subCategoryId,
  }) async {
    try {
      return await ProductService.getOnSaleProducts(
        limit: limit,
        page: page,
        search: search,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Single product by id
  Future<Product> getProductById(String productId) async {
    try {
      return await ProductService.getProductById(productId);
    } catch (e) {
      rethrow;
    }
  }

  /// Simple search (returns list of Product)
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
