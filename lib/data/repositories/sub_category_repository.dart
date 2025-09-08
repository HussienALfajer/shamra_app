import '../models/sub_category.dart';
import '../services/sub_category_service.dart';

class SubCategoryRepository {
  // Get all sub-categories
  Future<List<SubCategory>> getSubCategories({
    int page = 1,
    int limit = 50,
    String? categoryId,
    bool? isActive,
    String? search,
  }) async {
    try {
      return await SubCategoryService.getSubCategories(
        page: page,
        limit: limit,
        categoryId: categoryId,
        isActive: isActive,
        search: search,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-categories by category ID
  Future<List<SubCategory>> getSubCategoriesByCategory(
    String categoryId,
  ) async {
    try {
      return await SubCategoryService.getSubCategoriesByCategory(categoryId);
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-category by ID
  Future<SubCategory> getSubCategoryById(String subCategoryId) async {
    try {
      return await SubCategoryService.getSubCategoryById(subCategoryId);
    } catch (e) {
      rethrow;
    }
  }

  // Get active sub-categories only
  Future<List<SubCategory>> getActiveSubCategories({
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    try {
      return await SubCategoryService.getActiveSubCategories(
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Search sub-categories
  Future<List<SubCategory>> searchSubCategories({
    required String query,
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    try {
      return await SubCategoryService.searchSubCategories(
        query: query,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-categories by type
  Future<List<SubCategory>> getSubCategoriesByType({
    required SubCategoryType type,
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    try {
      return await SubCategoryService.getSubCategoriesByType(
        type: type,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-categories with custom fields only
  Future<List<SubCategory>> getCustomFieldSubCategories({
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    try {
      return await SubCategoryService.getSubCategoriesByType(
        type: SubCategoryType.customAttr,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-categories with free attributes only
  Future<List<SubCategory>> getFreeAttributeSubCategories({
    int page = 1,
    int limit = 50,
    String? categoryId,
  }) async {
    try {
      return await SubCategoryService.getSubCategoriesByType(
        type: SubCategoryType.freeAttr,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
