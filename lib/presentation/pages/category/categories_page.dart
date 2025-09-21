import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../data/utils/helpers.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/category.dart';

/// 📂 صفحة جميع الفئات Categories Page
/// - تعرض كل الفئات الموجودة من السيرفر
/// - تدعم البحث والفلترة
/// - تستخدم Widgets مشتركة (ShamraCard, CustomAppBar, LoadingWidget...)
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: "جميع الفئات"),
        body: SafeArea(
          child: Obx(() {
            if (categoryController.isLoading &&
                categoryController.categories.isEmpty) {
              return const LoadingWidget(message: "جاري تحميل الفئات...");
            }

            if (categoryController.errorMessage.isNotEmpty) {
              return ErrorWidget(
                message: categoryController.errorMessage,
                onRetry: categoryController.refreshCategories,
              );
            }

            if (categoryController.categories.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.category_outlined,
                title: "لا توجد فئات",
                message: "لا توجد فئات متاحة حالياً\nتحقق مرة أخرى لاحقاً",
              );
            }

            return _buildCategoriesContent(categoryController);
          }),
        ),
      ),
    );
  }

  /// 🔹 بناء محتوى قائمة الفئات
  Widget _buildCategoriesContent(CategoryController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshCategories,
      color: AppColors.primary,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.80,
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  /// 🔹 كرت فئة فردية
  Widget _buildCategoryCard(Category category) {
    return ShamraCard(
      onTap: () => Get.toNamed(
        Routes.categoryDetails,
        arguments: {
          "categoryId": category.id,
          "categoryName": category.displayName,
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// صورة الفئة
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: category.image != null && category.image!.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: HelperMethod.getImageUrl(category.image!),
              width: double.infinity,
              height: 130,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: AppColors.grey,
              ),
            )
                : Container(
              width: double.infinity,
              height: 120,
              color: AppColors.lightGrey,
              child: const Icon(
                Icons.category_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// اسم الفئة
          Text(
            category.displayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          /// وصف الفئة (اختياري)
          if (category.displayDescription.isNotEmpty)
            Text(
              category.displayDescription,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
