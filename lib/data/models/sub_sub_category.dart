class SubSubCategory {
  final String id;
  final String name;
  final String? image;
  final String subCategoryId;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubSubCategory({
    required this.id,
    required this.name,
    this.image,
    required this.subCategoryId,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubSubCategory.fromJson(Map<String, dynamic> json) {
    try {
      return SubSubCategory(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        image: json['image']?.toString(),
        subCategoryId: json['subCategoryId']?.toString() ?? '',
        isActive: _parseBool(json['isActive'], defaultValue: true),
        isDeleted: _parseBool(json['isDeleted'], defaultValue: false),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('Error parsing SubSubCategory from JSON: $e');
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
      'subCategoryId': subCategoryId,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name;

  String get imageUrl => image ?? '';

  bool get hasImage => image != null && image!.isNotEmpty;
}
