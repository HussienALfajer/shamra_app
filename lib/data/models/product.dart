import 'package:get/get.dart';
import '../../core/services/storage_service.dart';
import '../../presentation/controllers/auth_controller.dart';

enum ProductStatus {
  ACTIVE,
  INACTIVE,
  DRAFT,
  ARCHIVED,
}

enum Currency {
  USD,
  SYP,
  EUR,
}

class BranchPrice {
  final String branchId;
  final String sku;
  final double price;
  final double costPrice;
  final double wholeSalePrice;
  final double? salePrice;
  final String? currency;
  final int stockQuantity;
  final bool isOnSale;
  final bool isActive;

  BranchPrice({
    required this.branchId,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.wholeSalePrice,
    this.salePrice,
    this.currency,
    required this.stockQuantity,
    required this.isOnSale,
    required this.isActive,
  });

  factory BranchPrice.fromJson(Map<String, dynamic> json) {
    return BranchPrice(
      branchId: json['branchId'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      wholeSalePrice: (json['wholeSalePrice'] ?? 0).toDouble(),
      salePrice: json['salePrice'] != null ? (json['salePrice']).toDouble() : null,
      currency: json['currency'],
      stockQuantity: (json['stockQuantity'] ?? 0).toInt(),
      isOnSale: json['isOnSale'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'sku': sku,
      'price': price,
      'costPrice': costPrice,
      'wholeSalePrice': wholeSalePrice,
      'salePrice': salePrice,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'isOnSale': isOnSale,
      'isActive': isActive,
    };
  }

  /// الحصول على رمز العملة المناسب
  String get currencySymbol {
    switch (currency?.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'SYP':
        return 'SYP';
      case 'EUR':
        return '€';
      default:
        return '\$'; // افتراضي
    }
  }

  /// الحصول على اسم العملة
  String get currencyName {
    switch (currency?.toUpperCase()) {
      case 'USD':
        return 'دولار';
      case 'SYP':
        return 'ليرة سورية';
      case 'EUR':
        return 'يورو';
      default:
        return 'دولار';
    }
  }
}

class Product {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? subCategoryId;
  final List<String> branchesId;
  final List<BranchPrice> branchPricing;
  final String? brand;
  final String? model;
  final bool isActive;
  final bool isFeatured;
  final List<String> tags;
  final List<String> keywords;
  final ProductStatus? status;
  final int sortOrder;
  final Map<String, dynamic>? specifications;
  final List<String> images;
  final String mainImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.subCategoryId,
    required this.branchesId,
    required this.branchPricing,
    this.brand,
    this.model,
    required this.isActive,
    required this.isFeatured,
    required this.tags,
    required this.keywords,
    this.status,
    required this.sortOrder,
    this.specifications,
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
      categoryId: json['categoryId'] ?? '',
      subCategoryId: json['subCategoryId'],
      branchesId: List<String>.from(json['branches'] ?? []),
      branchPricing: (json['branchPricing'] as List? ?? [])
          .map((e) => BranchPrice.fromJson(e))
          .toList(),
      brand: json['brand'],
      model: json['model'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      status: _mapStatus(json['status']),
      sortOrder: json['sortOrder'] ?? 0,
      specifications: json['specifications'],
      images: List<String>.from(json['images'] ?? []),
      mainImage: json['mainImage'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'branches': branchesId,
      'branchPricing': branchPricing.map((e) => e.toJson()).toList(),
      'brand': brand,
      'model': model,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'tags': tags,
      'keywords': keywords,
      'status': status?.name,
      'sortOrder': sortOrder,
      'specifications': specifications,
      'images': images,
      'mainImage': mainImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BranchPrice? get currentBranchPrice {
    String? branchId = Get.find<AuthController>().currentUser?.selectedBranch;

    if (branchId == null || branchId.isEmpty) {
      branchId = StorageService.getBranchId();
    }

    if (branchId == null || branchId.isEmpty) return null;

    return branchPricing.firstWhereOrNull((bp) => bp.branchId == branchId);
  }

  double get price => currentBranchPrice?.price ?? 0;
  double? get salePrice => currentBranchPrice?.salePrice;
  int get stockQuantity => currentBranchPrice?.stockQuantity ?? 0;

  double get displayPrice {
    if (currentBranchPrice == null) return 0;
    if (currentBranchPrice!.isOnSale && currentBranchPrice!.salePrice != null) {
      return currentBranchPrice!.salePrice!;
    }
    return currentBranchPrice!.price;
  }

  bool get hasDiscount =>
      currentBranchPrice != null &&
          currentBranchPrice!.isOnSale &&
          currentBranchPrice!.salePrice != null &&
          currentBranchPrice!.salePrice! < currentBranchPrice!.price;

  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((currentBranchPrice!.price - currentBranchPrice!.salePrice!) /
        currentBranchPrice!.price) *
        100;
  }

  /// الحصول على رمز العملة
  String get currencySymbol => currentBranchPrice?.currencySymbol ?? '\$';

  /// الحصول على اسم العملة
  String get currencyName => currentBranchPrice?.currencyName ?? 'دولار';

  /// تنسيق السعر مع العملة
  String get formattedPrice {
    if (currentBranchPrice == null) return '0';

    final currency = currentBranchPrice!.currency?.toUpperCase() ?? 'USD';
    final priceValue = displayPrice.toStringAsFixed(0);

    switch (currency) {
      case 'USD':
        return '$priceValue \$';
      case 'SYP':
        return '$priceValue SYP';
      case 'EUR':
        return '$priceValue €';
      default:
        return '$priceValue \$';
    }
  }

  /// تنسيق السعر الأصلي مع العملة (قبل الخصم)
  String get formattedOriginalPrice {
    if (currentBranchPrice == null) return '0';

    final currency = currentBranchPrice!.currency?.toUpperCase() ?? 'USD';
    final priceValue = price.toStringAsFixed(0);

    switch (currency) {
      case 'USD':
        return '$priceValue \$';
      case 'SYP':
        return '$priceValue SYP';
      case 'EUR':
        return '$priceValue €';
      default:
        return '$priceValue \$';
    }
  }

  String get displayName => name;
  String get displayDescription => description ?? '';
  bool get inStock => stockQuantity > 0;

  static ProductStatus? _mapStatus(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return ProductStatus.values.firstWhereOrNull(
            (e) => e.name.toUpperCase() == value.toUpperCase(),
      );
    }
    return null;
  }
}