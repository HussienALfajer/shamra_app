import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import '../widgets/common_widgets.dart'; // يحتوي ShamraSnackBar

/// 📌 [OrderController] مسؤول عن إدارة الطلبات:
/// - تحميل جميع الطلبات من API.
/// - إنشاء طلب جديد من السلة.
/// - جلب تفاصيل الطلب حسب الرقم أو الـ ID.
/// - تصفية الطلبات حسب الحالة.
/// - عرض ملخص الطلبات (إحصائيات).
class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  // 🔹 الحالة الداخلية (Observables)
  final RxList<Order> _orders = <Order>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPlacingOrder = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Order?> _currentOrder = Rx<Order?>(null);

  // 🔹 Getters عامة
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

  /// ✅ تحميل جميع الطلبات للعميل الحالي
  Future<void> loadOrders() async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn || authController.currentUser == null) {
        return;
      }

      _isLoading.value = true;
      _errorMessage.value = '';

      final orders = await _orderRepository.getCustomerOrders();
      _orders.value = orders;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في تحميل الطلبات: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ إنشاء طلب جديد من السلة
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
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'الرجاء تسجيل الدخول أولاً',
          type: SnackBarType.warning,
        );
        return false;
      }

      if (cartController.isEmpty) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'سلة التسوق فارغة',
          type: SnackBarType.warning,
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

      _orders.insert(0, order);
      _currentOrder.value = order;

      await cartController.clearCart();

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إنشاء الطلب بنجاح! رقم الطلب: #${order.orderNumber}',
        type: SnackBarType.success,
      );

      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في إنشاء الطلب: ${e.toString()}',
        type: SnackBarType.error,
      );
      return false;
    } finally {
      _isPlacingOrder.value = false;
    }
  }

  /// ✅ جلب تفاصيل الطلب بالـ ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      _isLoading.value = true;
      final order = await _orderRepository.getOrderById(orderId);
      _currentOrder.value = order;
      return order;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في تحميل الطلب',
        type: SnackBarType.error,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ جلب تفاصيل الطلب برقم الطلب
  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      _isLoading.value = true;
      final order = await _orderRepository.getOrderByNumber(orderNumber);
      _currentOrder.value = order;
      return order;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في تحميل الطلب',
        type: SnackBarType.error,
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// ✅ تصفية الطلبات حسب الحالة
  List<Order> getOrdersByStatus(String status) {
    return _orders
        .where((order) => order.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // 🔹 Getters خاصة بالحالات
  List<Order> get pendingOrders => getOrdersByStatus('pending');
  List<Order> get confirmedOrders => getOrdersByStatus('confirmed');
  List<Order> get shippedOrders => getOrdersByStatus('shipped');
  List<Order> get deliveredOrders => getOrdersByStatus('delivered');
  List<Order> get cancelledOrders => getOrdersByStatus('cancelled');

  // 🔹 إضافات لتفادي الأخطاء في OrdersPage
  List<Order> get activeOrders =>
      pendingOrders + confirmedOrders + shippedOrders;
  List<Order> get completedOrders => deliveredOrders;

  /// ✅ إحصائيات الطلبات
  Map<String, dynamic> get orderSummary {
    return {
      'totalOrders': _orders.length,
      'totalAmount':
      _orders.fold(0.0, (sum, order) => sum + order.totalAmount),
      'pendingCount': pendingOrders.length,
      'deliveredCount': deliveredOrders.length,
    };
  }

  /// ✅ التحكم بالطلب الحالي
  void setCurrentOrder(Order order) => _currentOrder.value = order;
  void clearCurrentOrder() => _currentOrder.value = null;

  /// ✅ إعادة تحميل الطلبات
  Future<void> refreshOrders() async => await loadOrders();

  /// ✅ مسح رسالة الخطأ
  void clearErrorMessage() => _errorMessage.value = '';
}
