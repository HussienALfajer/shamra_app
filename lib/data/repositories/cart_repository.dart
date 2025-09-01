import 'package:get_storage/get_storage.dart';
import '../models/cart.dart';
import '../models/product.dart';

class CartRepository {
  static const String _cartKey = 'shopping_cart';
  static final _storage = GetStorage();

  // Save cart to storage
  Future<void> saveCart(Cart cart) async {
    try {
      await _storage.write(_cartKey, cart.toJson());
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Load cart from storage
  Future<Cart> loadCart() async {
    try {
      final cartData = _storage.read<Map<String, dynamic>>(_cartKey);
      if (cartData != null) {
        return Cart.fromJson(cartData);
      }
      return Cart();
    } catch (e) {
      print('Error loading cart: $e');
      return Cart();
    }
  }

  // Add item to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      final cart = await loadCart();
      cart.addItem(product, quantity: quantity);
      await saveCart(cart);
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      final cart = await loadCart();
      cart.removeItem(productId);
      await saveCart(cart);
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    try {
      final cart = await loadCart();
      cart.updateItemQuantity(productId, newQuantity);
      await saveCart(cart);
    } catch (e) {
      print('Error updating cart quantity: $e');
      rethrow;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      final cart = Cart();
      await saveCart(cart);
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    try {
      final cart = await loadCart();
      return cart.totalItems;
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  // Check if product is in cart
  Future<bool> isInCart(String productId) async {
    try {
      final cart = await loadCart();
      return cart.contains(productId);
    } catch (e) {
      print('Error checking cart: $e');
      return false;
    }
  }

  // Get product quantity in cart
  Future<int> getProductQuantity(String productId) async {
    try {
      final cart = await loadCart();
      final item = cart.getItem(productId);
      return item?.quantity ?? 0;
    } catch (e) {
      print('Error getting product quantity: $e');
      return 0;
    }
  }
}