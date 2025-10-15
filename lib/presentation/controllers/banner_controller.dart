import 'package:get/get.dart';
import 'package:flutter/material.dart' hide Banner;
import '../../data/models/banner.dart';
import '../../data/repositories/banner_repository.dart';
import '../../routes/app_routes.dart';

class BannerController extends GetxController {
  final BannerRepository _bannerRepository = BannerRepository();

  // Observables
  final RxList<Banner> _banners = <Banner>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMoreData = true.obs;
  final RxBool _isLoadingMore = false.obs;

  // Getters
  List<Banner> get banners => _banners;

  List<Banner> get activeBanners =>
      _banners.where((banner) => banner.isActive).toList();

  bool get isLoading => _isLoading.value;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get hasMoreData => _hasMoreData.value;

  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
  }

  /// Load banners
  Future<void> loadBanners({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMoreData.value = true;
        _banners.clear();
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _bannerRepository.getBanners(
        page: _currentPage.value,
        limit: 20,
      );

      final newBanners = result['banners'] as List<Banner>;

      if (refresh) {
        _banners.value = newBanners;
      } else {
        _banners.addAll(newBanners);
      }

      _hasMoreData.value = result['hasNextPage'] ?? false;
      _currentPage.value++;

      print('تم تحميل ${newBanners.length} banner');
    } catch (e) {
      _errorMessage.value = e.toString();
      print('خطأ في تحميل البانرات: $e');

      Get.snackbar(
        'خطأ',
        'فشل تحميل البانرات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load more banners (pagination)
  Future<void> loadMoreBanners() async {
    if (_isLoadingMore.value || !_hasMoreData.value) return;

    try {
      _isLoadingMore.value = true;
      await loadBanners();
    } catch (e) {
      print('خطأ في تحميل المزيد من البانرات: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Refresh banners
  Future<void> refreshBanners() async {
    await loadBanners(refresh: true);
  }

  /// Handle banner tap
  void onBannerTap(Banner banner) {
    try {
      if (banner.hasProduct && banner.productId != null) {
        // Navigate to product details
        Get.toNamed(Routes.productDetails, arguments: banner.productId);
      } else if (banner.hasCategory && banner.categoryId != null) {
        // Navigate to category details
        Get.toNamed(
          Routes.categoryDetails,
          arguments: {
            'categoryId': banner.categoryId,
            'categoryName': banner.category?.name ?? 'Category',
          },
        );
      } else {
        // Show a message if banner has no action
        Get.snackbar(
          'معلومات',
          'هذا البانر للعرض فقط',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('خطأ في التنقل من البانر: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ في التنقل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Get banner by ID
  Future<Banner?> getBannerById(String bannerId) async {
    try {
      return await _bannerRepository.getBannerById(bannerId);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل البانر: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  /// Get banners by product
  Future<List<Banner>> getBannersByProduct(String productId) async {
    try {
      return await _bannerRepository.getBannersByProduct(productId);
    } catch (e) {
      _errorMessage.value = e.toString();
      return [];
    }
  }

  /// Get banners by category
  Future<List<Banner>> getBannersByCategory(String categoryId) async {
    try {
      return await _bannerRepository.getBannersByCategory(categoryId);
    } catch (e) {
      _errorMessage.value = e.toString();
      return [];
    }
  }

  /// Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  /// Get banner statistics
  Map<String, int> getBannerStats() {
    return {
      'totalBanners': _banners.length,
      'activeBanners': activeBanners.length,
      'productBanners': _banners.where((b) => b.hasProduct).length,
      'categoryBanners': _banners.where((b) => b.hasCategory).length,
    };
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}