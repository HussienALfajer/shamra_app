class Category {
  final String id;
  final String name;
  final String? description;
  final String? image; // ✅ أضفنا حقل الصورة
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image, // ✅
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        image: json['image']?.toString(), // ✅
        isActive: _parseBool(json['isActive'], defaultValue: true),
        sortOrder: _parseInt(json['sortOrder']),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('Error parsing Category from JSON: $e');
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
      'name': name,
      'description': description,
      'image': image, // ✅
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name;

  String get displayDescription => (description ?? '');

  String get displayImage => image ?? ''; // ✅ Getter مفيد لو بدك تستخدمه
}
