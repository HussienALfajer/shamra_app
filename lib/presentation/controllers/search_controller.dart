// lib/presentation/controllers/search_controller.dart
// Search controller with filters, suggestions, pagination and local filtering.
// EN comments only.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:shamra_app/core/services/storage_service.dart';
import 'package:shamra_app/data/models/product.dart';
import 'package:shamra_app/data/models/category.dart';
import 'package:shamra_app/data/models/sub_category.dart';
import 'package:shamra_app/data/repositories/product_repository.dart';
import 'package:shamra_app/data/repositories/category_repository.dart';
import 'package:shamra_app/data/repositories/sub_category_repository.dart';
import 'package:shamra_app/presentation/widgets/common_widgets.dart';

class SearchController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final SubCategoryRepository _subCategoryRepository = SubCategoryRepository();

  final RxList<Product> _searchResults = <Product>[].obs;
  final RxList<Product> _filteredResults = <Product>[].obs;
  final RxBool _isSearching = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;

  final RxList<Category> _categories = <Category>[].obs;
  final RxList<SubCategory> _subCategories = <SubCategory>[].obs;
  final RxList<String> _brands = <String>[].obs;

  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;
  final RxString _selectedBrand = ''.obs;
  final RxString _sortBy = 'relevance'.obs;
  final RxBool _showOnlyInStock = false.obs;
  final RxBool _showOnlyOnSale = false.obs;
  final RxBool _showOnlyFeatured = false.obs;

  final RxDouble _minPrice = 0.0.obs;
  final RxDouble _maxPrice = 10000.0.obs;
  final RxDouble _currentMinPrice = 0.0.obs;
  final RxDouble _currentMaxPrice = 10000.0.obs;

  final RxDouble _minRating = 0.0.obs;

  final RxBool _showFilters = false.obs;
  final RxBool _isAdvancedSearch = false.obs;

  final RxList<String> _searchHistory = <String>[].obs;
  final RxList<String> _searchSuggestions = <String>[].obs;
  final RxList<String> _popularSearches = <String>[].obs;

  final TextEditingController searchTextController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  final RxInt _currentPage = 1.obs;
  final RxBool _hasNextPage = true.obs;

  // NEW: track if a real search has been triggered (button/enter/filters)
  final RxBool _hasSearched = false.obs;

  List<Product> get searchResults => _searchResults;

  List<Product> get filteredResults => _filteredResults;

  List<Category> get categories => _categories;

  List<SubCategory> get subCategories => _subCategories;

  List<String> get brands => _brands;

  List<String> get searchHistory => _searchHistory;

  List<String> get searchSuggestions => _searchSuggestions;

  List<String> get popularSearches => _popularSearches;

  bool get isSearching => _isSearching.value;

  bool get isLoadingMore => _isLoadingMore.value;

  bool get showFilters => _showFilters.value;

  bool get isAdvancedSearch => _isAdvancedSearch.value;

  bool get hasActiveFilters => _hasActiveFilters();

  bool get hasNextPage => _hasNextPage.value;

  bool get hasSearched => _hasSearched.value; // NEW

  String get searchQuery => _searchQuery.value;

  String get selectedCategoryId => _selectedCategoryId.value;

  String get selectedSubCategoryId => _selectedSubCategoryId.value;

  String get selectedBrand => _selectedBrand.value;

  String get sortBy => _sortBy.value;

  String get errorMessage => _errorMessage.value;

  bool get showOnlyInStock => _showOnlyInStock.value;

  bool get showOnlyOnSale => _showOnlyOnSale.value;

  bool get showOnlyFeatured => _showOnlyFeatured.value;

  double get minPrice => _minPrice.value;

  double get maxPrice => _maxPrice.value;

  double get currentMinPrice => _currentMinPrice.value;

  double get currentMaxPrice => _currentMaxPrice.value;

  double get minRating => _minRating.value;

  int get resultsCount => _filteredResults.length;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadCategories(),
      _loadSearchHistory(),
      _loadPopularSearches(),
    ]);
    _updateMaxPriceFromProducts();
  }

  void _setupSearchListener() {
    searchTextController.addListener(() {
      final query = searchTextController.text.trim();
      if (query != _searchQuery.value) {
        _searchQuery.value = query;
        if (query.isNotEmpty) {
          _generateSearchSuggestions(query);
        } else {
          _searchSuggestions.clear();
          if (!_hasActiveFilters()) {
            _clearResults();
          }
        }
      }
    });
  }

  Future<void> _performSearch(String query, {bool reset = true}) async {
    if (query.isEmpty && !_hasActiveFilters()) {
      _clearResults();
      return;
    }
    try {
      if (reset) {
        _currentPage.value = 1;
        _hasNextPage.value = true;
        _searchResults.clear();
        _filteredResults.clear();
      }
      _isSearching.value = true;
      _hasSearched.value = true; // NEW: mark as searched only when performing
      _errorMessage.value = '';

      final result = await _productRepository.getProducts(
        page: _currentPage.value,
        limit: 20,
        search: query.isNotEmpty ? query : null,
        categoryId: _selectedCategoryId.value.isNotEmpty
            ? _selectedCategoryId.value
            : null,
        subCategoryId: _selectedSubCategoryId.value.isNotEmpty
            ? _selectedSubCategoryId.value
            : null,
        sort: _getSortParameter(),
      );
      final products = result['products'] as List<Product>;
      if (reset) {
        _searchResults.value = products;
      } else {
        _searchResults.addAll(products);
      }
      _hasNextPage.value = result['hasNextPage'] ?? false;
      _applyLocalFilters();

      if (reset && query.isNotEmpty) {
        _addToSearchHistory(query);
      }
      _updateMaxPriceFromProducts();
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'خطأ في البحث: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      _isSearching.value = false;
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore.value ||
        !_hasNextPage.value ||
        (_searchQuery.isEmpty && !_hasActiveFilters()))
      return;
    try {
      _isLoadingMore.value = true;
      _currentPage.value++;
      await _performSearch(
        _searchQuery.value.isNotEmpty ? _searchQuery.value : '',
        reset: false,
      );
    } catch (e) {
      _currentPage.value--;
      debugPrint('Error loading more search results: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _applyLocalFilters() {
    List<Product> filtered = List.from(_searchResults);

    if (_selectedBrand.value.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.brand?.toLowerCase() == _selectedBrand.value.toLowerCase(),
          )
          .toList();
    }

    filtered = filtered
        .where(
          (p) =>
              p.displayPrice >= _currentMinPrice.value &&
              p.displayPrice <= _currentMaxPrice.value,
        )
        .toList();

    if (_showOnlyInStock.value) {
      filtered = filtered.where((p) => p.inStock).toList();
    }
    if (_showOnlyOnSale.value) {
      filtered = filtered.where((p) => p.hasDiscount).toList();
    }
    if (_showOnlyFeatured.value) {
      filtered = filtered.where((p) => p.isFeatured).toList();
    }
    if (_minRating.value > 0) {
      // apply rating if available
    }

    _sortResults(filtered);
    _filteredResults.value = filtered;
    _extractBrands();
  }

  void _sortResults(List<Product> products) {
    switch (_sortBy.value) {
      case 'price_low_high':
        products.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        break;
      case 'price_high_low':
        products.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
        break;
      case 'newest':
        products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
        // if rating exists, sort by rating
        break;
      case 'popularity':
        products.sort(
          (a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0),
        );
        break;
      case 'name_asc':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'relevance':
      default:
        break;
    }
  }

  void performSearch(String query) {
    searchTextController.text = query;
    _searchQuery.value = query;
    _performSearch(query);
  }

  void performQuickSearch(String query) {
    searchTextController.text = query;
    searchFocusNode.unfocus();
    _performSearch(query);
  }

  void performAdvancedSearch() {
    final query = searchTextController.text.trim();
    _performSearch(query.isNotEmpty ? query : '');
  }

  void clearSearch() {
    searchTextController.clear();
    _searchQuery.value = '';
    _clearResults();
    _hasSearched.value = false; // NEW: reset flag on clear
    searchFocusNode.unfocus();
  }

  void _clearResults() {
    _searchResults.clear();
    _filteredResults.clear();
    _errorMessage.value = '';
    _currentPage.value = 1;
    _hasNextPage.value = true;
    _hasSearched.value = false; // NEW: reset when results are cleared
  }

  void toggleFilters() {
    _showFilters.value = !_showFilters.value;
  }

  Future<void> selectCategory(String categoryId) async {
    _selectedCategoryId.value = categoryId;
    _selectedSubCategoryId.value = '';
    if (categoryId.isNotEmpty) {
      await _loadSubCategories(categoryId);
    } else {
      _subCategories.clear();
    }
    _applyFiltersAndSearch();
  }

  void selectSubCategory(String subCategoryId) {
    _selectedSubCategoryId.value = subCategoryId;
    _applyFiltersAndSearch();
  }

  void selectBrand(String brand) {
    _selectedBrand.value = brand;
    _applyFiltersAndSearch();
  }

  void setSortBy(String sortBy) {
    _sortBy.value = sortBy;
    _applyLocalFilters();
  }

  void setPriceRange(double min, double max) {
    _currentMinPrice.value = min;
    _currentMaxPrice.value = max;
    _applyLocalFilters();
  }

  void setMinRating(double rating) {
    _minRating.value = rating;
    _applyLocalFilters();
  }

  void toggleStockFilter() {
    _showOnlyInStock.value = !_showOnlyInStock.value;
    _applyFiltersAndSearch();
  }

  void toggleSaleFilter() {
    _showOnlyOnSale.value = !_showOnlyOnSale.value;
    _applyFiltersAndSearch();
  }

  void toggleFeaturedFilter() {
    _showOnlyFeatured.value = !_showOnlyFeatured.value;
    _applyFiltersAndSearch();
  }

  void _applyFiltersAndSearch() {
    if (_searchQuery.value.isNotEmpty || _hasActiveFilters()) {
      _performSearch(
        _searchQuery.value.isNotEmpty ? _searchQuery.value : '',
        reset: true,
      );
    } else {
      _clearResults();
    }
  }

  void clearAllFilters() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    _selectedBrand.value = '';
    _currentMinPrice.value = _minPrice.value;
    _currentMaxPrice.value = _maxPrice.value;
    _minRating.value = 0.0;
    _showOnlyInStock.value = false;
    _showOnlyOnSale.value = false;
    _showOnlyFeatured.value = false;
    _sortBy.value = 'relevance';
    _subCategories.clear();

    if (_searchQuery.value.isNotEmpty) {
      _performSearch(_searchQuery.value);
    } else {
      _clearResults();
    }
  }

  bool _hasActiveFilters() {
    return _selectedCategoryId.value.isNotEmpty ||
        _selectedSubCategoryId.value.isNotEmpty ||
        _selectedBrand.value.isNotEmpty ||
        _currentMinPrice.value > _minPrice.value ||
        _currentMaxPrice.value < _maxPrice.value ||
        _minRating.value > 0.0 ||
        _showOnlyInStock.value ||
        _showOnlyOnSale.value ||
        _showOnlyFeatured.value;
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories();
      _categories.value = categories;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    try {
      final subCategories = await _subCategoryRepository
          .getSubCategoriesByCategory(categoryId);
      _subCategories.value = subCategories;
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  void _extractBrands() {
    final brands = <String>{};
    for (final product in _searchResults) {
      if (product.brand != null && product.brand!.isNotEmpty) {
        brands.add(product.brand!);
      }
    }
    _brands.value = brands.toList()..sort();
  }

  void _updateMaxPriceFromProducts() {
    if (_searchResults.isNotEmpty) {
      final currentMax = _searchResults
          .map((p) => p.displayPrice)
          .reduce((a, b) => a > b ? a : b);
      if (currentMax > _maxPrice.value) {
        _maxPrice.value = (currentMax * 1.1).ceilToDouble();
        if (_currentMaxPrice.value > _maxPrice.value) {
          _currentMaxPrice.value = _maxPrice.value;
        }
      }
    } else {
      _maxPrice.value = 10000.0;
      _currentMaxPrice.value = 10000.0;
    }
  }

  void _addToSearchHistory(String query) {
    if (query.trim().isEmpty) return;
    _searchHistory.removeWhere(
      (item) => item.toLowerCase() == query.toLowerCase(),
    );
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 20) {
      _searchHistory.removeRange(20, _searchHistory.length);
    }
    _saveSearchHistory();
  }

  void _saveSearchHistory() {
    StorageService.storage.write('search_history', _searchHistory.toList());
  }

  Future<void> _loadSearchHistory() async {
    try {
      final history = StorageService.storage.read<List>('search_history') ?? [];
      _searchHistory.value = history.cast<String>();
    } catch (e) {
      debugPrint('Error loading search history: $e');
    }
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    StorageService.storage.remove('search_history');
  }

  void removeFromHistory(String query) {
    _searchHistory.remove(query);
    _saveSearchHistory();
  }

  Future<void> _loadPopularSearches() async {
    _popularSearches.value = [
      'ايفون',
      'سامسونج',
      'لابتوب',
      'سماعات',
      'شاحن',
      'غطاء هاتف',
      'ساعة ذكية',
      'تابلت',
    ];
  }

  void _generateSearchSuggestions(String query) {
    final suggestions = <String>{};
    final lowerQuery = query.toLowerCase();

    for (final historyItem in _searchHistory) {
      if (historyItem.toLowerCase().contains(lowerQuery)) {
        suggestions.add(historyItem);
      }
    }
    for (final popular in _popularSearches) {
      if (popular.toLowerCase().contains(lowerQuery)) {
        suggestions.add(popular);
      }
    }
    for (final category in _categories) {
      if (category.displayName.toLowerCase().contains(lowerQuery)) {
        suggestions.add(category.displayName);
      }
    }
    for (final brand in _brands) {
      if (brand.toLowerCase().contains(lowerQuery)) {
        suggestions.add(brand);
      }
    }
    _searchSuggestions.value = suggestions.take(8).toList();
  }

  String _getSortParameter() {
    switch (_sortBy.value) {
      case 'price_low_high':
        return 'price';
      case 'price_high_low':
        return '-price';
      case 'newest':
        return '-createdAt';
      case 'oldest':
        return 'createdAt';
      case 'name_asc':
        return 'name';
      case 'name_desc':
        return '-name';
      default:
        return '-createdAt';
    }
  }

  String getActiveFiltersDescription() {
    final filters = <String>[];
    if (_selectedCategoryId.value.isNotEmpty) {
      final category = _categories.firstWhereOrNull(
        (c) => c.id == _selectedCategoryId.value,
      );
      if (category != null) {
        filters.add('الفئة: ${category.displayName}');
      }
    }
    if (_selectedSubCategoryId.value.isNotEmpty) {
      final subCategory = _subCategories.firstWhereOrNull(
        (s) => s.id == _selectedSubCategoryId.value,
      );
      if (subCategory != null) {
        filters.add('الفئة الفرعية: ${subCategory.displayName}');
      }
    }
    if (_selectedBrand.value.isNotEmpty) {
      filters.add('العلامة: ${_selectedBrand.value}');
    }
    if (_currentMinPrice.value > _minPrice.value ||
        _currentMaxPrice.value < _maxPrice.value) {
      filters.add(
        'السعر: ${_currentMinPrice.value.toStringAsFixed(0)} - ${_currentMaxPrice.value.toStringAsFixed(0)}',
      );
    }
    if (_showOnlyInStock.value) filters.add('متوفر');
    if (_showOnlyOnSale.value) filters.add('عروض');
    if (_showOnlyFeatured.value) filters.add('مميز');
    return filters.isEmpty ? 'لا توجد فلاتر' : filters.join(' | ');
  }

  void resetSearch() {
    clearSearch();
    clearAllFilters();
    _showFilters.value = false;
    _isAdvancedSearch.value = false;
  }
}
