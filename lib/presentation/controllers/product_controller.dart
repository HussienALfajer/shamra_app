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
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadFeaturedProducts();
    loadOnSaleProducts();
    loadProducts();
  }

  // Load products with pagination
  Future<void> loadProducts({
    bool refresh = false,
    String? categoryId,
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

      final result = await _productRepository.getProducts(
        page: _currentPage.value,
        limit: 20,
        // categoryId: categoryId ?? _currentCategoryId.value,
        // search: search ?? _searchQuery.value,
      );
      print("NO ERROR IN PRODUCT CONTROLLER");

      final newProducts = result['products'] as List<Product>;

      if (refresh) {
        _products.value = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      _hasMoreData.value = result['hasNextPage'] ?? false;
      _currentPage.value++;

      if (categoryId != null) {
        _currentCategoryId.value = categoryId;
      }

      if (search != null) {
        _searchQuery.value = search;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load products: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      _isLoading.value = false;
      _isLoadingMore.value = false;
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

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final products = await _productRepository.searchProducts(
        query: query,
        limit: 50,
      );

      _searchResults.value = products;
      _searchQuery.value = query;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Search failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get products by category
  Future<void> getProductsByCategory(String categoryId) async {
    _currentCategoryId.value = categoryId;
    await loadProducts(refresh: true, categoryId: categoryId);
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
    _searchResults.clear();
    _searchQuery.value = '';
  }

  // Clear category filter
  void clearCategoryFilter() {
    _currentCategoryId.value = '';
    refreshProducts();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }
}
