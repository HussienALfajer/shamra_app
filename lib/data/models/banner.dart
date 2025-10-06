class Banner {
  final String id;
  final String image;
  final String? productId;
  final BannerProduct? product;
  final String? categoryId;
  final BannerCategory? category;
  final BannerSubCategory? subCategory;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  Banner({
    required this.id,
    required this.image,
    this.productId,
    this.product,
    this.categoryId,
    this.category,
    this.subCategory,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    try {
      return Banner(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        productId: json['productId']?.toString(),
        product: json['product'] != null ? BannerProduct.fromJson(json['product']) : null,
        categoryId: json['categoryId']?.toString(),
        category: json['category'] != null ? BannerCategory.fromJson(json['category']) : null,
        subCategory: json['subCategory'] != null ? BannerSubCategory.fromJson(json['subCategory']) : null,
        sortOrder: _parseInt(json['sortOrder']),
        isActive: _parseBool(json['isActive'], defaultValue: true),
        createdAt: _parseDateTime(json['createdAt']),
      );
    } catch (e) {
      print('Error parsing Banner from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  // Helper methods for safe parsing
  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'productId': productId,
      'product': product?.toJson(),
      'categoryId': categoryId,
      'category': category?.toJson(),
      'subCategory': subCategory?.toJson(),
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayImage => image;

  bool get hasProduct => product != null && productId != null;
  bool get hasCategory => category != null && categoryId != null;
}

class BannerProduct {
  final String name;
  final String? image;
  final double price;
  final bool isActive;

  BannerProduct({
    required this.name,
    this.image,
    required this.price,
    required this.isActive,
  });

  factory BannerProduct.fromJson(Map<String, dynamic> json) {
    return BannerProduct(
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      price: _parseDouble(json['price']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'isActive': isActive,
    };
  }
}

class BannerCategory {
  final String name;
  final String? image;
  final bool isActive;

  BannerCategory({
    required this.name,
    this.image,
    required this.isActive,
  });

  factory BannerCategory.fromJson(Map<String, dynamic> json) {
    return BannerCategory(
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'isActive': isActive,
    };
  }
}

class BannerSubCategory {
  final String name;
  final String? image;
  final bool isActive;

  BannerSubCategory({
    required this.name,
    this.image,
    required this.isActive,
  });

  factory BannerSubCategory.fromJson(Map<String, dynamic> json) {
    return BannerSubCategory(
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static bool _parseBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'isActive': isActive,
    };
  }
}