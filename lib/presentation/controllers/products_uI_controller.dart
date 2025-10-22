///////////////////////////////////////////////
// presentation/controllers/products_ui_controller.dart  (NEW - extracted)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/main_controller.dart';
import 'package:shamra_app/presentation/controllers/product_controller.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';

/// UI controller for Products page - extracted from page file
/// Manages UI state (search visibility, selected filters, scroll listener, etc.)
class ProductsUIController extends GetxController {
  final searchController = TextEditingController();
  late PageController _pageController;

  final RxBool _showSearchField = false.obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;
  final RxInt _currentTabIndex = 0.obs;
  int _lastAnimationIndex = -1;

  bool _tabListenerAttached = false; // ensure listener is added once

  bool get showSearchField => _showSearchField.value;
  String get selectedCategoryId => _selectedCategoryId.value;
  String get selectedSubCategoryId => _selectedSubCategoryId.value;
  int get currentTabIndex => _currentTabIndex.value;
  PageController get pageController => _pageController;

  @override
  void onInit() {
    super.onInit();
    _pageController = PageController(initialPage: 0);
    _setupScrollListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    _pageController.dispose();
    _removeScrollListener();
    super.onClose();
  }

  void initializePageController(int initialPage) {
    if (_pageController.hasClients && initialPage != _currentTabIndex.value) {
      _pageController.jumpToPage(initialPage);
    }
  }

  void _setupScrollListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final scrollController =
            Get.find<MainController>().productsScrollController;
        scrollController.addListener(_onScroll);
      } catch (e) {
        debugPrint('Error setting scroll listener: $e');
      }
    });
  }

  void _removeScrollListener() {
    try {
      final scrollController =
          Get.find<MainController>().productsScrollController;
      scrollController.removeListener(_onScroll);
    } catch (e) {
      debugPrint('Error removing scroll listener: $e');
    }
  }

  void _onScroll() {
    try {
      final scrollController =
          Get.find<MainController>().productsScrollController;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        final productController = Get.find<ProductController>();
        if (!productController.isLoadingMore && productController.hasMoreData) {
          productController.loadMoreProducts();
        }
      }
    } catch (e) {
      debugPrint('Error handling scroll: $e');
    }
  }

  /// Attach TabController listener (added once) to keep tab index & data in sync
  void attachTabControllerListenerOnce(
      TabController tc, {
        required void Function(int index) onIndexChanged,
      }) {
    if (_tabListenerAttached) return;
    _tabListenerAttached = true;

    // يعمل مع السحب Swipe بين التبويبات
    tc.animation?.addListener(() {
      final v = tc.animation!.value;
      final idx = v.round();
      if (idx != _lastAnimationIndex) {
        _lastAnimationIndex = idx;
        onIndexChanged(idx);
      }
    });

    // يبقى المستمع الأصلي للاحتياط
    tc.addListener(() {
      if (!tc.indexIsChanging) {
        onIndexChanged(tc.index);
      }
    });
  }

  /// Tab change logic: clear filters only when switching to/from the "All" tab.
  void changeTab(int index) {
    final oldIndex = _currentTabIndex.value;
    if (oldIndex == index) return;

    _currentTabIndex.value = index;

    // hide search on tab change
    if (_showSearchField.value) _showSearchField.value = false;

    // Clear filters only when switching to or from the "All" tab (UI-only)
    if ((oldIndex == 0 && index != 0) || (oldIndex != 0 && index == 0)) {
      clearFiltersOnly();
    }

    update();
  }

  void toggleSearch() {
    _showSearchField.value = !_showSearchField.value;
    if (!_showSearchField.value) {
      clearSearch();
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    try {
      final productController = Get.find<ProductController>();
      productController.clearSearch();
    } catch (_) {}
  }

  void onSearchChanged(String value) {
    try {
      final productController = Get.find<ProductController>();
      productController.searchProducts(value);
    } catch (_) {}
  }

  void onCategoryChanged(String? value) async {
    _selectedCategoryId.value = value ?? '';
    _selectedSubCategoryId.value = '';

    try {
      final productController = Get.find<ProductController>();
      final subCategoryController = Get.find<SubCategoryController>();

      if (value?.isNotEmpty == true) {
        subCategoryController.clearFilters();
        update();

        await subCategoryController.loadSubCategoriesByCategory(value!);
        // Always filter the current active tab using category
        await productController.getProductsByCategory(value!);
      } else {
        productController.clearCategoryFilter();
        subCategoryController.clearFilters();
      }
    } catch (_) {}
    update();
  }

  void onSubCategoryChanged(String? value) {
    _selectedSubCategoryId.value = value ?? '';

    try {
      final productController = Get.find<ProductController>();

      if (value?.isNotEmpty == true) {
        productController.filterBySubCategory(value!);
      } else {
        if (_selectedCategoryId.value.isNotEmpty) {
          productController.getProductsByCategory(_selectedCategoryId.value);
        } else {
          productController.clearSubCategoryFilter();
        }
      }
    } catch (_) {}
    update();
  }

  void clearFiltersOnly() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    update();
  }

  void clearAllFilters() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    searchController.clear();
    update();
  }


}
