import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';

class MainController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Observables
  final RxList<Product> _featuredProducts = <Product>[].obs;
  final RxList<Product> _onSaleProducts = <Product>[].obs;
  final RxList<Product> _recentProducts = <Product>[].obs;
  final RxList<Category> _categories = <Category>[].obs;
  final RxList<Product> _searchResults = <Product>[].obs;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingCategories = false.obs;
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _errorMessage = ''.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Getters
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get onSaleProducts => _onSaleProducts;
  List<Product> get recentProducts => _recentProducts;
  List<Category> get categories => _categories;
  List<Product> get searchResults => _searchResults;

  bool get isLoading => _isLoading.value;
  bool get isLoadingCategories => _isLoadingCategories.value;
  bool get isSearching => _isSearching.value;
  String get searchQuery => _searchQuery.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Load initial data for main page
  Future<void> loadInitialData() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      await Future.wait([
        loadFeaturedProducts(),
        loadOnSaleProducts(),
        loadRecentProducts(),
        loadCategories(),
      ]);
      _isLoading.value = false;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل البيانات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      final products = await _productRepository.getFeaturedProducts(limit: 10);
      _featuredProducts.value = products;
    } catch (e) {
      print('Error loading featured products: $e');
    }
  }

  // Load products on sale
  Future<void> loadOnSaleProducts() async {
    try {
      final products = await _productRepository.getOnSaleProducts(limit: 15);
      _onSaleProducts.value = products;
    } catch (e) {
      print('Error loading on sale products: $e');
    }
  }

  // Load recent products
  Future<void> loadRecentProducts() async {
    try {
      final result = await _productRepository.getProducts(page: 1, limit: 12);
      print("NO ERROR IN MAIN CONTROLLER");
      _recentProducts.value = result['products'] as List<Product>;
    } catch (e) {
      print('Error loading recent products: $e');
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoadingCategories.value = true;
      final categories = await _categoryRepository.getCategories();
      _categories.value = categories
          .take(8)
          .toList(); // Show only first 8 categories
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      _searchQuery.value = '';
      return;
    }

    try {
      _isSearching.value = true;
      _searchQuery.value = query;

      final products = await _productRepository.searchProducts(
        query: query,
        limit: 50,
      );

      _searchResults.value = products;
    } catch (e) {
      Get.snackbar(
        'خطأ في البحث',
        'فشل في البحث: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    _searchResults.clear();
    _searchQuery.value = '';
  }

  // Refresh all data
  Future<void> refreshData() async {
    await loadInitialData();
  }

  // Navigate to product details
  void goToProductDetails(Product product) {
    Get.toNamed('/product-details', arguments: product);
  }

  // Navigate to category products
  void goToCategoryProducts(Category category) {
    Get.toNamed('/products-by-category', arguments: category);
  }

  // Navigate to all categories
  void goToAllCategories() {
    Get.toNamed('/categories');
  }

  // Navigate to all featured products
  void goToAllFeaturedProducts() {
    Get.toNamed('/products', arguments: {'featured': true});
  }

  // Navigate to all sale products
  void goToAllSaleProducts() {
    Get.toNamed('/products', arguments: {'onSale': true});
  }

  // Navigate to search page
  void goToSearchPage() {
    Get.toNamed('/search');
  }
}
