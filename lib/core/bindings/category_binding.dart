// lib/core/bindings/category_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/category_controller.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';
import 'package:shamra_app/presentation/controllers/product_controller.dart';

/// Binds controllers used across category-related pages.
/// Kept lean; UI-only pages consume these via Get.find().
class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<SubCategoryController>(() => SubCategoryController(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
  }
}
