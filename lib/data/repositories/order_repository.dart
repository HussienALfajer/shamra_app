import '../models/order.dart';
import '../services/order_service.dart';

class OrderRepository {
  // Create order
  Future<Order> createOrder({
    required String customerId,
    required String branchId,
    required List<OrderItem> items,
    required double discountAmount,
    String? notes,
    int? pointsToRedeem,
    String? currency,

  }) async {
    try {
      return await OrderService.createOrder(
        customerId: customerId,
        branchId: branchId,
        items: items,
        discountAmount: discountAmount,
        notes: notes,
        pointsToRedeem: pointsToRedeem,
        currency: currency,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> cancelOrder(String orderId, {String? reason}) async {
    try {
      return await OrderService.cancelOrder(orderId: orderId, reason: reason);
    } catch (e) {
      rethrow;
    }
  }

  // Get orders for customer
  Future<List<Order>> getCustomerOrders() async {
    try {
      return await OrderService.getCustomerOrders();
    } catch (e) {
      rethrow;
    }
  }

  // Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      return await OrderService.getOrderById(orderId);
    } catch (e) {
      rethrow;
    }
  }

  // Get order by number
  Future<Order> getOrderByNumber(String orderNumber) async {
    try {
      return await OrderService.getOrderByNumber(orderNumber);
    } catch (e) {
      rethrow;
    }
  }

  // Update order status
  Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      return await OrderService.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
    } catch (e) {
      rethrow;
    }
  }
}