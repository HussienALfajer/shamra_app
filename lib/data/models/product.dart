class Product {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String sku;
  final double price;
  final double? salePrice;
  final double? costPrice;
  final String categoryId;
  final String branchId;
  final int stockQuantity;
  final String? brand;
  final String? model;
  final bool isActive;
  final bool isFeatured;
  final bool isOnSale;
  final String slug;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    required this.sku,
    required this.price,
    this.salePrice,
    this.costPrice,
    required this.categoryId,
    required this.branchId,
    required this.stockQuantity,
    this.brand,
    this.model,
    required this.isActive,
    required this.isFeatured,
    required this.isOnSale,
    required this.slug,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      salePrice: json['salePrice']?.toDouble(),
      costPrice: json['costPrice']?.toDouble(),
      categoryId: json['categoryId'] ?? '',
      branchId: json['branchId'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      brand: json['brand'],
      model: json['model'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      isOnSale: json['isOnSale'] ?? false,
      slug: json['slug'] ?? '',
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
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'sku': sku,
      'price': price,
      'salePrice': salePrice,
      'costPrice': costPrice,
      'categoryId': categoryId,
      'branchId': branchId,
      'stockQuantity': stockQuantity,
      'brand': brand,
      'model': model,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isOnSale': isOnSale,
      'slug': slug,
      'images': images,
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

  String get displayName => nameAr.isNotEmpty ? nameAr : name;

  String get displayDescription =>
      descriptionAr?.isNotEmpty == true ? descriptionAr! : (description ?? '');

  bool get inStock => stockQuantity > 0;

  String get firstImage => images.isNotEmpty ? images.first : '';
}
