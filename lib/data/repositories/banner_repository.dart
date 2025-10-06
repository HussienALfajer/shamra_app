import '../models/banner.dart';
import '../services/banner_service.dart';

class BannerRepository {
  // Get all banners
  Future<Map<String, dynamic>> getBanners({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await BannerService.getBanners(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get active banners only
  Future<Map<String, dynamic>> getActiveBanners({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await BannerService.getActiveBanners(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get banner by ID
  Future<Banner> getBannerById(String bannerId) async {
    try {
      return await BannerService.getBannerById(bannerId);
    } catch (e) {
      rethrow;
    }
  }

  // Get banners by product ID
  Future<List<Banner>> getBannersByProduct(String productId) async {
    try {
      return await BannerService.getBannersByProduct(productId);
    } catch (e) {
      rethrow;
    }
  }

  // Get banners by category ID
  Future<List<Banner>> getBannersByCategory(String categoryId) async {
    try {
      return await BannerService.getBannersByCategory(categoryId);
    } catch (e) {
      rethrow;
    }
  }
}