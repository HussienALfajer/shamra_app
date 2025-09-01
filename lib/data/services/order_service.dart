import 'package:dio/dio.dart';
import '../../core/services/dio_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/order.dart';

class OrderService {
  // Create order
  static Future<Order> createOrder({
    required String customerId,
    required String branchId,
    required List<OrderItem> items,
    required double taxAmount,
    required double discountAmount,
    String? notes,
  }) async {
    try {
      final response = await DioService.post(
        ApiConstants.orders,
        data: {
          'customerId': customerId,
          'branchId': branchId,
          'items': items.map((item) => item.toJson()).toList(),
          'taxAmount': taxAmount,
          'discountAmount': discountAmount,
          if (notes != null) 'notes': notes,
        },
      );

      return Order.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get orders for customer
  static Future<List<Order>> getCustomerOrders({
    required String customerId,
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await DioService.get(
        ApiConstants.orders,
        queryParameters: {
          'customerId': customerId,
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

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
      final response = await DioService.get('${ApiConstants.orders}/$orderId');
      return Order.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get order by number
  static Future<Order> getOrderByNumber(String orderNumber) async {
    try {
      final response = await DioService.get('${ApiConstants.orders}/number/$orderNumber');
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