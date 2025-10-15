import 'dart:convert';

class OrderNotification {
  final String id;
  final String title;
  final String body;
  final String orderId;
  final DateTime createdAt;
  final bool isRead;

  OrderNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.orderId,
    required this.createdAt,
    this.isRead = false,
  });

  OrderNotification copyWith({bool? isRead}) => OrderNotification(
    id: id,
    title: title,
    body: body,
    orderId: orderId,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'orderId': orderId,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory OrderNotification.fromMap(Map<String, dynamic> m) => OrderNotification(
    id: m['id'] ?? '',
    title: m['title'] ?? '',
    body: m['body'] ?? '',
    orderId: m['orderId'] ?? '',
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
    isRead: m['isRead'] ?? false,
  );

  String toJson() => jsonEncode(toMap());
  factory OrderNotification.fromJson(String s) => OrderNotification.fromMap(jsonDecode(s));
}