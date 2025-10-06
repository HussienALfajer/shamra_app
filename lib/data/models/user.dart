import 'package:shamra_app/data/models/branch.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String branchId;
  final String selectedBranch;
  final Branch? selectedBranchObject;
  final int points;
  final int totalPointsEarned;
  final int totalPointsUsed;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.branchId,
    required this.selectedBranch,
    this.selectedBranchObject,
    this.points = 0, // 🎯
    this.totalPointsEarned = 0, // 🎯
    this.totalPointsUsed = 0, // 🎯

  });

  factory User.fromJson(Map<String, dynamic> json) {
    print("ٍِHHHHHHHHHHHHHHHHHHHHHHHHHHHHH${json['selectedBranchObject']}");
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'customer',
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      branchId: json['branchId'] ?? '',
      selectedBranch: json['selectedBranchId'] ?? '',
      selectedBranchObject: json['selectedBranchObject'] != null
          ? Branch.fromJson(json['selectedBranchObject'])
          : null,
      points: json['points'] ?? 0,
      totalPointsEarned: json['totalPointsEarned'] ?? 0,
      totalPointsUsed: json['totalPointsUsed'] ?? 0,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'branchId': branchId,
      'selectedBranchId': selectedBranch,
      "selectedBranchObject": selectedBranchObject?.toJson(),
      'points': points,
      'totalPointsEarned': totalPointsEarned,
      'totalPointsUsed': totalPointsUsed,

    };
  }

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? branchId,
    String? selectedBranch,
    int? points, // 🎯
    int? totalPointsEarned, // 🎯
    int? totalPointsUsed, // 🎯

  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchId: branchId ?? this.branchId,
      selectedBranch: selectedBranch ?? this.selectedBranch,
      selectedBranchObject: selectedBranchObject ?? this.selectedBranchObject,
      points: points ?? this.points,
      totalPointsEarned: totalPointsEarned ?? this.totalPointsEarned,
      totalPointsUsed: totalPointsUsed ?? this.totalPointsUsed,

    );
  }
}
