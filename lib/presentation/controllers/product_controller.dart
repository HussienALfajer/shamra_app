import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  // Observables
  final RxList<Product> _products = <Product>[].obs;
  final RxList<Product> _featuredProducts = <Product>[].obs;
  final RxList<Product> _onSaleProducts = <Product>[].obs;
  final RxList<Product> _searchResults = <Product>[].obs;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasMoreData = true.obs;
  final RxString _errorMessage = ''.obs;

  final RxInt _currentPage = 1.obs;
  final RxString _currentCategoryId = ''.obs;
  final RxString _currentSubCategoryId = ''.obs;
  final RxString _searchQuery = ''.obs;

  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get onSaleProducts => _onSaleProducts;
  List<Product> get searchResults => _searchResults;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMoreData => _hasMoreData.value;
  String get errorMessage => _errorMessage.value;

  int get currentPage => _currentPage.value;
  String get currentCategoryId => _currentCategoryId.value;
  String get currentSubCategoryId => _currentSubCategoryId.value;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadFeaturedProducts();
    loadOnSaleProducts();
    loadProducts();
  }

  // Load products with pagination and filters
  Future<void> loadProducts({
    bool refresh = false,
    String? categoryId,
    String? subCategoryId,
    String? search,
  }) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMoreData.value = true;
        _isLoading.value = true;
      } else {
        _isLoadingMore.value = true;
      }

      _errorMessage.value = '';

      // تحديث الفلاتر الحالية
      if (categoryId != null) _currentCategoryId.value = categoryId;
      if (subCategoryId != null) _currentSubCategoryId.value = subCategoryId;
      if (search != null) _searchQuery.value = search;

      final result = await _productRepository.getProducts(
        page: _currentPage.value,
        limit: 20,
        categoryId: _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
        subCategoryId: _currentSubCategoryId.value.isNotEmpty ? _currentSubCategoryId.value : null,
        search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      );

      final newProducts = result['products'] as List<Product>;


      if (refresh) {
        _products.value = newProducts;
        if (_searchQuery.value.isNotEmpty) {
          _searchResults.value = newProducts;
        }
      } else {
        _products.addAll(newProducts);
        if (_searchQuery.value.isNotEmpty) {
          _searchResults.addAll(newProducts);
        }
      }

      _hasMoreData.value = result['hasNextPage'] ?? false;
      _currentPage.value++;

    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load products: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  // Load more products
  Future<void> loadMoreProducts() async {
    if (!_hasMoreData.value || _isLoadingMore.value) return;
    await loadProducts();
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      final products = await _productRepository.getFeaturedProducts(limit: 10);
      _featuredProducts.value = products;
    } catch (e) {
      _errorMessage.value = e.toString();
    }
  }

  // Load products on sale
  Future<void> loadOnSaleProducts() async {
    try {
      final products = await _productRepository.getOnSaleProducts(limit: 20);
      _onSaleProducts.value = products;
    } catch (e) {
      _errorMessage.value = e.toString();
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _searchResults.clear();
      await loadProducts(refresh: true);
      return;
    }

    await loadProducts(refresh: true, search: query);
  }

  // Get products by category
  Future<void> getProductsByCategory(String categoryId) async {
    await loadProducts(refresh: true, categoryId: categoryId);
  }

  Future<void> filterBySubCategory(String subCategoryId) async {
    await loadProducts(refresh: true, subCategoryId: subCategoryId);
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      return await _productRepository.getProductById(productId);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load product: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
    loadProducts(refresh: true);
  }

  // Clear category filter
  void clearCategoryFilter() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    loadProducts(refresh: true);
  }

  // Clear subcategory filter
  void clearSubCategoryFilter() {
    _currentSubCategoryId.value = '';
    loadProducts(refresh: true);
  }

  // Clear all filters
  void clearAllFilters() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    _searchResults.clear();
    loadProducts(refresh: true);
  }

  // إعادة تعيين كامل للبيانات
  void resetAllData() {
    _products.clear();
    _featuredProducts.clear();
    _onSaleProducts.clear();
    _searchResults.clear();
    _currentPage.value = 1;
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    _hasMoreData.value = true;
    _errorMessage.value = '';
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }
}