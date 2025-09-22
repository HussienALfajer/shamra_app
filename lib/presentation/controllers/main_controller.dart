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
/// - إدارة التنقل بين التبويبات في MainPage
class MainController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();

  // --- 🔹 التنقل بين التبويبات ---
  final RxInt currentIndex = 0.obs; // التبويب الحالي
  void changeTab(int index) => currentIndex.value = index;

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
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في تحميل البيانات: $e',
        type: SnackBarType.error,
      );
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
      print('Error loading featured products: $e');
    }
  }

  // --- 🔹 تحميل المنتجات المخفّضة ---
  Future<void> loadOnSaleProducts() async {
    try {
      final products = await _productRepository.getOnSaleProducts(limit: 10);
      _onSaleProducts.value = products['products'];
    } catch (e) {
      print('Error loading on sale products: $e');
    }
  }

  // --- 🔹 تحميل أحدث المنتجات ---
  Future<void> loadRecentProducts() async {
    try {
      final result = await _productRepository.getProducts(page: 1, limit: 20);
      _recentProducts.value = result['products'] as List<Product>;
    } catch (e) {
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
      print('Error loading categories: $e');
    } finally {
      _isLoadingCategories.value = false;
    }
  }
  Future<void> loadBanners() async {
    try {
      BannerController bannerController= Get.find<BannerController>();
       await bannerController.loadBanners(refresh: true);
    } catch (e) {
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
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في البحث: $e',
        type: SnackBarType.error,
      );
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
