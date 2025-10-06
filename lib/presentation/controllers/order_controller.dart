import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../data/models/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../routes/app_routes.dart';
import 'auth_controller.dart';
import 'cart_controller.dart';
import '../widgets/common_widgets.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepository = OrderRepository();

  // state
  final RxList<Order> _orders = <Order>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isPlacingOrder = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Order?> _currentOrder = Rx<Order?>(null);

  // polling
  Timer? _ordersPoller;
  Timer? _detailsPoller;
  String? _watchingOrderId;

  // getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading.value;
  bool get isPlacingOrder => _isPlacingOrder.value;
  String get errorMessage => _errorMessage.value;
  Order? get currentOrder => _currentOrder.value;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    // _startOrdersPolling(); // تحديث فوري مُستمر لقائمة الطلبات
  }

  @override
  void onClose() {
    _stopOrdersPolling();
    _stopDetailsPolling();
    super.onClose();
  }

  // ---------- Real-time (Polling) ----------
  // void _startOrdersPolling({Duration interval = const Duration(seconds: 3)}) {
  //   _ordersPoller?.cancel();
  //   _ordersPoller = Timer.periodic(interval, (_) async {
  //     try {
  //       await _silentRefreshOrders();
  //     } catch (_) {}
  //   });
  // }

  void _stopOrdersPolling() {
    _ordersPoller?.cancel();
    _ordersPoller = null;
  }

  // void _startDetailsPolling(String orderId, {Duration interval = const Duration(seconds: 3)}) {
  //   _watchingOrderId = orderId;
  //   _detailsPoller?.cancel();
  //   _detailsPoller = Timer.periodic(interval, (_) async {
  //     try {
  //       final latest = await _orderRepository.getOrderById(orderId);
  //       // إذا تغيرت الحالة أو أي حقل، حدّث الكائن
  //       if (_currentOrder.value == null || latest.updatedAt.isAfter(_currentOrder.value!.updatedAt)) {
  //         _currentOrder.value = latest;
  //         // انعكاس الحالة داخل القائمة أيضاً
  //         final idx = _orders.indexWhere((o) => o.id == latest.id);
  //         if (idx != -1) _orders[idx] = latest;
  //       }
  //     } catch (_) {}
  //   });
  // }

  void _stopDetailsPolling() {
    _detailsPoller?.cancel();
    _detailsPoller = null;
    _watchingOrderId = null;
  }

  // ---------- API ops ----------
  Future<void> loadOrders() async {
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn || auth.currentUser == null) return;

      _isLoading.value = true;
      _errorMessage.value = '';
      final orders = await _orderRepository.getCustomerOrders();
      _orders.value = orders;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(context: Get.context!, message: 'فشل في تحميل الطلبات: $e', type: SnackBarType.error);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _silentRefreshOrders() async {
    try {
      final auth = Get.find<AuthController>();
      if (!auth.isLoggedIn || auth.currentUser == null) return;
      final orders = await _orderRepository.getCustomerOrders();
      if (orders.length != _orders.length) {
        _orders.value = orders;
      } else {
        for (final o in orders) {
          final idx = _orders.indexWhere((x) => x.id == o.id);
          if (idx != -1 && o.updatedAt.isAfter(_orders[idx].updatedAt)) {
            _orders[idx] = o;
          }
        }
      }
    } catch (_) {}
  }

  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      _errorMessage.value = '';

      final existing = _orders.firstWhere(
            (o) => o.id == orderId,
        orElse: () => _currentOrder.value ?? null as Order,

      );
      if (existing != null) {
        final st = existing.status.toLowerCase();
        if (st == 'shipped' || st == 'delivered' || st == 'cancelled') {
          ShamraSnackBar.show(
            context: Get.context!,
            message: 'لا يمكن إلغاء هذا الطلب في حالته الحالية.',
            type: SnackBarType.warning,
          );
          return false;
        }
      }

      final updated = await _orderRepository.cancelOrder(orderId, reason: reason);

      // تحديث العنصر بالقائمة
      final idx = _orders.indexWhere((o) => o.id == updated.id);
      if (idx != -1) _orders[idx] = updated;

      // تحديث الطلب الحالي
      if (_currentOrder.value?.id == updated.id) {
        _currentOrder.value = updated;
      }

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إلغاء الطلب بنجاح',
        type: SnackBarType.success,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل إلغاء الطلب: $e',
        type: SnackBarType.error,
      );
      return false;
    }
  }

  Future<bool> createOrderFromCart({
    required String branchId,
    String? notes,
    double? customTaxAmount,
    double? discountAmount,
    int? pointsToRedeem, // 🎯 إضافة
    String? currency, // 🎯 إضافة

  }) async {
    try {
      final auth = Get.find<AuthController>();
      final cart = Get.find<CartController>();

      if (!auth.isLoggedIn || auth.currentUser == null) {
        ShamraSnackBar.show(context: Get.context!, message: 'الرجاء تسجيل الدخول أولاً', type: SnackBarType.warning);
        return false;
      }
      if (cart.isEmpty) {
        ShamraSnackBar.show(context: Get.context!, message: 'سلة التسوق فارغة', type: SnackBarType.warning);
        return false;
      }

      _isPlacingOrder.value = true;
      _errorMessage.value = '';

      final order = await _orderRepository.createOrder(
        customerId: auth.currentUser!.id,
        branchId: branchId,
        items: cart.getOrderItems(),
        discountAmount: discountAmount ?? 0.0,
        notes: notes,
        pointsToRedeem: pointsToRedeem, // 🎯 إضافة
        currency: currency ?? 'USD', // 🎯 إضافة

      );

      _orders.insert(0, order);
      setCurrentOrder(order);

      await cart.clearCart();

      // 🎯 تحديث بيانات المستخدم لتحديث النقاط
      await auth.getProfile();

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إنشاء الطلب بنجاح! رقم الطلب: #${order.orderNumber}',
        type: SnackBarType.success,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(context: Get.context!, message: 'فشل في إنشاء الطلب: $e', type: SnackBarType.error);
      return false;
    } finally {
      _isPlacingOrder.value = false;
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final order = await _orderRepository.getOrderById(orderId);
      setCurrentOrder(order);
      return order;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(context: Get.context!, message: 'فشل في تحميل الطلب', type: SnackBarType.error);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final order = await _orderRepository.getOrderByNumber(orderNumber);
      setCurrentOrder(order);
      return order;
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(context: Get.context!, message: 'فشل في تحميل الطلب', type: SnackBarType.error);
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  // filters
  List<Order> getOrdersByStatus(String status) =>
      _orders.where((o) => o.status.toLowerCase() == status.toLowerCase()).toList();

  List<Order> get pendingOrders => getOrdersByStatus('pending');
  List<Order> get confirmedOrders => getOrdersByStatus('confirmed');
  List<Order> get shippedOrders => getOrdersByStatus('shipped');
  List<Order> get deliveredOrders => getOrdersByStatus('delivered');
  List<Order> get cancelledOrders => getOrdersByStatus('cancelled');

  List<Order> get activeOrders => pendingOrders + confirmedOrders + shippedOrders;
  List<Order> get completedOrders => deliveredOrders;

  Map<String, dynamic> get orderSummary => {
    'totalOrders': _orders.length,
    'totalAmount': _orders.fold(0.0, (sum, o) => sum + o.totalAmount),
    'pendingCount': pendingOrders.length,
    'deliveredCount': deliveredOrders.length,
  };

  // current
  void setCurrentOrder(Order order) {
    _currentOrder.value = order;
    // _startDetailsPolling(order.id);
  }

  void clearCurrentOrder() {
    _currentOrder.value = null;
    _stopDetailsPolling();
  }

  // دالة جديدة للتحقق من تغيير الطلب
  bool isCurrentOrder(String orderId) {
    return _currentOrder.value?.id == orderId;
  }

  Future<void> refreshOrders() async => await loadOrders();
  void clearErrorMessage() => _errorMessage.value = '';


  Future<void> placeOrderWithLocation({
    required String branchId,
    required double lat,
    required double lng,
    String? address,
    String? extraNotes,
    int? pointsToRedeem, // 🎯 إضافة
    String? currency, // 🎯 إضافة

  }) async {
    final locJson =
        '{"lat":${lat.toStringAsFixed(6)},"lng":${lng.toStringAsFixed(6)}'
        '${address != null ? ',"address":"${_sanitizeForNotes(address)}"' : ''}}';
    final locationBlock = '[LOC] $locJson [/LOC]';

    String mergedNotes;
    if (extraNotes != null && extraNotes.trim().isNotEmpty) {
      mergedNotes = '${extraNotes.trim()} | $locationBlock';
    } else {
      mergedNotes = locationBlock;
    }
    if (mergedNotes.length > 480) mergedNotes = mergedNotes.substring(0, 480);

    // ✅ اطبع ملخص ما سيتم تمريره (بما فيه notes)
    debugPrint('🗺️ Checkout location: lat=$lat, lng=$lng, address=${address ?? '-'}');
    debugPrint('🏪 Using branchId: $branchId');
    debugPrint('📝 Notes (merged) [len=${mergedNotes.length}]: $mergedNotes');

    await createOrderFromCart(
      branchId: branchId,
      notes: mergedNotes,
      pointsToRedeem: pointsToRedeem, // 🎯 إضافة
      currency: currency, // 🎯 إضافة
    );
  }

  String _sanitizeForNotes(String v) => v.replaceAll('"', "'");




}