import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  // Observables
  final RxList<Order> _orders = <Order>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPlacingOrder = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Order?> _currentOrder = Rx<Order?>(null);

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading.value;
  bool get isPlacingOrder => _isPlacingOrder.value;
  String get errorMessage => _errorMessage.value;
  Order? get currentOrder => _currentOrder.value;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Load customer orders
  Future<void> loadOrders() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn || authController.currentUser == null) {
        return;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final orders = await _orderRepository.getCustomerOrders(
        customerId: authController.currentUser!.id,
        limit: 50,
      );

      _orders.value = orders;

    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load orders: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Create order from cart
  Future<bool> createOrderFromCart({
    required String branchId,
    String? notes,
    double? customTaxAmount,
    double? discountAmount,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final cartController = Get.find<CartController>();

      if (!authController.isLoggedIn || authController.currentUser == null) {
        Get.snackbar(
          'Error',
          'Please login to place an order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      if (cartController.isEmpty) {
        Get.snackbar(
          'Error',
          'Your cart is empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return false;
      }

      _isPlacingOrder.value = true;
      _errorMessage.value = '';

      final order = await _orderRepository.createOrder(
        customerId: authController.currentUser!.id,
        branchId: branchId,
        items: cartController.getOrderItems(),
        taxAmount: customTaxAmount ?? cartController.taxAmount,
        discountAmount: discountAmount ?? 0.0,
        notes: notes,
      );

      // Add order to local list
      _orders.insert(0, order);
      _currentOrder.value = order;

      // Clear cart after successful order
      await cartController.clearCart();

      Get.snackbar(
        'Success',
        'Order placed successfully! Order #${order.orderNumber}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      return true;

    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to place order: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      _isPlacingOrder.value = false;
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      _isLoading.value = true;
      final order = await _orderRepository.getOrderById(orderId);
      _currentOrder.value = order;
      return order;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load order: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get order by number
  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      _isLoading.value = true;
      final order = await _orderRepository.getOrderByNumber(orderNumber);
      _currentOrder.value = order;
      return order;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load order: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get pending orders
  List<Order> get pendingOrders => getOrdersByStatus('pending');

  // Get confirmed orders
  List<Order> get confirmedOrders => getOrdersByStatus('confirmed');

  // Get shipped orders
  List<Order> get shippedOrders => getOrdersByStatus('shipped');

  // Get delivered orders
  List<Order> get deliveredOrders => getOrdersByStatus('delivered');

  // Get cancelled orders
  List<Order> get cancelledOrders => getOrdersByStatus('cancelled');

  // Calculate order summary
  Map<String, dynamic> get orderSummary {
    final totalOrders = _orders.length;
    final totalAmount = _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final pendingCount = pendingOrders.length;
    final deliveredCount = deliveredOrders.length;

    return {
      'totalOrders': totalOrders,
      'totalAmount': totalAmount,
      'pendingCount': pendingCount,
      'deliveredCount': deliveredCount,
    };
  }

  // Set current order
  void setCurrentOrder(Order order) {
    _currentOrder.value = order;
  }

  // Clear current order
  void clearCurrentOrder() {
    _currentOrder.value = null;
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadOrders();
  }

  // Clear error message
  void clearErrorMessage() {
    _errorMessage.value = '';
  }

  // Show order confirmation dialog
  void showOrderConfirmation(Order order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Order Confirmed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Number: ${order.orderNumber}'),
            Text('Total Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
            Text('Status: ${order.statusDisplay}'),
            const SizedBox(height: 8),
            const Text('Thank you for your order!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/order-details', arguments: order);
            },
            child: const Text('View Order'),
          ),
        ],
      ),
    );
  }
}