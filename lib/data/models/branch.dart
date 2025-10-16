// lib/data/models/branch.dart
class Branch {
  final String id;
  final String name;
  final String? description;
  final String? phone;
  final String? email;
  final BranchAddress address;
  final String? managerId;
  final bool isActive;
  final bool isMainBranch;
  final int employeeCount;
  final double totalSales;
  final int totalOrders;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.email,
    required this.address,
    this.managerId,
    required this.isActive,
    required this.isMainBranch,
    required this.employeeCount,
    required this.totalSales,
    required this.totalOrders,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: BranchAddress.fromJson(json['address'] ?? {}),
      managerId: json['managerId']?.toString(),
      isActive: json['isActive'] ?? true,
      isMainBranch: json['isMainBranch'] ?? false,
      employeeCount: json['employeeCount'] ?? 0,
      totalSales: (json['totalSales'] ?? 0.0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'email': email,
      'address': address.toJson(),
      'managerId': managerId,
      'isActive': isActive,
      'isMainBranch': isMainBranch,
      'employeeCount': employeeCount,
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name;
  String get displayDescription => (description ?? '');
  String get fullAddress => address.fullAddress;
}

class BranchAddress {
  final String street;
  final String city;
  final String? country;
  final Coordinates? coordinates;

  BranchAddress({
    required this.street,
    required this.city,
    this.country,
    this.coordinates,
  });

  factory BranchAddress.fromJson(Map<String, dynamic> json) {
    return BranchAddress(
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      country: json['country']?.toString() ?? 'Syria',
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'country': country,
      'coordinates': coordinates?.toJson(),
    };
  }

  String get fullAddress {
    final parts = [
      street,
      city,
      country,
    ].where((part) => part?.isNotEmpty == true).toList();
    return parts.join(', ');
  }
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng};
  }
}