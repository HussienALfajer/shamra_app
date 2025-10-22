////////////////////////////////
// presentation/controllers/product_controller.dart  (updated)
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/models/user.dart';
import '../../data/repositories/product_repository.dart';
import 'auth_controller.dart';

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

  // Simple in-memory cache for fetched single product items.
  final Map<String, Product> _productCache = {};

  // Current state observables
  final Rx<ProductTab> _currentTab = ProductTab.all.obs;
  final List<Product> _currentProducts = <Product>[];
  final List<Product> _searchResults = <Product>[];

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

    final auth = Get.find<AuthController>();

    // Watch for user changes (login/logout/branch change)
    ever<User?>(auth.currentUserRx, (_) async {
      if (auth.hasBranchSelected) {
        resetAllData();
        await switchToTab(ProductTab.all, forceRefresh: true);
      } else {
        // clear data when no branch selected
        resetAllData();
      }
    });

    // Initial load if branch selected
    if (auth.hasBranchSelected) {
      switchToTab(ProductTab.all, forceRefresh: true);
    }
  }

  /// Switch to a specific tab and load data if needed
  Future<void> switchToTab(ProductTab tab, {bool forceRefresh = false}) async {
    _currentTab.value = tab;

    // ⬅️ اظهار شِمِر فوري بدل محتوى التبويب السابق
    _isLoading.value = true;
    _currentProducts.clear();
    update();

    if (!(_tabDataLoaded[tab] ?? false) || forceRefresh) {
      await _loadTabData(tab, refresh: true);
    } else {
      _updateCurrentProductsFromTab();
      _isLoading.value = false;  // ⬅️ نوقف التحميل لو البيانات جاهزة بالكاش
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

      // Pass category/subcategory/search to ALL tabs (featured/onSale included)
      switch (tab) {
        case ProductTab.all:
          result = await _productRepository.getProducts(
            page: currentPage,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: currentPage,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: currentPage,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
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

      if (_currentTab.value == tab) {
        _updateCurrentProductsFromTab();
      }

      debugPrint('Loaded ${newProducts.length} products for tab ${tab.toString()}');
    } catch (e) {
      _errorMessage.value = e.toString();
      debugPrint('Error loading products for tab ${tab.toString()}: $e');

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
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: currentPage,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: currentPage,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
      }

      final newProducts = result['products'] as List<Product>;

      _tabProducts[_currentTab.value]!.addAll(newProducts);
      _tabHasMoreData[_currentTab.value] = result['hasNextPage'] ?? false;
      _tabPages[_currentTab.value] = currentPage + 1;

      _updateCurrentProductsFromTab();

      debugPrint(
          'Loaded ${newProducts.length} more products for tab ${_currentTab.value.toString()}');
    } catch (e) {
      _errorMessage.value = e.toString();
      debugPrint('Error loading more products: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Refresh current tab data while keeping filters/search
  Future<void> refreshCurrentTab() async {
    debugPrint(
        '🔄 Refreshing tab: ${_currentTab.value} preserving filters search=${_searchQuery.value}, category=${_currentCategoryId.value}, sub=${_currentSubCategoryId.value}');
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      _tabPages[_currentTab.value] = 1;
      _tabHasMoreData[_currentTab.value] = true;

      Map<String, dynamic> result;

      // IMPORTANT: prefer subCategory > category
      switch (_currentTab.value) {
        case ProductTab.all:
          if (_currentSubCategoryId.value.isNotEmpty) {
            result = await _productRepository.getProductsBySubCategory(
              subCategoryId: _currentSubCategoryId.value,
              page: 1,
              limit: 20,
              search:
              _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
            );
          } else if (_currentCategoryId.value.isNotEmpty) {
            result = await _productRepository.getProductsByCategory(
              categoryId: _currentCategoryId.value,
              page: 1,
              limit: 20,
              search:
              _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
            );
          } else {
            result = await _productRepository.getProducts(
              page: 1,
              limit: 20,
              search:
              _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
            );
          }
          break;

        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: 1,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;

        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: 1,
            limit: 20,
            categoryId:
            _currentCategoryId.value.isNotEmpty ? _currentCategoryId.value : null,
            subCategoryId: _currentSubCategoryId.value.isNotEmpty
                ? _currentSubCategoryId.value
                : null,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
      }

      final newProducts = result['products'] as List<Product>;
      _tabProducts[_currentTab.value] = newProducts;
      _tabHasMoreData[_currentTab.value] = result['hasNextPage'] ?? false;
      _tabPages[_currentTab.value] = 2;
      _tabDataLoaded[_currentTab.value] = true;

      _updateCurrentProductsFromTab();
      debugPrint('✅ Refreshed ${newProducts.length} products');
    } catch (e) {
      _errorMessage.value = e.toString();
      debugPrint('❌ Error refreshing tab: $e');

      if (Get.context != null) {
        Get.snackbar(
          'خطأ',
          'فشل في تحديث البيانات: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void _updateCurrentProductsFromTab() {
    _currentProducts
      ..clear()
      ..addAll(_tabProducts[_currentTab.value] ?? []);
    update(); // notify GetBuilder
  }

  void _resetTabState(ProductTab tab) {
    _tabProducts[tab] = [];
    _tabPages[tab] = 1;
    _tabHasMoreData[tab] = true;
    _tabDataLoaded[tab] = false;
  }

  Future<void> searchProducts(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      await refreshCurrentTab();
      return;
    }
    await _loadTabData(_currentTab.value, refresh: true);
  }

  Future<void> getProductsByCategory(String categoryId, {int page = 1}) async {
    if (_currentTab.value != ProductTab.all) {
      // Apply filters to the current tab as well (featured/onSale supported downstream)
      _currentCategoryId.value = categoryId;
      _currentSubCategoryId.value = '';
      await _loadTabData(_currentTab.value, refresh: true);
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      _currentCategoryId.value = categoryId;
      _currentSubCategoryId.value = '';

      final result = await _productRepository.getProductsByCategory(
        categoryId: categoryId,
        page: page,
        limit: 20,
        search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      );

      final newProducts = result['products'] as List<Product>;
      _tabProducts[ProductTab.all] = newProducts;
      _tabHasMoreData[ProductTab.all] = result['hasNextPage'] ?? false;
      _tabPages[ProductTab.all] = 2;

      _updateCurrentProductsFromTab();
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> filterBySubCategory(String subCategoryId, {int page = 1}) async {
    if (_currentTab.value != ProductTab.all) {
      _currentSubCategoryId.value = subCategoryId;
      await _loadTabData(_currentTab.value, refresh: true);
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      _currentSubCategoryId.value = subCategoryId;

      final result = await _productRepository.getProductsBySubCategory(
        subCategoryId: subCategoryId,
        page: page,
        limit: 20,
        search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
      );

      final newProducts = result['products'] as List<Product>;
      _tabProducts[ProductTab.all] = newProducts;
      _tabHasMoreData[ProductTab.all] = result['hasNextPage'] ?? false;
      _tabPages[ProductTab.all] = 2;

      _updateCurrentProductsFromTab();
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Product?> getProductById(String productId) async {
    if (_productCache.containsKey(productId)) return _productCache[productId];

    try {
      final p = await _productRepository.getProductById(productId);
      if (p != null) {
        _productCache[productId] = p;
      }
      return p;
    } catch (e) {
      _errorMessage.value = e.toString();
      return null;
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    refreshCurrentTab();
  }

  void clearCategoryFilter() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    refreshCurrentTab();
  }

  void clearSubCategoryFilter() {
    _currentSubCategoryId.value = '';
    refreshCurrentTab();
  }

  void clearAllFilters() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    refreshCurrentTab();
  }

  bool get searchAvailableForCurrentTab => true;

  // NOW: category filters shown in ALL tabs
  bool get categoryFiltersAvailableForCurrentTab => true;

  Map<String, dynamic> getTabStats(ProductTab tab) {
    return {
      'productsCount': _tabProducts[tab]?.length ?? 0,
      'isLoaded': _tabDataLoaded[tab] ?? false,
      'hasMoreData': _tabHasMoreData[tab] ?? false,
      'currentPage': _tabPages[tab] ?? 1,
    };
  }

  void resetTab(ProductTab tab) {
    _resetTabState(tab);
  }

  void resetAllData() {
    for (ProductTab tab in ProductTab.values) {
      _resetTabState(tab);
    }
    _currentProducts.clear();
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    _errorMessage.value = '';
    update();
  }

  bool get hasActiveFilters =>
      _currentCategoryId.value.isNotEmpty ||
          _currentSubCategoryId.value.isNotEmpty ||
          _searchQuery.value.isNotEmpty;
}
