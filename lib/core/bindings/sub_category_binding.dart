// lib/core/bindings/sub_category_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';

/// Binding for sub-category controller.
class SubCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubCategoryController>(
          () => SubCategoryController(),
      fenix: true,
    );
  }
}