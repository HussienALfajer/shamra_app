import '../models/sub_sub_category.dart';
import '../services/sub_sub_category_service.dart';

class SubSubCategoryRepository {
  // Get all sub-sub-categories
  Future<List<SubSubCategory>> getSubSubCategories({
    int page = 1,
    int limit = 50,
    String? subCategoryId,
    bool? isActive,
    String? search,
  }) async {
    try {
      return await SubSubCategoryService.getSubSubCategories(
        page: page,
        limit: limit,
        subCategoryId: subCategoryId,
        isActive: isActive,
        search: search,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-sub-categories by sub-category ID
  Future<List<SubSubCategory>> getSubSubCategoriesBySubCategory(
    String subCategoryId,
  ) async {
    try {
      return await SubSubCategoryService.getSubSubCategoriesBySubCategory(
        subCategoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get sub-sub-category by ID
  Future<SubSubCategory> getSubSubCategoryById(String id) async {
    try {
      return await SubSubCategoryService.getSubSubCategoryById(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get active sub-sub-categories only
  Future<List<SubSubCategory>> getActiveSubSubCategories({
    int page = 1,
    int limit = 50,
    String? subCategoryId,
  }) async {
    try {
      return await SubSubCategoryService.getActiveSubSubCategories(
        page: page,
        limit: limit,
        subCategoryId: subCategoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Search sub-sub-categories
  Future<List<SubSubCategory>> searchSubSubCategories({
    required String query,
    int page = 1,
    int limit = 50,
    String? subCategoryId,
  }) async {
    try {
      return await SubSubCategoryService.searchSubSubCategories(
        query: query,
        page: page,
        limit: limit,
        subCategoryId: subCategoryId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
