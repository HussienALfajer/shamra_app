import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/product.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';

/// 📌 صفحة المنتجات المفضلة
/// - تعرض جميع المنتجات اللي اختارها المستخدم كمفضلة.
/// - تستخدم [FavoriteController] للحصول على قائمة الـ IDs.
/// - ثم تجيب تفاصيل كل منتج من [ProductController].
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  /// ✅ تحميل المنتجات المفضلة (حسب الـ IDs)
  Future<List<Product>> _loadFavorites(
      FavoriteController favController,
      ProductController productController,
      ) async {
    final products = <Product>[];
    for (final id in favController.favorites) {
      final product = await productController.getProductById(id);
      if (product != null) products.add(product);
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final favController = Get.find<FavoriteController>();
    final productController = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "المفضلة"),

      /// ✅ نستخدم FutureBuilder مع Obx للتعامل مع الحالة
      body: Obx(() {
        if (favController.favorites.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.favorite_border,
            title: "لا توجد منتجات مفضلة",
            message: "أضف منتجات إلى المفضلة لتظهر هنا",
          );
        }

        return FutureBuilder<List<Product>>(
          future: _loadFavorites(favController, productController),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(message: "جاري تحميل المنتجات...");
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.favorite_border,
                title: "لا توجد منتجات مفضلة",
                message: "أضف منتجات إلى المفضلة لتظهر هنا",
              );
            }

            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => Get.toNamed(
                    Routes.productDetails,
                    arguments: product.id,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
