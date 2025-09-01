import 'package:shamra_app/data/models/order.dart';

import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final double price;

  CartItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      product: product,
      quantity: quantity,
      price: product.displayPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity, 'price': price};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  double get total => quantity * price;

  OrderItem toOrderItem() {
    return OrderItem(
      productId: product.id,
      productName: product.name,
      productSku: product.sku,
      quantity: quantity,
      price: price,
    );
  }
}

class Cart {
  final List<CartItem> items;

  Cart({List<CartItem>? items}) : items = items ?? [];

  void addItem(Product product, {int quantity = 1}) {
    final existingItemIndex = items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      items[existingItemIndex].quantity += quantity;
    } else {
      items.add(CartItem.fromProduct(product, quantity: quantity));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((item) => item.product.id == productId);
  }

  void updateItemQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final itemIndex = items.indexWhere((item) => item.product.id == productId);
    if (itemIndex != -1) {
      items[itemIndex].quantity = newQuantity;
    }
  }

  void clear() {
    items.clear();
  }

  bool contains(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  CartItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  List<OrderItem> toOrderItems() {
    return items.map((item) => item.toOrderItem()).toList();
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}
