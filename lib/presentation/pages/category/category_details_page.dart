import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../data/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';

class CategoryDetailsPage extends StatelessWidget {
  const CategoryDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments
    final args = Get.arguments as Map<String, dynamic>;
    final categoryId = args['categoryId'] as String;
    final categoryName = args['categoryName'] as String;

    // Get controllers
    final categoryController = Get.find<CategoryController>();
    final subCategoryController = Get.find<SubCategoryController>();

    // Initialize category page
    categoryController.initializeCategoryPage(categoryId, categoryName);
    subCategoryController.loadSubCategoriesByCategory(categoryId);

    return WillPopScope(
      onWillPop: () async {
        categoryController.cleanupCategoryPage();
        subCategoryController.clearSelectedSubCategory();
        subCategoryController.clearFilters();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: categoryName,
          actions: [
            Obx(() => IconButton(
              icon: Icon(
                categoryController.showSearch ? Icons.close : Icons.search,
                color: AppColors.black,
              ),
              onPressed: categoryController.toggleSearch,
            )),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Obx(() => categoryController.showSearch
                ? _SearchBar(categoryController: categoryController, categoryName: categoryName)
                : const SizedBox.shrink()),

            // Subcategory filters
            _SubCategoryFilters(
              categoryController: categoryController,
              subCategoryController: subCategoryController,
            ),

            const Divider(height: 1, color: AppColors.divider),

            // Products grid
            Expanded(
              child: _ProductsGrid(categoryController: categoryController),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search bar widget
class _SearchBar extends StatelessWidget {
  final CategoryController categoryController;
  final String categoryName;

  const _SearchBar({
    required this.categoryController,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

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
        controller: searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'البحث في منتجات $categoryName...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: Obx(() => categoryController.searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              categoryController.clearSearch();
            },
          )
              : const SizedBox.shrink()),
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
        onChanged: (query) => categoryController.searchProducts(query),
        onSubmitted: (query) => categoryController.searchProducts(query),
      ),
    );
  }
}

/// Subcategory filters widget
class _SubCategoryFilters extends StatelessWidget {
  final CategoryController categoryController;
  final SubCategoryController subCategoryController;

  const _SubCategoryFilters({
    required this.categoryController,
    required this.subCategoryController,
  });

  @override
  Widget build(BuildContext context) {
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
          onRetry: () => subCategoryController.loadSubCategoriesByCategory(
            categoryController.currentCategoryId,
          ),
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
            // "All" button
            Obx(() => _CategoryChip(
              title: "الكل",
              isSelected: categoryController.selectedSubCategoryId.isEmpty,
              onTap: () {
                subCategoryController.clearSelectedSubCategory();
                categoryController.clearSubCategoryFilter();
              },
            )),

            // Subcategory chips
            ...subCategories.map((sub) => _SubCategoryChip(
              subCategory: sub,
              categoryController: categoryController,
              subCategoryController: subCategoryController,
            )),
          ],
        ),
      );
    });
  }
}

/// Category chip widget
class _CategoryChip extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Subcategory chip widget
class _SubCategoryChip extends StatelessWidget {
  final dynamic subCategory;
  final CategoryController categoryController;
  final SubCategoryController subCategoryController;

  const _SubCategoryChip({
    required this.subCategory,
    required this.categoryController,
    required this.subCategoryController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = categoryController.selectedSubCategoryId == subCategory.id;

      return GestureDetector(
        onTap: () {
          print('🏷️ Subcategory tapped: ${subCategory.id} (${subCategory.displayName})');
          subCategoryController.selectSubCategory(subCategory);
          categoryController.filterBySubCategory(subCategory.id);
        },
        child: Container(
          width: 75,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.chipBackground,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: subCategory.hasImage
                        ? CachedNetworkImage(
                      imageUrl: HelperMethod.getImageUrl(subCategory.image!),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Icon(
                        Icons.category_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.category_outlined,
                        color: AppColors.grey,
                        size: 20,
                      ),
                    )
                        : Icon(
                      Icons.category_outlined,
                      color: isSelected ? AppColors.primary : AppColors.grey,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    subCategory.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
      );
    });
  }
}

/// Products grid widget
class _ProductsGrid extends StatelessWidget {
  final CategoryController categoryController;

  const _ProductsGrid({required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (controller) => NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Load more when scrolling near the bottom
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
            controller.loadMoreProducts();
          }
          return false;
        },
        child: Obx(() {
          // Loading state
          if (controller.isLoadingProducts && controller.categoryProducts.isEmpty) {
            return const LoadingWidget(message: "جاري تحميل المنتجات...");
          }

          // Error state
          if (controller.productErrorMessage.isNotEmpty &&
              controller.categoryProducts.isEmpty) {
            return ErrorWidget(
              message: controller.productErrorMessage,
              onRetry: controller.refreshCategoryProducts,
            );
          }

          // Empty state
          if (controller.categoryProducts.isEmpty) {
            return SingleChildScrollView(
              child: EmptyStateWidget(
                icon: Icons.inventory_2_outlined,
                title: "لا توجد منتجات",
                message: controller.getEmptyMessage(),
              ),
            );
          }

          // Products grid
          return RefreshIndicator(
            onRefresh: controller.refreshCategoryProducts,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 300,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.categoryProducts.length +
                  (controller.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading more indicator
                if (index == controller.categoryProducts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoadingWidget(size: 20, message: "تحميل المزيد..."),
                    ),
                  );
                }

                // Product card
                final product = controller.categoryProducts[index];
                return ProductCard(
                  product: product,
                  isGridView: true,
                  onTap: () => Get.toNamed(Routes.productDetails, arguments: product.id),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}