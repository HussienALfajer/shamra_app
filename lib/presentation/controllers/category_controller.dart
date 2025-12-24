import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ProductRepository _productRepository = ProductRepository();

  // Category data
  final RxList<Category> _categories = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Category?> _selectedCategory = Rx<Category?>(null);

  // Category-specific product data
  final RxList<Product> _categoryProducts = <Product>[].obs;
  final RxBool _isLoadingProducts = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _productErrorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;

  // Filter states
  final RxString _searchQuery = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;
  final RxString _selectedSubSubCategoryId = ''.obs;
  final RxBool _showSearch = false.obs;

  // Current category context
  String currentCategoryId = '';
  String _currentCategoryName = '';

  // Getters - Categories
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Category? get selectedCategory => _selectedCategory.value;

  // Getters - Products
  List<Product> get categoryProducts => _categoryProducts;
  bool get isLoadingProducts => _isLoadingProducts.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get productErrorMessage => _productErrorMessage.value;
  bool get hasMoreData => _hasMoreData.value;

  // Getters - Filters
  String get searchQuery => _searchQuery.value;
  String get selectedSubCategoryId => _selectedSubCategoryId.value;
  String get selectedSubSubCategoryId => _selectedSubSubCategoryId.value;
  bool get showSearch => _showSearch.value;
  String get currentCategoryName => _currentCategoryName;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Initialize category page with specific category
  void initializeCategoryPage(String categoryId, String categoryName) {
    currentCategoryId = categoryId;
    _currentCategoryName = categoryName;
    _resetAllState();
    loadCategoryProducts();
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final categories = await _categoryRepository.getCategories(limit: 100);
      _categories.value = categories;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل تحميل الفئات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load products for current category
  Future<void> loadCategoryProducts({bool resetPagination = false}) async {
    if (currentCategoryId.isEmpty) return;

    try {
      if (resetPagination) {
        _resetPaginationOnly();
      }

      _isLoadingProducts.value = true;
      _productErrorMessage.value = '';

      Map<String, dynamic> result;

      print('🔍 Loading products with filters:');
      print('  - Category: $currentCategoryId');
      print('  - SubCategory: ${_selectedSubCategoryId.value}');
      print('  - SubSubCategory: ${_selectedSubSubCategoryId.value}');
      print('  - Search: ${_searchQuery.value}');
      print('  - Page: ${_currentPage.value}');

      // Choose API call based on current filters
      // Priority: SubSubCategory > SubCategory > Category
      if (_selectedSubSubCategoryId.value.isNotEmpty) {
        // Filter by sub-sub-category (highest priority)
        result = await _productRepository.getProductsBySubSubCategory(
          subSubCategoryId: _selectedSubSubCategoryId.value,
          page: _currentPage.value,
          limit: 20,
          search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
        );
      } else if (_searchQuery.value.isNotEmpty) {
        if (_selectedSubCategoryId.value.isNotEmpty) {
          result = await _productRepository.getProductsBySubCategory(
            subCategoryId: _selectedSubCategoryId.value,
            page: _currentPage.value,
            limit: 20,
            search: _searchQuery.value,
          );
        } else {
          result = await _productRepository.getProductsByCategory(
            categoryId: currentCategoryId,
            page: _currentPage.value,
            limit: 20,
            search: _searchQuery.value,
          );
        }
      } else if (_selectedSubCategoryId.value.isNotEmpty) {
        result = await _productRepository.getProductsBySubCategory(
          subCategoryId: _selectedSubCategoryId.value,
          page: _currentPage.value,
          limit: 20,
        );
      } else {
        result = await _productRepository.getProductsByCategory(
          categoryId: currentCategoryId,
          page: _currentPage.value,
          limit: 20,
        );
      }

      final newProducts = result['products'] as List<Product>;

      if (resetPagination) {
        _categoryProducts.value = newProducts;
      } else {
        _categoryProducts.addAll(newProducts);
      }

      _hasMoreData.value = result['hasNextPage'] ?? false;

      print('✅ تم تحميل ${newProducts.length} منتجات للصفحة ${_currentPage.value}');

    } catch (e) {
      _productErrorMessage.value = e.toString();
      print('❌ خطأ في تحميل منتجات الفئة: $e');

      Get.snackbar(
        'خطأ',
        'فشل تحميل المنتجات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoadingProducts.value = false;
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore.value || !_hasMoreData.value || currentCategoryId.isEmpty) return;

    print('📄 Loading more products - Page: ${_currentPage.value + 1}');

    try {
      _isLoadingMore.value = true;
      _currentPage.value++;

      await loadCategoryProducts();

    } catch (e) {
      _currentPage.value--; // Revert page increment on error
      print('❌ خطأ في تحميل المزيد من المنتجات: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Search products in current category
  Future<void> searchProducts(String query) async {
    print('🔍 Searching for: "$query"');
    _searchQuery.value = query.trim();
    await loadCategoryProducts(resetPagination: true);
  }

  /// Clear search
  Future<void> clearSearch() async {
    print('🔍 Clearing search');
    _searchQuery.value = '';
    await loadCategoryProducts(resetPagination: true);
  }

  /// Filter by subcategory
  Future<void> filterBySubCategory(String subCategoryId) async {
    print('🏷️ Filtering by subcategory: $subCategoryId');
    _selectedSubCategoryId.value = subCategoryId;
    _selectedSubSubCategoryId.value = ''; // Clear sub-sub-category when changing sub-category
    _searchQuery.value = ''; // Clear search when filtering
    await loadCategoryProducts(resetPagination: true);
  }

  /// Clear subcategory filter
  Future<void> clearSubCategoryFilter() async {
    print('🏷️ Clearing subcategory filter');
    _selectedSubCategoryId.value = '';
    _selectedSubSubCategoryId.value = ''; // Also clear sub-sub-category
    await loadCategoryProducts(resetPagination: true);
  }

  /// Filter by sub-subcategory
  Future<void> filterBySubSubCategory(String subSubCategoryId) async {
    print('🏷️ Filtering by sub-subcategory: $subSubCategoryId');
    _selectedSubSubCategoryId.value = subSubCategoryId;
    _searchQuery.value = ''; // Clear search when filtering
    await loadCategoryProducts(resetPagination: true);
  }

  /// Clear sub-subcategory filter
  Future<void> clearSubSubCategoryFilter() async {
    print('🏷️ Clearing sub-subcategory filter');
    _selectedSubSubCategoryId.value = '';
    await loadCategoryProducts(resetPagination: true);
  }

  /// Toggle search visibility
  void toggleSearch() {
    _showSearch.value = !_showSearch.value;
    if (!_showSearch.value) {
      clearSearch();
    }
  }

  /// Reset only pagination data (preserve filters)
  void _resetPaginationOnly() {
    _categoryProducts.clear();
    _currentPage.value = 1;
    _hasMoreData.value = true;
    _isLoadingProducts.value = false;
    _isLoadingMore.value = false;
    _productErrorMessage.value = '';
  }

  /// Reset all state (including filters)
  void _resetAllState() {
    _resetPaginationOnly();
    _searchQuery.value = '';
    _selectedSubCategoryId.value = '';
    _selectedSubSubCategoryId.value = '';
    _showSearch.value = false;
  }

  /// Get empty message based on current state
  String getEmptyMessage() {
    if (_searchQuery.value.isNotEmpty) {
      return 'لا توجد نتائج للبحث عن "${_searchQuery.value}"';
    } else if (_selectedSubSubCategoryId.value.isNotEmpty) {
      return 'لا توجد منتجات في هذه الفئة الفرعية';
    } else if (_selectedSubCategoryId.value.isNotEmpty) {
      return 'لا توجد منتجات في هذه الفئة الفرعية';
    }
    return 'لا توجد منتجات متاحة في هذا القسم حالياً';
  }

  /// Select category
  void selectCategory(Category? category) {
    _selectedCategory.value = category;
  }

  /// Clear selected category
  void clearSelectedCategory() {
    _selectedCategory.value = null;
  }

  /// Search categories
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    return _categories.where((category) {
      return category.displayName.toLowerCase().contains(query.toLowerCase()) ||
          (category.displayDescription.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  /// Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  /// Clear product error message
  void clearProductErrorMessage() {
    _productErrorMessage.value = '';
  }

  /// Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  /// Refresh category products
  Future<void> refreshCategoryProducts() async {
    await loadCategoryProducts(resetPagination: true);
  }

  /// Clean up when leaving category page
  void cleanupCategoryPage() {
    _resetAllState();
    currentCategoryId = '';
    _currentCategoryName = '';
  }

  @override
  void onClose() {
    cleanupCategoryPage();
    super.onClose();
  }
}