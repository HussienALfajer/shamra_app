import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/category_controller.dart';
import 'package:shamra_app/presentation/controllers/product_controller.dart';

import '../../presentation/pages/product/product_page.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<ProductsUIController>(() => ProductsUIController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
