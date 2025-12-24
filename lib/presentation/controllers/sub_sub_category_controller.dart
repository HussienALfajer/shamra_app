import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/sub_sub_category.dart';
import '../../data/repositories/sub_sub_category_repository.dart';

class SubSubCategoryController extends GetxController {
  final SubSubCategoryRepository _repository = SubSubCategoryRepository();

  // Observables
  final RxList<SubSubCategory> _subSubCategories = <SubSubCategory>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<SubSubCategory?> _selectedSubSubCategory =
      Rx<SubSubCategory?>(null);
  final RxString _selectedSubCategoryId = ''.obs;

  // Getters
  List<SubSubCategory> get subSubCategories => _subSubCategories;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  SubSubCategory? get selectedSubSubCategory => _selectedSubSubCategory.value;
  String get selectedSubCategoryId => _selectedSubCategoryId.value;
  bool get hasSubSubCategories => _subSubCategories.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
  }

  // Load sub-sub-categories by sub-category ID
  Future<void> loadSubSubCategoriesBySubCategory(String subCategoryId) async {
    // Skip if already loaded for this sub-category
    if (_selectedSubCategoryId.value == subCategoryId &&
        _subSubCategories.isNotEmpty) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      _selectedSubCategoryId.value = subCategoryId;
      _selectedSubSubCategory.value = null; // Clear previous selection

      final items = await _repository.getSubSubCategoriesBySubCategory(
        subCategoryId,
      );
      _subSubCategories.value = items;
    } catch (e) {
      _errorMessage.value = e.toString();
      _subSubCategories.clear();
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

  // Select sub-sub-category
  void selectSubSubCategory(SubSubCategory? subSubCategory) {
    _selectedSubSubCategory.value = subSubCategory;
  }

  // Clear selected sub-sub-category
  void clearSelectedSubSubCategory() {
    _selectedSubSubCategory.value = null;
  }

  // Clear all data when sub-category changes
  void clearSubSubCategories() {
    _subSubCategories.clear();
    _selectedSubSubCategory.value = null;
    _selectedSubCategoryId.value = '';
    _errorMessage.value = '';
  }

  // Get active sub-sub-categories only
  List<SubSubCategory> getActiveSubSubCategories() {
    return _subSubCategories
        .where((subSubCategory) => subSubCategory.isActive)
        .toList();
  }

  // Get sub-sub-categories with images
  List<SubSubCategory> getSubSubCategoriesWithImages() {
    return _subSubCategories.where((subSubCategory) {
      return subSubCategory.hasImage && subSubCategory.isActive;
    }).toList();
  }

  // Check if sub-sub-category exists
  bool subSubCategoryExists(String id) {
    return _subSubCategories.any((subSubCategory) => subSubCategory.id == id);
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  // Reset controller state
  void reset() {
    _subSubCategories.clear();
    _selectedSubSubCategory.value = null;
    _selectedSubCategoryId.value = '';
    _errorMessage.value = '';
    _isLoading.value = false;
  }
}
