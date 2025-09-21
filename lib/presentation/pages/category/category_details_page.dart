import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/product.dart';
import '../../../data/utils/helpers.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';

class CategoryDetailsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  late final ProductController productController;
  late final SubCategoryController subCategoryController;
  late final Rx<TextEditingController> searchController;
  late final RxBool showSearch;

  @override
  void initState() {
    super.initState();
    productController = Get.find<ProductController>();
    subCategoryController = Get.find<SubCategoryController>();
    searchController = TextEditingController().obs;
    showSearch = false.obs;

    // تحميل البيانات الأولية
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  @override
  void dispose() {
    // تنظيف البيانات عند الخروج من الصفحة
    _clearFiltersOnExit();
    searchController.value.dispose();
    super.dispose();
  }

  void _clearFiltersOnExit() {
    print("Clearing filters on exit from CategoryDetailsPage...");

    // مسح الفئات الفرعية المحددة
    subCategoryController.clearSelectedSubCategory();
    subCategoryController.clearFilters();

    // استخدام التوابع الموجودة في ProductController
    productController.clearAllFilters();

    print("Filters cleared successfully");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // تنظيف الفلاتر عند الضغط على زر الرجوع
        _clearFiltersOnExit();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: widget.categoryName,
          actions: [
            Obx(() => IconButton(
              icon: Icon(
                showSearch.value ? Icons.close : Icons.search,
                color: AppColors.black,
              ),
              onPressed: () {
                showSearch.value = !showSearch.value;
                if (!showSearch.value) {
                  searchController.value.clear();
                  // استخدام التابع الموجود لمسح البحث
                  productController.clearSearch();
                  // إعادة تحميل منتجات الفئة الحالية
                  _loadCategoryProducts();
                }
              },
            )),
          ],
        ),
        body: Column(
          children: [
            // شريط البحث
            Obx(() => showSearch.value
                ? _buildSearchBar()
                : const SizedBox.shrink()),

            // قائمة الفئات الفرعية
            _buildSubCategoryFilters(),

            const Divider(height: 1, color: AppColors.divider),

            // المنتجات
            Expanded(
              child: _buildProductsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    // مسح الفلاتر المسبقة
    subCategoryController.clearSelectedSubCategory();

    await Future.wait([
      subCategoryController.loadSubCategoriesByCategory(widget.categoryId),
      _loadCategoryProducts(),
    ]);
  }

  Future<void> _loadCategoryProducts() async {
    try {
      // استخدام التابع الموجود في ProductController للحصول على منتجات الفئة
      await productController.getProductsByCategory(widget.categoryId);
    } catch (e) {
      print('Error loading category products: $e');
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController.value,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'البحث في منتجات ${widget.categoryName}...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: searchController.value.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.value.clear();
              // استخدام التابع الموجود لمسح البحث
              productController.clearSearch();
              // إعادة تطبيق فلتر الفئة الحالية
              _applyCurrentFilter();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        onChanged: (query) => _performSearch(query),
        onSubmitted: (query) => _performSearch(query),
      ),
    );
  }

  Widget _buildSubCategoryFilters() {
    return Obx(() {
      if (subCategoryController.isLoading) {
        return const SizedBox(
          height: 80,
          child: Center(child: LoadingWidget(message: "جاري تحميل الفئات...")),
        );
      }

      if (subCategoryController.errorMessage.isNotEmpty) {
        return ErrorWidget(
          message: subCategoryController.errorMessage,
          onRetry: () => subCategoryController.loadSubCategoriesByCategory(widget.categoryId),
        );
      }

      final subCategories = subCategoryController.filteredSubCategories;
      if (subCategories.isEmpty) {
        return const SizedBox();
      }

      return SizedBox(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            // زر "الكل"
            Obx(() => GestureDetector(
              onTap: () async {
                subCategoryController.clearSelectedSubCategory();
                productController.clearSubCategoryFilter();
                searchController.value.clear();

                showSearch.value = false;

                await productController.getProductsByCategory(widget.categoryId);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: subCategoryController.selectedSubCategory == null
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: subCategoryController.selectedSubCategory == null
                      ? Border.all(color: AppColors.primary, width: 1.5)
                      : null,
                ),
                child: Text(
                  "الكل",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: subCategoryController.selectedSubCategory == null
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: subCategoryController.selectedSubCategory == null
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            )),

            // باقي الفئات الفرعية
            ...subCategories.map(
                  (sub) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Obx(() => GestureDetector(
                  onTap: () async {
                    subCategoryController.selectSubCategory(sub);
                    searchController.value.clear();
                    showSearch.value = false;

                    // استخدام التابع الموجود للفلترة حسب الفئة الفرعية
                    await productController.filterBySubCategory(sub.id);
                  },
                  child: Container(
                    width: 75,
                    decoration: BoxDecoration(
                      color: subCategoryController.selectedSubCategory?.id == sub.id
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: subCategoryController.selectedSubCategory?.id == sub.id
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(
                              color: subCategoryController.selectedSubCategory?.id == sub.id
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: sub.hasImage
                                  ? CachedNetworkImage(
                                imageUrl: HelperMethod.getImageUrl(sub.image!),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.lightGrey,
                                  child: Icon(Icons.category_outlined, color: AppColors.grey, size: 20),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.lightGrey,
                                  child: Icon(Icons.category_outlined, color: AppColors.grey, size: 20),
                                ),
                              )
                                  : Icon(
                                Icons.category_outlined,
                                color: subCategoryController.selectedSubCategory?.id == sub.id
                                    ? AppColors.primary
                                    : AppColors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              sub.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: subCategoryController.selectedSubCategory?.id == sub.id
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: subCategoryController.selectedSubCategory?.id == sub.id
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductsGrid() {
    return Obx(() {
      if (productController.isLoading) {
        return const LoadingWidget(message: "جاري تحميل المنتجات...");
      }

      if (productController.errorMessage.isNotEmpty) {
        return ErrorWidget(
          message: productController.errorMessage,
          onRetry: () => _loadCategoryProducts(),
        );
      }

      // استخدام searchResults إذا كان هناك بحث، وإلا products العادية
      final products = productController.searchQuery.isNotEmpty
          ? productController.searchResults
          : productController.products;

      if (products.isEmpty) {
        return SingleChildScrollView(
          child: EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            title: "لا توجد منتجات",
            message: _getEmptyMessage(),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _loadInitialData(),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 300,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              isGridView: true,
              onTap: () => Get.toNamed('/product-details', arguments: product),
            );
          },
        ),
      );
    });
  }

  String _getEmptyMessage() {
    if (productController.searchQuery.isNotEmpty) {
      return 'لا توجد نتائج للبحث عن "${productController.searchQuery}"';
    } else if (subCategoryController.selectedSubCategory != null) {
      return 'لا توجد منتجات في هذه الفئة الفرعية';
    }
    return 'لا توجد منتجات متاحة في هذا القسم حالياً';
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      // استخدام التابع الموجود لمسح البحث
      productController.clearSearch();
      await _applyCurrentFilter();
      return;
    }

    // تنفيذ البحث باستخدام التابع الموجود
    await productController.searchProducts(query);
  }

  Future<void> _applyCurrentFilter() async {
    if (subCategoryController.selectedSubCategory == null) {
      // إظهار جميع منتجات الفئة
      await productController.getProductsByCategory(widget.categoryId);
    } else {
      // فلترة حسب الفئة الفرعية المحددة
      await productController.filterBySubCategory(subCategoryController.selectedSubCategory!.id);
    }
  }
}