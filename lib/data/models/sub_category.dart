enum SubCategoryType {
  freeAttr('FREE_ATTR'),
  customAttr('CUSTOM_ATTR');

  const SubCategoryType(this.value);
  final String value;

  static SubCategoryType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FREE_ATTR':
        return SubCategoryType.freeAttr;
      case 'CUSTOM_ATTR':
        return SubCategoryType.customAttr;
      default:
        return SubCategoryType.freeAttr;
    }
  }
}

class SubCategory {
  final String id;
  final String name;
  final String? image;
  final String categoryId;
  final SubCategoryType type;
  final List<String> customFields;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.name,
    this.image,
    required this.categoryId,
    required this.type,
    required this.customFields,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    try {
      print(json);
      return SubCategory(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString(),
        categoryId: json['categoryId']?.toString() ?? '',
        type: SubCategoryType.fromString(
          json['type']?.toString() ?? 'FREE_ATTR',
        ),
        customFields: _parseStringList(json['customFields']),
        isActive: _parseBool(json['isActive'], defaultValue: true),
        isDeleted: _parseBool(json['isDeleted'], defaultValue: false),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('Error parsing SubCategory from JSON: $e');
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

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
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
      'name': name,
      'image': image,
      'categoryId': categoryId,
      'type': type.value,
      'customFields': customFields,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name;

  String get imageUrl => image ?? '';

  bool get hasImage => image != null && image!.isNotEmpty;

  bool get hasCustomFields => customFields.isNotEmpty;

  String get typeDisplayName {
    switch (type) {
      case SubCategoryType.freeAttr:
        return 'خصائص حرة';
      case SubCategoryType.customAttr:
        return 'خصائص مخصصة';
    }
  }
}