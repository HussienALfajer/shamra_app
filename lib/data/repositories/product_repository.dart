import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {
  // Get products with pagination and filters
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? subCategoryId, // إضافة معامل الفئة الفرعية
    String? branchId,
    String? search,
    String sort = '-createdAt',
  }) async {
    try {
      return await ProductService.getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        subCategoryId: subCategoryId, // تمرير الفئة الفرعية
        branchId: branchId,
        search: search,
        sort: sort,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 20}) async {
    try {
      return await ProductService.getFeaturedProducts(limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get products on sale
  Future<List<Product>> getOnSaleProducts({int limit = 20}) async {
    try {
      final allProducts = await getProducts(page: 1, limit: 1000);
      final products = allProducts['products'] as List<Product>;

      final onSaleProducts = products.where((product) {
        return product.hasDiscount;
      }).take(limit).toList();

      print("Found ${onSaleProducts.length} products on sale");
      return onSaleProducts;

    } catch (e) {
      print("Error getting on sale products: $e");
      throw e;
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

  // Get product by SKU
  Future<Product> getProductBySku(String sku) async {
    try {
      return await ProductService.getProductBySku(sku);
    } catch (e) {
      rethrow;
    }
  }

  // Get product by slug
  Future<Product> getProductBySlug(String slug) async {
    try {
      return await ProductService.getProductBySlug(slug);
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

  // Get products by category
  Future<List<Product>> getProductsByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await ProductService.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }
}
