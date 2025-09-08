class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? salePrice;
  final double? costPrice;
  final String categoryId;
  final List<String> branchesId;
  final int stockQuantity;
  final String? brand;
  final String? model;
  final bool isActive;
  final bool isFeatured;
  final bool isOnSale;
  final List<String> images;
  final String mainImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.salePrice,
    this.costPrice,
    required this.categoryId,
    required this.branchesId,
    required this.stockQuantity,
    this.brand,
    this.model,
    required this.isActive,
    required this.isFeatured,
    required this.isOnSale,
    required this.images,
    required this.mainImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      costPrice: json['costPrice']?.toDouble(),
      categoryId: json['categoryId'] ?? '',
      branchesId: List<String>.from(json['branchesId'] ?? []),
      stockQuantity: json['stockQuantity'] ?? 0,
      brand: json['brand'],
      model: json['model'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      isOnSale: json['isOnSale'] ?? false,
      mainImage: json['mainImage'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'categoryId': categoryId,
      'branchesId': branchesId,
      'stockQuantity': stockQuantity,
      'brand': brand,
      'model': model,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isOnSale': isOnSale,
      'images': images,
      'mainImage': mainImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get displayPrice => isOnSale && salePrice != null ? salePrice! : price;

  bool get hasDiscount => isOnSale && salePrice != null && salePrice! < price;

  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((price - salePrice!) / price) * 100;
  }

  String get displayName => name;

  String get displayDescription => (description ?? '');

  bool get inStock => stockQuantity > 0;
}
