import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product.dart';

/// Favorites page - shows user's favorite products.
/// Updated: load favorites in parallel using Future.wait for better performance.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  /// Load favorites in parallel to speed up fetching.
  Future<List<Product>> _loadFavorites(
      FavoriteController favController,
      ProductController productController,
      ) async {
    final ids = favController.favorites.toList();
    if (ids.isEmpty) return [];

    // Load all products in parallel and keep non-null results
    final futures = ids.map((id) => productController.getProductById(id));
    final results = await Future.wait(futures);
    return results.whereType<Product>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final favController = Get.find<FavoriteController>();
    final productController = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "المفضلة"),
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
