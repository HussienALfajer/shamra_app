import '../models/category.dart';
import '../services/category_service.dart';

class CategoryRepository {
  // Get all categories
  Future<List<Category>> getCategories({int page = 1, int limit = 50}) async {
    try {
      return await CategoryService.getCategories(page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  // Get category tree (hierarchical structure)
  // Future<List<Category>> getCategoryTree() async {
  //   try {
  //     return await CategoryService.getCategoryTree();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Get category by ID
  Future<Category> getCategoryById(
    String categoryId, {
    bool withChildren = false,
  }) async {
    try {
      return await CategoryService.getCategoryById(
        categoryId,
        withChildren: withChildren,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get category by slug
  Future<Category> getCategoryBySlug(
    String slug, {
    bool withChildren = false,
  }) async {
    try {
      return await CategoryService.getCategoryBySlug(
        slug,
        withChildren: withChildren,
      );
    } catch (e) {
      rethrow;
    }
  }
}
