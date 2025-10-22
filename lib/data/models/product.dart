///////////////////////////////////////////////
// lib/data/models/product.dart
// Product model + Branch pricing helpers.
// EN comments only.

import 'package:get/get.dart';
import 'package:collection/collection.dart';
import '../../core/services/storage_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../utils/currency_helper.dart';

enum ProductStatus { ACTIVE, INACTIVE, DRAFT, ARCHIVED }

enum Currency { USD, SYP, EUR }

/// Helper: convert dynamic to double safely
double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

/// Helper: convert dynamic to int safely
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
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
      price: _toDouble(json['price']),
      costPrice: _toDouble(json['costPrice']),
      wholeSalePrice: _toDouble(json['wholeSalePrice']),
      salePrice: json['salePrice'] != null
          ? _toDouble(json['salePrice'])
          : null,
      currency: json['currency'],
      stockQuantity: _toInt(json['stockQuantity']),
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

  /// Currency symbol for display (dynamic)
  String get currencySymbol => CurrencyHelper.symbol(currency);

  /// Currency name (Arabic, can localize later).
  String get currencyName => CurrencyHelper.nameAr(currency);
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
          .map((e) => BranchPrice.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      brand: json['brand'],
      model: json['model'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      status: _mapStatus(json['status']),
      sortOrder: json['sortOrder'] ?? 0,
      specifications: json['specifications'] != null
          ? Map<String, dynamic>.from(json['specifications'])
          : null,
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

  /// Get branch-specific price based on currently selected branch.
  BranchPrice? get currentBranchPrice {
    String? branchId;
    try {
      branchId = Get.find<AuthController>().currentUser?.selectedBranch;
    } catch (_) {
      // AuthController may not be available in some contexts; fall back to storage.
    }

    branchId = branchId ?? StorageService.getBranchId();

    if (branchId == null || branchId.isEmpty) return null;

    return branchPricing.firstWhereOrNull((bp) => bp.branchId == branchId);
  }

  /// Check if current user is a merchant (merchant pricing).
  bool get _isCurrentUserMerchant {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser?.role == 'merchant';
    } catch (e) {
      return false;
    }
  }

  /// Base price (depends on user role).
  double get price {
    if (currentBranchPrice == null) return 0;
    return _isCurrentUserMerchant
        ? currentBranchPrice!.wholeSalePrice
        : currentBranchPrice!.price;
  }

  /// Sale price if exists.
  double? get salePrice => currentBranchPrice?.salePrice;

  /// Stock available in selected branch.
  int get stockQuantity => currentBranchPrice?.stockQuantity ?? 0;

  /// Display price (considers sale and user role).
  double get displayPrice {
    if (currentBranchPrice == null) return 0;

    if (currentBranchPrice!.isOnSale && currentBranchPrice!.salePrice != null) {
      return currentBranchPrice!.salePrice!;
    }

    return _isCurrentUserMerchant
        ? currentBranchPrice!.wholeSalePrice
        : currentBranchPrice!.price;
  }

  /// Whether product currently has discount
  bool get hasDiscount {
    if (currentBranchPrice == null) return false;

    final basePrice = _isCurrentUserMerchant
        ? currentBranchPrice!.wholeSalePrice
        : currentBranchPrice!.price;

    return currentBranchPrice!.isOnSale &&
        currentBranchPrice!.salePrice != null &&
        currentBranchPrice!.salePrice! < basePrice;
  }

  /// Discount percentage (if any)
  double? get discountPercentage {
    if (!hasDiscount) return null;

    final basePrice = _isCurrentUserMerchant
        ? currentBranchPrice!.wholeSalePrice
        : currentBranchPrice!.price;

    return ((basePrice - currentBranchPrice!.salePrice!) / basePrice) * 100;
  }

  /// Currency symbol for display
  String get currencySymbol =>
      CurrencyHelper.symbol(currentBranchPrice?.currency);

  /// Currency name for display (Arabic)
  String get currencyName =>
      CurrencyHelper.nameAr(currentBranchPrice?.currency);

  /// Format numbers: drop unnecessary decimals. (kept for compatibility)
  String _formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    } else {
      return number
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  /// Formatted price string for UI (via helper)
  String get formattedPrice {
    if (currentBranchPrice == null) return '0';
    final code = currentBranchPrice!.currency;
    return CurrencyHelper.formatAmount(displayPrice, code: code);
  }

  /// Formatted original (base) price (via helper)
  String get formattedOriginalPrice {
    if (currentBranchPrice == null) return '0';
    final basePrice = _isCurrentUserMerchant
        ? currentBranchPrice!.wholeSalePrice
        : currentBranchPrice!.price;
    return CurrencyHelper.formatAmount(basePrice,
        code: currentBranchPrice!.currency);
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
