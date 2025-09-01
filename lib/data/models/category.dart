class Category {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String slug;
  final String? parentId;
  final bool isActive;
  final int sortOrder;
  final List<Category> children;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    required this.slug,
    this.parentId,
    required this.isActive,
    required this.sortOrder,
    required this.children,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        nameAr: json['nameAr']?.toString() ?? '',
        description: json['description']?.toString(),
        descriptionAr: json['descriptionAr']?.toString(),
        slug: json['slug']?.toString() ?? '',
        parentId: json['parentId']?.toString(),
        isActive: _parseBool(json['isActive'], defaultValue: true),
        sortOrder: _parseInt(json['sortOrder']),
        children: _parseChildren(json['children']),
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

  static List<Category> _parseChildren(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((child) {
            try {
              return Category.fromJson(child as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing child category: $e');
              return null;
            }
          })
          .where((category) => category != null)
          .cast<Category>()
          .toList();
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
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'slug': slug,
      'parentId': parentId,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'children': children.map((child) => child.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : name;

  String get displayDescription =>
      descriptionAr?.isNotEmpty == true ? descriptionAr! : (description ?? '');

  bool get hasChildren => children.isNotEmpty;

  bool get isParent => parentId == null;
}
