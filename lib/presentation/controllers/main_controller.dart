import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shamra_app/presentation/controllers/banner_controller.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../widgets/common_widgets.dart'; // ✅ لإستخدام ShamraSnackBar

/// 🔹 MainController
/// - مسؤول عن إدارة البيانات المعروضة في الصفحة الرئيسية (MainPage / CustomerHomePage)
/// - تحميل المنتجات (مميزة، تخفيضات، حديثة) + الفئات
/// - البحث عن المنتجات
/// - إدارة التنقل بين التبويبات في MainPage + سلوك الرجوع
class MainController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // --- 🔹 التنقل بين التبويبات ---
  final RxInt currentIndex = 0.obs; // التبويب الحالي

  // ✅ ابدأ بتاريخ يحتوي التبويب 0 للرئيسية
  final List<int> _tabHistory = [0];

  /// استدعِ هذي من الـ BottomNav (أو أي مكان) عند الضغط على تبويب
  void onNavTap(int index) {
    if (currentIndex.value == index) {
      // نفس التبويب: مرّر للأعلى
      scrollToTop(index);
      return;
    }
    _pushHistoryIfNeeded(currentIndex.value);
    currentIndex.value = index;

    // بعد التبديل، ارجع السكروول لبداية الصفحة (jump سريع)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToTop(index, animate: false);
    });
  }

  /// استخدمها للتبديل البرمجي بين التبويبات (من صفحات ثانية)
  void changeTab(int index) {
    if (currentIndex.value == index) return;
    _pushHistoryIfNeeded(currentIndex.value);
    currentIndex.value = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToTop(index, animate: false);
    });
  }

  /// رجوع إلى التبويب السابق إن وُجد. تُرجع true إذا تم التعامل مع الرجوع.
// داخل MainController
  bool backToPreviousTab() {
    debugPrint('[MainController] back | currentIndex=${currentIndex.value}');

    // لو لسنا على الرئيسية → ارجع للرئيسية واستهلك الرجوع
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToTop(0, animate: false);
      });
      return true; // استهلكنا الرجوع
    }
    // نحن أصلًا على الرئيسية → اسمح للنظام بالخروج
    return false;

  }

  void _pushHistoryIfNeeded(int index) {
    if (_tabHistory.isEmpty || _tabHistory.last != index) {
      _tabHistory.add(index);
    }
  }

  // --- 🔹 بيانات المنتجات والفئات ---
  final RxList<Product> _featuredProducts = <Product>[].obs;
  final RxList<Product> _onSaleProducts = <Product>[].obs;
  final RxList<Product> _recentProducts = <Product>[].obs;
  final RxList<Category> _categories = <Category>[].obs;
  final RxList<Product> _searchResults = <Product>[].obs;

  // --- 🔹 الحالة ---
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingCategories = false.obs;
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _errorMessage = ''.obs;

  // --- 🔹 أدوات البحث ---
  final TextEditingController searchController = TextEditingController();

  // --- 🔹 Getters ---
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

  // ---------------- Scroll-to-top support ----------------
  final homeScrollController = ScrollController();
  final productsScrollController = ScrollController();
  final cartScrollController = ScrollController();
  final ordersScrollController = ScrollController();
  final profileScrollController = ScrollController();

  /// مرّر لأعلى الصفحة للتبويب المحدد
  void scrollToTop(int index, {bool animate = true}) {
    ScrollController? c;
    switch (index) {
      case 0:
        c = homeScrollController;
        break;
      case 1:
        c = productsScrollController;
        break;
      case 2:
        c = cartScrollController;
        break;
      case 3:
        c = ordersScrollController;
        break;
      case 4:
        c = profileScrollController;
        break;
    }
    if (c != null && c.hasClients) {
      if (animate) {
        c.animateTo(0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut);
      } else {
        c.jumpTo(0);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  @override
  void onClose() {
    homeScrollController.dispose();
    productsScrollController.dispose();
    cartScrollController.dispose();
    ordersScrollController.dispose();
    profileScrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // --- 🔹 تحميل البيانات الأولية ---
  Future<void> loadInitialData() async {
    _errorMessage.value = '';
    _isLoading.value = true;

    try {
      await Future.wait([
        loadFeaturedProducts(),
        loadOnSaleProducts(),
        loadRecentProducts(),
        loadCategories(),
        loadBanners(),
      ]);
    } catch (e) {
      _errorMessage.value = e.toString();
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'فشل في تحميل البيانات: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }

  // --- 🔹 تحميل المنتجات المميزة ---
  Future<void> loadFeaturedProducts() async {
    try {
      final products = await _productRepository.getFeaturedProducts(limit: 10);
      _featuredProducts.value = products['products'];
    } catch (e) {
      // ignore: avoid_print
      print('Error loading featured products: $e');
    }
  }

  // --- 🔹 تحميل المنتجات المخفّضة ---
  Future<void> loadOnSaleProducts() async {
    try {
      final products = await _productRepository.getOnSaleProducts(limit: 10);
      _onSaleProducts.value = products['products'];
    } catch (e) {
      // ignore: avoid_print
      print('Error loading on sale products: $e');
    }
  }

  // --- 🔹 تحميل أحدث المنتجات ---
  Future<void> loadRecentProducts() async {
    try {
      final result = await _productRepository.getProducts(page: 1, limit: 20);
      _recentProducts.value = result['products'] as List<Product>;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading recent products: $e');
    }
  }

  // --- 🔹 تحميل الفئات ---
  Future<void> loadCategories() async {
    try {
      _isLoadingCategories.value = true;
      final categories = await _categoryRepository.getCategories();
      _categories.value = categories.take(8).toList(); // فقط أول 8
    } catch (e) {
      // ignore: avoid_print
      print('Error loading categories: $e');
    } finally {
      _isLoadingCategories.value = false;
    }
  }

  Future<void> loadBanners() async {
    try {
      BannerController bannerController = Get.find<BannerController>();
      await bannerController.loadBanners(refresh: true);
    } catch (e) {
      // ignore: avoid_print
      print('Error loading Banners: $e');
    }
  }

  // --- 🔹 البحث ---
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
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'فشل في البحث: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      _isSearching.value = false;
    }
  }

  // --- 🔹 مسح البحث ---
  void clearSearch() {
    searchController.clear();
    _searchResults.clear();
    _searchQuery.value = '';
  }

  // --- 🔹 تحديث البيانات ---
  Future<void> refreshData() async {
    await loadInitialData();
  }

  // --- 🔹 التنقل ---
  void goToProductDetails(Product product) {
    Get.toNamed('/product-details', arguments: product);
  }

  void goToCategoryProducts(Category category) {
    Get.toNamed('/products-by-category', arguments: category);
  }

  void goToAllCategories() {
    Get.toNamed('/categories');
  }

  void goToAllFeaturedProducts() {
    Get.toNamed('/products', arguments: {'featured': true});
  }

  void goToAllSaleProducts() {
    Get.toNamed('/products', arguments: {'onSale': true});
  }

  void goToSearchPage() {
    Get.toNamed('/search');
  }
}