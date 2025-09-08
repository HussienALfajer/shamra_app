import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/sub_category.dart';
import '../../data/repositories/sub_category_repository.dart';

class SubCategoryController extends GetxController {
  final SubCategoryRepository _subCategoryRepository = SubCategoryRepository();

  // Observables
  final RxList<SubCategory> _subCategories = <SubCategory>[].obs;
  final RxList<SubCategory> _filteredSubCategories = <SubCategory>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<SubCategory?> _selectedSubCategory = Rx<SubCategory?>(null);
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategoryId = ''.obs;
  final Rx<SubCategoryType?> _selectedType = Rx<SubCategoryType?>(null);

  // Getters
  List<SubCategory> get subCategories => _subCategories;
  List<SubCategory> get filteredSubCategories => _filteredSubCategories;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  SubCategory? get selectedSubCategory => _selectedSubCategory.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCategoryId => _selectedCategoryId.value;
  SubCategoryType? get selectedType => _selectedType.value;

  @override
  void onInit() {
    super.onInit();
    loadSubCategories();
  }

  // Load all sub-categories
  Future<void> loadSubCategories({
    String? categoryId,
    bool? isActive = true,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final subCategories = await _subCategoryRepository.getSubCategories(
        limit: 100,
        categoryId: categoryId,
        isActive: isActive,
      );

      _subCategories.value = subCategories;
      _filteredSubCategories.value = subCategories;

      if (categoryId != null) {
        _selectedCategoryId.value = categoryId;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفئات الفرعية: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load sub-categories by category ID
  Future<void> loadSubCategoriesByCategory(String categoryId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _selectedCategoryId.value = categoryId;

      final subCategories = await _subCategoryRepository
          .getSubCategoriesByCategory(categoryId);
      _subCategories.value = subCategories;
      _filteredSubCategories.value = subCategories;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفئات الفرعية: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get sub-category by ID
  Future<SubCategory?> getSubCategoryById(String subCategoryId) async {
    try {
      return await _subCategoryRepository.getSubCategoryById(subCategoryId);
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفئة الفرعية: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  // Search sub-categories
  void searchSubCategories(String query) {
    _searchQuery.value = query;
    if (query.isEmpty) {
      _filteredSubCategories.value = _subCategories;
      return;
    }

    _filteredSubCategories.value = _subCategories.where((subCategory) {
      return subCategory.displayName.toLowerCase().contains(
        query.toLowerCase(),
      );
    }).toList();
  }

  // Filter by type
  void filterByType(SubCategoryType? type) {
    _selectedType.value = type;
    _applyFilters();
  }

  // Apply all active filters
  void _applyFilters() {
    List<SubCategory> filtered = List.from(_subCategories);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((subCategory) {
        return subCategory.displayName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }).toList();
    }

    // Apply type filter
    if (_selectedType.value != null) {
      filtered = filtered.where((subCategory) {
        return subCategory.type == _selectedType.value;
      }).toList();
    }

    _filteredSubCategories.value = filtered;
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery.value = '';
    _selectedType.value = null;
    _filteredSubCategories.value = _subCategories;
  }

  // Select sub-category
  void selectSubCategory(SubCategory? subCategory) {
    _selectedSubCategory.value = subCategory;
  }

  // Clear selected sub-category
  void clearSelectedSubCategory() {
    _selectedSubCategory.value = null;
  }

  // Get sub-categories by type
  List<SubCategory> getSubCategoriesByType(SubCategoryType type) {
    return _subCategories.where((subCategory) {
      return subCategory.type == type && subCategory.isActive;
    }).toList();
  }

  // Get custom field sub-categories
  List<SubCategory> getCustomFieldSubCategories() {
    return getSubCategoriesByType(SubCategoryType.customAttr);
  }

  // Get free attribute sub-categories
  List<SubCategory> getFreeAttributeSubCategories() {
    return getSubCategoriesByType(SubCategoryType.freeAttr);
  }

  // Get sub-categories with images
  List<SubCategory> getSubCategoriesWithImages() {
    return _subCategories.where((subCategory) {
      return subCategory.hasImage && subCategory.isActive;
    }).toList();
  }

  // Get active sub-categories only
  List<SubCategory> getActiveSubCategories() {
    return _subCategories.where((subCategory) => subCategory.isActive).toList();
  }

  // Load sub-categories by type
  Future<void> loadSubCategoriesByType(
    SubCategoryType type, {
    String? categoryId,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final subCategories = await _subCategoryRepository.getSubCategoriesByType(
        type: type,
        limit: 100,
        categoryId: categoryId,
      );

      _subCategories.value = subCategories;
      _filteredSubCategories.value = subCategories;
      _selectedType.value = type;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الفئات الفرعية: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Search sub-categories remotely
  Future<void> searchSubCategoriesRemote(
    String query, {
    String? categoryId,
  }) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final subCategories = await _subCategoryRepository.searchSubCategories(
        query: query,
        limit: 100,
        categoryId: categoryId,
      );

      _subCategories.value = subCategories;
      _filteredSubCategories.value = subCategories;
      _searchQuery.value = query;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في البحث: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Get sub-category count by category
  int getSubCategoryCountByCategory(String categoryId) {
    return _subCategories.where((subCategory) {
      return subCategory.categoryId == categoryId && subCategory.isActive;
    }).length;
  }

  // Check if sub-category exists
  bool subCategoryExists(String subCategoryId) {
    return _subCategories.any((subCategory) => subCategory.id == subCategoryId);
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  // Refresh sub-categories
  Future<void> refreshSubCategories() async {
    await loadSubCategories(
      categoryId: _selectedCategoryId.isNotEmpty
          ? _selectedCategoryId.value
          : null,
    );
  }

  // Reset controller state
  void reset() {
    _subCategories.clear();
    _filteredSubCategories.clear();
    _selectedSubCategory.value = null;
    _searchQuery.value = '';
    _selectedCategoryId.value = '';
    _selectedType.value = null;
    _errorMessage.value = '';
  }
}
