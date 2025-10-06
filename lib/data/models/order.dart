class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;


  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });


  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // طباعة البيانات الخام للتشخيص
    print('OrderItem JSON: $json');

    final product = json['product'];
    print('Product object: $product');

    String? _pId;
    String? _pName;
    String? _main;
    List<String> _imgs = const [];

    if (product is Map<String, dynamic>) {
      _pId = product['_id'] ?? product['id'] ?? json['productId'];
      _pName = product['name'] ?? json['productName'] ?? '';
      _main = product['mainImage'] ??
          product['image'] ??
          product['thumbnail'] ??
          json['mainImage'] ??
          json['image'] ??
          json['thumbnail'];
      final imgs = product['images'] ?? json['images'];
      if (imgs is List) {
        _imgs = imgs.map((e) => e.toString()).toList();
      }
      print('From product - mainImage: $_main, images: $_imgs');
    } else {
      _pId = json['productId'] ?? '';
      _pName = json['productName'] ?? '';
      _main = json['mainImage'] ?? json['image'] ?? json['thumbnail'];
      final imgs = json['images'];
      if (imgs is List) {
        _imgs = imgs.map((e) => e.toString()).toList();
      }
      print('From json - mainImage: $_main, images: $_imgs');
    }

    print('Final - mainImage: $_main, images: $_imgs');

    return OrderItem(
      productId: _pId ?? '',
      productName: _pName ?? '',
      quantity: (json['quantity'] ?? 0) as int,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  double get total => quantity * price;

  /// URL نهائي لصورة العرض

}

class Order {
  final String id;
  final String orderNumber;
  final String branchId;
  final List<OrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.branchId,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.isPaid,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      branchId: json['branchId'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      isPaid: json['isPaid'] ?? false,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'branchId': branchId,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'status': status,
      'isPaid': isPaid,
      'notes': notes,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'processing': return 'Processing';
      case 'shipped': return 'Shipped';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}
