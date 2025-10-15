import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../data/models/user.dart';
import '../../data/repositories/product_repository.dart';
import 'auth_controller.dart'; // تأكد من استيراد AuthController

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

    // راقب تغيّرات المستخدم (تسجيل دخول/خروج أو تحديثات)
    ever<User?>(auth.currentUserRx, (_) async {
      if (auth.hasBranchSelected) {
        resetAllData();
        await switchToTab(ProductTab.all, forceRefresh: true);
      } else {
        // لو ما في فرع مختار امسح البيانات
        resetAllData();
      }
    });

    // تحميل أولي إذا كان في جلسة وفرع محفوظين
    if (auth.hasBranchSelected) {
      switchToTab(ProductTab.all, forceRefresh: true);
    }
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
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: currentPage,
            limit: 20,
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
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: currentPage,
            limit: 20,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
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

  /// Refresh current tab data with maintaining current filters and search
  Future<void> refreshCurrentTab() async {
    print('🔄 بدء تحديث التبويب: ${_currentTab.value} مع الحفاظ على الفلاتر');
    print('📊 الحالة الحالية:');
    print('  - البحث: ${_searchQuery.value}');
    print('  - الفئة: ${_currentCategoryId.value}');
    print('  - الفئة الفرعية: ${_currentSubCategoryId.value}');

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // إعادة تعيين الصفحة للبداية
      _tabPages[_currentTab.value] = 1;
      _tabHasMoreData[_currentTab.value] = true;

      Map<String, dynamic> result;

      switch (_currentTab.value) {
        case ProductTab.all:
        // للتبويب "الكل" نحتاج للتحقق من الفلاتر النشطة
          if (_currentCategoryId.value.isNotEmpty) {
            // إذا كان هناك فئة مختارة
            result = await _productRepository.getProductsByCategory(
              categoryId: _currentCategoryId.value,
              page: 1,
              limit: 20,
              search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
            );
          } else if (_currentSubCategoryId.value.isNotEmpty) {
            // إذا كانت هناك فئة فرعية مختارة
            result = await _productRepository.getProductsBySubCategory(
              subCategoryId: _currentSubCategoryId.value,
              page: 1,
              limit: 20,
              search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
            );
          } else {
            // بحث أو عرض عام
            result = await _productRepository.getProducts(
              page: 1,
              limit: 20,
              search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
            );
          }
          break;

        case ProductTab.featured:
          result = await _productRepository.getFeaturedProducts(
            page: 1,
            limit: 20,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;

        case ProductTab.onSale:
          result = await _productRepository.getOnSaleProducts(
            page: 1,
            limit: 20,
            search: _searchQuery.value.isNotEmpty ? _searchQuery.value : null,
          );
          break;
      }

      final newProducts = result['products'] as List<Product>;

      // تحديث البيانات
      _tabProducts[_currentTab.value] = newProducts;
      _tabHasMoreData[_currentTab.value] = result['hasNextPage'] ?? false;
      _tabPages[_currentTab.value] = 2; // الصفحة التالية
      _tabDataLoaded[_currentTab.value] = true;

      // تحديث المنتجات الحالية
      _updateCurrentProductsFromTab();

      print('✅ تم تحديث ${newProducts.length} منتجات بنجاح');

    } catch (e) {
      _errorMessage.value = e.toString();
      print('❌ خطأ في تحديث التبويب: $e');

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

  /// Update current products from active tab
  void _updateCurrentProductsFromTab() {
    _currentProducts.clear();
    _currentProducts.addAll(_tabProducts[_currentTab.value] ?? []);
    update(); // إخبار GetBuilder بالتحديث
  }

  /// Reset tab state for refresh
  void _resetTabState(ProductTab tab) {
    _tabProducts[tab] = [];
    _tabPages[tab] = 1;
    _tabHasMoreData[tab] = true;
    _tabDataLoaded[tab] = false;
  }

  /// Search products in current tab context - محدث للعمل مع كل التبويبات
  Future<void> searchProducts(String query) async {
    _searchQuery.value = query;

    if (query.isEmpty) {
      // إعادة تحميل البيانات الأصلية للتبويب الحالي
      await refreshCurrentTab();
      return;
    }

    // إعادة تحميل البيانات مع البحث
    await _loadTabData(_currentTab.value, refresh: true);
  }

  /// Filter by category (only for "All" tab)
  Future<void> getProductsByCategory(String categoryId, {int page = 1}) async {
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
      // لا نقوم بمسح البحث هنا للسماح بالبحث داخل الفئة

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

      print('✅ تم تحميل ${newProducts.length} منتجات للفئة $categoryId');

    } catch (e) {
      print('❌ خطأ في تحميل منتجات الفئة: $e');
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Filter by subcategory (only for "All" tab)
  Future<void> filterBySubCategory(String subCategoryId, {int page = 1}) async {
    if (_currentTab.value != ProductTab.all) {
      print('تصفية الفئات الفرعية متاحة فقط في تبويبة "الكل"');
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      _currentSubCategoryId.value = subCategoryId;
      // لا نقوم بمسح البحث هنا للسماح بالبحث داخل الفئة الفرعية

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
    refreshCurrentTab();
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

  /// Clear all filters - محدث للتعامل مع البحث في كل التبويبات
  void clearAllFilters() {
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    refreshCurrentTab();
  }

  /// Check if search is available for current tab - البحث متاح لكل التبويبات الآن
  bool get searchAvailableForCurrentTab => true;

  /// Check if category/subcategory filters are available for current tab - الفلاتر متاحة فقط للتبويب "الكل"
  bool get categoryFiltersAvailableForCurrentTab => _currentTab.value == ProductTab.all;

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
    _currentCategoryId.value = '';
    _currentSubCategoryId.value = '';
    _searchQuery.value = '';
    _errorMessage.value = '';
    // لا نقوم بإعادة تعيين التبويب الحالي، فقط البيانات
    update();
  }

  /// Check if has active filters
  bool get hasActiveFilters =>
      _currentCategoryId.value.isNotEmpty ||
          _currentSubCategoryId.value.isNotEmpty ||
          _searchQuery.value.isNotEmpty;
}