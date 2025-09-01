import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shamra_app/data/models/order.dart';
import '../../data/models/cart.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = CartRepository();

  // Observables
  final Rx<Cart> _cart = Cart().obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxDouble _taxRate = 0.1.obs; // 10% tax rate
  final RxDouble _shippingFee = 0.0.obs;

  // Getters
  Cart get cart => _cart.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  double get taxRate => _taxRate.value;
  double get shippingFee => _shippingFee.value;

  List<CartItem> get items => _cart.value.items;
  int get itemCount => _cart.value.totalItems;
  double get subtotal => _cart.value.subtotal;
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount + shippingFee;
  bool get isEmpty => _cart.value.isEmpty;
  bool get isNotEmpty => _cart.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  // Load cart from storage
  Future<void> loadCart() async {
    try {
      _isLoading.value = true;
      final cart = await _cartRepository.loadCart();
      _cart.value = cart;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // Add item to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      _cart.value.addItem(product, quantity: quantity);
      await _cartRepository.saveCart(_cart.value);

      Get.snackbar(
        'Added to Cart',
        '${product.name} has been added to your cart',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Trigger reactive update
      _cart.refresh();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to add item to cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final item = _cart.value.getItem(productId);
      if (item != null) {
        _cart.value.removeItem(productId);
        await _cartRepository.saveCart(_cart.value);

        Get.snackbar(
          'Removed from Cart',
          '${item.product.name} has been removed from your cart',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );

        // Trigger reactive update
        _cart.refresh();
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to remove item from cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      _cart.value.updateItemQuantity(productId, newQuantity);
      await _cartRepository.saveCart(_cart.value);

      // Trigger reactive update
      _cart.refresh();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update quantity',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Increment item quantity
  Future<void> incrementQuantity(String productId) async {
    final item = _cart.value.getItem(productId);
    if (item != null) {
      await updateItemQuantity(productId, item.quantity + 1);
    }
  }

  // Decrement item quantity
  Future<void> decrementQuantity(String productId) async {
    final item = _cart.value.getItem(productId);
    if (item != null) {
      await updateItemQuantity(productId, item.quantity - 1);
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      _cart.value.clear();
      await _cartRepository.saveCart(_cart.value);

      Get.snackbar(
        'Cart Cleared',
        'All items have been removed from your cart',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Trigger reactive update
      _cart.refresh();
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to clear cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _cart.value.contains(productId);
  }

  // Get product quantity in cart
  int getProductQuantity(String productId) {
    final item = _cart.value.getItem(productId);
    return item?.quantity ?? 0;
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    return _cart.value.getItem(productId);
  }

  // Set tax rate
  void setTaxRate(double rate) {
    _taxRate.value = rate;
  }

  // Set shipping fee
  void setShippingFee(double fee) {
    _shippingFee.value = fee;
  }

  // Get order items for checkout
  List<OrderItem> getOrderItems() {
    return _cart.value.toOrderItems();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  // Show cart summary dialog
  void showCartSummary() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cart Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${itemCount}'),
            Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
            Text('Tax: \$${taxAmount.toStringAsFixed(2)}'),
            if (shippingFee > 0)
              Text('Shipping: \$${shippingFee.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/checkout');
            },
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}
