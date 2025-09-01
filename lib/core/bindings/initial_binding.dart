import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/product_controller.dart';
import '../../presentation/controllers/cart_controller.dart';
import '../../presentation/controllers/category_controller.dart';
import '../../presentation/controllers/order_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers that need to be available globally
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<ProductController>(ProductController(), permanent: true);
    Get.put<CategoryController>(CategoryController(), permanent: true);
    Get.put<OrderController>(OrderController(), permanent: true);
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<CartController>(() => CartController());
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}