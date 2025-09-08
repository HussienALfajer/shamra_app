import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/cart_controller.dart';
import 'package:shamra_app/presentation/controllers/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<CartController>(() => CartController());
  }
}
