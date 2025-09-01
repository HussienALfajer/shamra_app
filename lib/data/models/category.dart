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
    return Category(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      slug: json['slug'] ?? '',
      parentId: json['parentId'],
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => Category.fromJson(child))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
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
  
  String get displayDescription => descriptionAr?.isNotEmpty == true ? descriptionAr! : (description ?? '');
  
  bool get hasChildren => children.isNotEmpty;
  
  bool get isParent => parentId == null;
}