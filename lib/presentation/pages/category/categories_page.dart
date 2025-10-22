import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../data/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/category.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final TextEditingController searchController = TextEditingController();
    final RxString searchQuery = ''.obs;

    // Calculate filtered categories reactively
    List<Category> getFilteredCategories() {
      if (searchQuery.value.isEmpty) {
        return categoryController.categories;
      }
      return categoryController.categories.where((category) {
        final query = searchQuery.value.toLowerCase();
        return category.displayName.toLowerCase().contains(query) ||
            category.displayDescription.toLowerCase().contains(query);
      }).toList();
    }

    void onSearchChanged(String query) {
      searchQuery.value = query.trim();
    }

    void clearSearch() {
      searchController.clear();
      searchQuery.value = '';
      FocusScope.of(context).unfocus();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            'الفئات',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Column(
          children: [
            // Search section
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child:  TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'ابحث عن الفئات...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary.withOpacity(0.6),
                    size: 22,
                  ),
                  suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.textSecondary.withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: clearSearch,
                  )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Categories content
            Expanded(
              child: GetBuilder<CategoryController>(
                builder: (controller) {
                  if (controller.isLoading && controller.categories.isEmpty) {
                    return const Center(
                      child: LoadingWidget(message: "جاري تحميل الفئات..."),
                    );
                  }

                  if (controller.errorMessage.isNotEmpty && controller.categories.isEmpty) {
                    return ErrorWidget(
                      message: controller.errorMessage,
                      onRetry: controller.refreshCategories,
                    );
                  }

                  if (controller.categories.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.category_outlined,
                      title: "لا توجد فئات",
                      message: "لا توجد فئات متاحة حالياً",
                    );
                  }

                  // Build grid with reactive search
                  return Obx(() {
                    final filteredCategories = getFilteredCategories();

                    // Show search results or no results message
                    if (searchQuery.value.isNotEmpty && filteredCategories.isEmpty) {
                      return SingleChildScrollView(
                        child: EmptyStateWidget(
                          icon: Icons.search_off,
                          title: "لا توجد نتائج",
                          message: 'لا توجد فئات تطابق "${searchQuery.value}"',
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.refreshCategories,
                      color: AppColors.primary,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          return _MinimalCategoryCard(category: category);
                        },
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalCategoryCard extends StatelessWidget {
  final Category category;

  const _MinimalCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        Routes.categoryDetails,
        arguments: {
          "categoryId": category.id,
          "categoryName": category.displayName,
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image section
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                  child: category.image != null && category.image!.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: HelperMethod.getImageUrl(category.image!),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGrey.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary.withOpacity(0.05),
                      child: Icon(
                        Icons.category_outlined,
                        size: 32,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                    ),
                  )
                      : Icon(
                    Icons.category_outlined,
                    size: 32,
                    color: AppColors.primary.withOpacity(0.7),
                  ),
                ),
              ),

              // Text section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (category.displayDescription.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          category.displayDescription,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.8),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}