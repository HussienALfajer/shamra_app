import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/category.dart';
import '../../data/repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Observables
  final RxList<Category> _categories = <Category>[].obs;
  final RxList<Category> _categoryTree = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Category?> _selectedCategory = Rx<Category?>(null);

  // Getters
  List<Category> get categories => _categories;
  List<Category> get categoryTree => _categoryTree;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Category? get selectedCategory => _selectedCategory.value;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadCategoryTree();
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final categories = await _categoryRepository.getCategories(limit: 100);
      _categories.value = categories;

    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load category tree (hierarchical)
  Future<void> loadCategoryTree() async {
    try {
      final categoryTree = await _categoryRepository.getCategoryTree();
      _categoryTree.value = categoryTree;
    } catch (e) {
      _errorMessage.value = e.toString();
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String categoryId, {bool withChildren = false}) async {
    try {
      return await _categoryRepository.getCategoryById(categoryId, withChildren: withChildren);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load category: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  // Get category by slug
  Future<Category?> getCategoryBySlug(String slug, {bool withChildren = false}) async {
    try {
      return await _categoryRepository.getCategoryBySlug(slug, withChildren: withChildren);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load category: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  // Select category
  void selectCategory(Category? category) {
    _selectedCategory.value = category;
  }

  // Clear selected category
  void clearSelectedCategory() {
    _selectedCategory.value = null;
  }

  // Get parent categories only
  List<Category> get parentCategories {
    return _categories.where((category) => category.isParent).toList();
  }

  // Get subcategories for a parent category
  List<Category> getSubcategories(String parentId) {
    return _categories.where((category) => category.parentId == parentId).toList();
  }

  // Search categories
  List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) {
      return category.displayName.toLowerCase().contains(query.toLowerCase()) ||
             (category.displayDescription.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
    await loadCategoryTree();
  }
}