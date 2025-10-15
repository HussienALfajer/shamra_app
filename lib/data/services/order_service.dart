import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/order.dart';

class OrderService {
  // Create order
  static Future<Order> createOrder({
    required String customerId,
    required String branchId,
    required List<OrderItem> items,
    required double discountAmount,
    String? notes,
    int? pointsToRedeem, // 🎯 إضافة
    String? currency, // 🎯 إضافة

  }) async {
    try {
      // ✅ جهّز الجسم الذي سيُرسل
      final payload = {
        'branchId': branchId,
        'items': items.map((item) => item.toJson()).toList(),
        'discountAmount': discountAmount,
        if (notes != null) 'notes': notes,
        if (pointsToRedeem != null) 'pointsToRedeem': pointsToRedeem, // 🎯 إضافة
        if (currency != null) 'currency': currency, // 🎯 إضافة

      };

      // ✅ اطبع الـ payload كـ JSON منسق
      try {
        final pretty = const JsonEncoder.withIndent('  ').convert(payload);
        debugPrint('🚀 Sending order payload to ${ApiConstants.orders}:\n$pretty');
      } catch (_) {
        debugPrint('🚀 Sending order payload (raw): $payload');
      }

      final response = await DioService.post(
        ApiConstants.orders,
        data: payload,
      );

      // ✅ اطبع ملخّص الاستجابة
      final data = response.data['data'];
      try {
        final prettyRes = const JsonEncoder.withIndent('  ').convert(data);
        debugPrint('✅ Order created. Server response:\n$prettyRes');
      } catch (_) {
        debugPrint('✅ Order created. Server response (raw): $data');
      }

      return Order.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  static Future<Order> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      final res = await DioService.patch(
        '${ApiConstants.orders}/$orderId/status',
        data: {'status': 'CANCELLED'.toLowerCase()},
      );
      return Order.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get orders for customer
  static Future<List<Order>> getCustomerOrders() async {
    try {
      final response = await DioService.get(ApiConstants.myOrders);

      return (response.data['data'] as List)
          .map((item) => Order.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get order by ID
  static Future<Order> getOrderById(String orderId) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.orders}/by-id/$orderId',
      );
      return Order.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get order by number
  static Future<Order> getOrderByNumber(String orderNumber) async {
    try {
      final response = await DioService.get(
        '${ApiConstants.orders}/number/$orderNumber',
      );
      return Order.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update order status
  static Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await DioService.patch(
        '${ApiConstants.orders}/$orderId/status',
        data: {'status': status},
      );

      return Order.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  static String _handleError(DioException error) {
    if (error.response?.data != null) {
      return error.response!.data['message'] ?? 'Something went wrong';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error. Please check your internet connection.';
    }
  }
}