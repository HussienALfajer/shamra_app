import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

enum ProductTab { all, featured, onSale }

class ProductController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  // Tab-specific data storage
  final Map<ProductTab, List<Product>> _tabProducts = {
    ProductTab.all: <Product>[],
    ProductTab.featured: <Product>[],
    ProductTab.onSale: <Product>[],
  };

  final Map<ProductTab, int> _tabPages = {
    ProductTab.all: 1,
    ProductTab.featured: 1,
    ProductTab.onSale: 1,
  };

  final Map<ProductTab, bool> _tabHasMoreData = {
    ProductTab.all: true,
    ProductTab.featured: true,
    ProductTab.onSale: true,
  };

  final Map<ProductTab, bool> _tabDataLoaded = {
    ProductTab.all: false,
    ProductTab.featured: false,
    ProductTab.onSale: false,
  };

  // Current state observables
  final Rx<ProductTab> _currentTab = ProductTab.all.obs;
  final RxList<Product> _currentProducts = <Product>[].obs;
  final RxList<Product> _searchResults = <Product>[].obs;

  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;

  // Filter states
  final RxString _currentCategoryId = ''.obs;
  final RxString _currentSubCategoryId = ''.obs;
  final RxString _searchQuery = ''.obs;

  // Getters
  ProductTab get currentTab => _currentTab.value;
  List<Product> get currentProducts => _currentProducts;
  List<Product> get searchResults => _searchResults;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get errorMessage => _errorMessage.value;

  String get currentCategoryId => _currentCategoryId.value;
  String get currentSubCategoryId => _currentSubCategoryId.value;
  String get searchQuery => _searchQuery.value;

  bool get hasMoreData => _tabHasMoreData[_currentTab.value] ?? false;
  bool get isCurrentTabLoaded => _tabDataLoaded[_currentTab.value] ?? false;

  @override
  void onInit() {
    super.onInit();
    // Don't load any data on init - wait for tab selection
  }

  /// Switch to a specific tab and load data if needed
  Future<void> switchToTab(ProductTab tab, {bool forceRefresh = false}) async {
    _currentTab.value = tab;

    // Load data for this tab if not loaded or force refresh
    if (!(_tabDataLoaded[tab] ?? false) || forceRefresh) {
      await _loadTabData(tab, refresh: true);
    } else {
      // Just update current products from cache
      _updateCurrentProductsFromTab();
    }
  }

  /// Load data for specific tab
  Future<void> _loadTabData(ProductTab tab, {bool refresh = false}) async {
    try {
      if (refresh) {
        _resetTabState(tab);
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      Map<String, dynamic> result;
      int currentPage = _tabPages[tab] ?? 1;

      switch (tab) {
        case ProductTab.all:
          result = await _productRepository.getProducts(
            page: currentPage,
            limit: 20,
            categoryId: _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty ? _currentSubCategoryId.value : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: currentPage,
            limit: 20,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: currentPage,
            limit: 20,
          );
          break;
      }

      final newProducts = result['products'] as List<Product>;

      if (refresh) {
        _tabProducts[tab] = newProducts;
      } else {
        _tabProducts[tab]!.addAll(newProducts);
      }

      _tabHasMoreData[tab] = result['hasNextPage'] ?? false;
      _tabPages[tab] = currentPage + 1;
      _tabDataLoaded[tab] = true;

      // Update current products if this is the active tab
      if (_currentTab.value == tab) {
        _updateCurrentProductsFromTab();
      }

      print('تم تحميل ${newProducts.length} منتجات للتبويب ${tab.toString()}');

    } catch (e) {
      _errorMessage.value = e.toString();
      print('خطأ في تحميل منتجات التبويب ${tab.toString()}: $e');

      if (Get.context != null) {
        Get.snackbar(
          'خطأ',
          'فشل تحميل المنتجات: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load more products for current tab
  Future<void> loadMoreProducts() async {
    if (!hasMoreData || _isLoadingMore.value) return;

    try {
      _isLoadingMore.value = true;

      Map<String, dynamic> result;
      int currentPage = _tabPages[_currentTab.value] ?? 1;

      switch (_currentTab.value) {
        case ProductTab.all:
          result = await _productRepository.getProducts(
            page: currentPage,
            limit: 20,
            categoryId: _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty ? _currentSubCategoryId.value : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: currentPage,
            limit: 20,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: currentPage,
            limit: 20,
          );
          break;
      }

      final newProducts = result['products'] as List<Product>;

      _tabProducts[_currentTab.value]!.addAll(newProducts);
      _tabHasMoreData[_currentTab.value] = result['hasNextPage'] ?? false;
      _tabPages[_currentTab.value] = currentPage + 1;

      _updateCurrentProductsFromTab();

      print('تم تحميل ${newProducts.length} منتجات إضافية للتبويب ${_currentTab.value.toString()}');

    } catch (e) {
      _errorMessage.value = e.toString();
      print('خطأ في تحميل المزيد من المنتجات: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Refresh current tab data
  Future<void> refreshCurrentTab() async {
    await _loadTabData(_currentTab.value, refresh: true);
  }

  /// Update current products from active tab
  void _updateCurrentProductsFromTab() {
    if (_searchQuery.value.isNotEmpty && _searchResults.isNotEmpty) {
      _currentProducts.value = _searchResults;
    } else {
      _currentProducts.value = _tabProducts[_currentTab.value] ?? [];
    }
  }

  /// Reset tab state for refresh
  void _resetTabState(ProductTab tab) {
    _tabProducts[tab] = [];
    _tabPages[tab] = 1;
    _tabHasMoreData[tab] = true;
    _tabDataLoaded[tab] = false;
  }

  /// Search products in current tab context
  Future<void> searchProducts(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      _searchResults.clear();
      _updateCurrentProductsFromTab();
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      Map<String, dynamic> result;

      switch (_currentTab.value) {
        case ProductTab.all:
          result = await _productRepository.getProducts(
            page: 1,
            limit: 50, // More results for search
            search: query,
            categoryId: _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty ? _currentSubCategoryId.value : null,
          );
          break;
        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: 1,
            limit: 50,
            search: query,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: 1,
            limit: 50,
            search: query,
          );
          break;
      }

      _searchResults.value = result['products'] as List<Product>;
      _updateCurrentProductsFromTab();

    } catch (e) {
      _errorMessage.value = e.toString();
      print('خطأ في البحث: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filter by category (only for "All" tab)
  Future<void> getProductsByCategory(String categoryId,{int page=1}) async {
    if (_currentTab.value != ProductTab.all) {
      print('تصفية الفئات متاحة فقط في تبويبة "الكل"');
      return;
    }

    print('🔍 بدء تحميل منتجات الفئة: $categoryId');

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      _currentCategoryId.value = categoryId;
      _currentSubCategoryId.value = '';
      _searchQuery.value = '';
      _searchResults.clear();

      final result = await _productRepository.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: 20,
      );

      final newProducts = result['products'] as List<Product>;
      _tabProducts[ProductTab.all] = newProducts;
      _tabHasMoreData[ProductTab.all] = result['hasNextPage'] ?? false;
      _tabPages[ProductTab.all] = 2;

      _updateCurrentProductsFromTab();

      print('✅ تم تحميل ${newProducts.length} منتجات للفئة $categoryId');

    } catch (e) {
      print('❌ خطأ في تحميل منتجات الفئة: $e');
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filter by subcategory (only for "All" tab)
  Future<void> filterBySubCategory(String subCategoryId,{int page=1}) async {
    if (_currentTab.value != ProductTab.all) {
      print('تصفية الفئات الفرعية متاحة فقط في تبويبة "الكل"');
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      _currentSubCategoryId.value = subCategoryId;
      _searchQuery.value = '';
      _searchResults.clear();

      final result = await _productRepository.getProductsBySubCategory(
        subCategoryId: subCategoryId,
        page: page,
        limit: 20,
      );

      final newProducts = result['products'] as List<Product>;
      _tabProducts[ProductTab.all] = newProducts;
      _tabHasMoreData[ProductTab.all] = result['hasNextPage'] ?? false;
      _tabPages[ProductTab.all] = 2;

      _updateCurrentProductsFromTab();

      print('تم تحميل ${newProducts.length} منتجات للفئة الفرعية $subCategoryId');

    } catch (e) {
      _errorMessage.value = e.toString();
      print('خطأ في تحميل منتجات الفئة الفرعية: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      return await _productRepository.getProductById(productId);
    } catch (e) {
      _errorMessage.value = e.toString();
      return null;
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _searchResults.clear();
    _updateCurrentProductsFromTab();
  }

  /// Clear category filter
  void clearCategoryFilter() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    if (_currentTab.value == ProductTab.all) {
      refreshCurrentTab();
    }
  }

  /// Clear subcategory filter
  void clearSubCategoryFilter() {
    _currentSubCategoryId.value = '';
    if (_currentTab.value == ProductTab.all) {
      refreshCurrentTab();
    }
  }

  /// Clear all filters
  void clearAllFilters() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    _searchResults.clear();

    if (_currentTab.value == ProductTab.all) {
      refreshCurrentTab();
    } else {
      _updateCurrentProductsFromTab();
    }
  }

  /// Check if filters are available for current tab
  bool get filtersAvailableForCurrentTab => _currentTab.value == ProductTab.all;

  /// Get tab statistics
  Map<String, dynamic> getTabStats(ProductTab tab) {
    return {
      'productsCount': _tabProducts[tab]?.length ?? 0,
      'isLoaded': _tabDataLoaded[tab] ?? false,
      'hasMoreData': _tabHasMoreData[tab] ?? false,
      'currentPage': _tabPages[tab] ?? 1,
    };
  }

  /// Reset specific tab
  void resetTab(ProductTab tab) {
    _resetTabState(tab);
  }

  /// Reset all data
  void resetAllData() {
    for (ProductTab tab in ProductTab.values) {
      _resetTabState(tab);
    }
    _currentProducts.clear();
    _searchResults.clear();
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    _errorMessage.value = '';
    _currentTab.value = ProductTab.all;
  }

  /// Check if has active filters
  bool get hasActiveFilters {
    return _currentCategoryId.isNotEmpty ||
        _currentSubCategoryId.isNotEmpty ||
        _searchQuery.isNotEmpty;
  }

  /// Get active filters description
  String get activeFiltersDescription {
    List<String> filters = [];

    if (_searchQuery.isNotEmpty) {
      filters.add('البحث: ${_searchQuery.value}');
    }
    if (_currentCategoryId.isNotEmpty) {
      filters.add('الفئة محددة');
    }
    if (_currentSubCategoryId.isNotEmpty) {
      filters.add('الفئة الفرعية محددة');
    }

    return filters.isEmpty ? 'لا توجد فلاتر' : filters.join(' | ');
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}