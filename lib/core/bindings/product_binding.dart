// lib/core/bindings/product_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/product_controller.dart';
import 'package:shamra_app/presentation/controllers/category_controller.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';
import 'package:shamra_app/presentation/controllers/cart_controller.dart';

// UI controller lives in the page file for now (kept for compatibility).
import 'package:shamra_app/presentation/pages/product/product_page.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<SubCategoryController>(() => SubCategoryController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);

    // Temporary: UI-specific controller used by the products page.
    Get.lazyPut<ProductsUIController>(() => ProductsUIController(), fenix: true);
  }
}
