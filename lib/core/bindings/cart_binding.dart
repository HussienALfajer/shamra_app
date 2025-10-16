// lib/core/bindings/cart_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/cart_controller.dart';

/// Binding for cart controller.
/// Used by cart and checkout routes.
class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}