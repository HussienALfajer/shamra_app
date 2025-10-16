// lib/core/bindings/order_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/cart_controller.dart';
import 'package:shamra_app/presentation/controllers/order_controller.dart';

/// Binding for order-related controllers.
class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}