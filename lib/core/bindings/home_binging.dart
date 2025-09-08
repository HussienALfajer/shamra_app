import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/category_controller.dart';
import 'package:shamra_app/presentation/controllers/product_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
