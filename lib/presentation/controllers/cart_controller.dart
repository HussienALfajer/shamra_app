import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shamra_app/data/models/order.dart';
import '../../data/models/cart.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../widgets/common_widgets.dart'; // ✅ لاستخدام ShamraSnackBar

/// 🛒 CartController
/// - مسؤول عن إدارة حالة السلة (إضافة/إزالة/تحديث المنتجات).
/// - يتعامل مع CartRepository لحفظ واسترجاع البيانات.
/// - يستخدم GetX لإدارة الحالة بشكل تفاعلي.
class CartController extends GetxController {
  final CartRepository _cartRepository = CartRepository();

  // 🔹 الحالة (State)
  final Rx<Cart> _cart = Cart().obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // 🔹 Getters (الوصول إلى البيانات)
  Cart get cart => _cart.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  List<CartItem> get items => _cart.value.items;
  int get itemCount => _cart.value.totalItems;
  double get subtotal => _cart.value.subtotal;
  double get total => subtotal;
  bool get isEmpty => _cart.value.isEmpty;
  bool get isNotEmpty => _cart.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  /// 🔹 تحميل السلة من التخزين
  Future<void> loadCart() async {
    try {
      _isLoading.value = true;
      final cart = await _cartRepository.loadCart();
      _cart.value = cart;
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// 🔹 إضافة منتج إلى السلة
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    try {
      _cart.value.addItem(product, quantity: quantity);
      await _cartRepository.saveCart(_cart.value);

      ShamraSnackBar.show(
        context: Get.context!,
        message: '${product.name} تمت إضافته إلى السلة',
        type: SnackBarType.success,
      );

      _cart.refresh(); // ✅ تحديث الـ UI
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في إضافة المنتج إلى السلة',
        type: SnackBarType.error,
      );
    }
  }

  /// 🔹 إزالة منتج من السلة
  Future<void> removeFromCart(String productId) async {
    try {
      final item = _cart.value.getItem(productId);
      if (item != null) {
        _cart.value.removeItem(productId);
        await _cartRepository.saveCart(_cart.value);

        ShamraSnackBar.show(
          context: Get.context!,
          message: '${item.product.name} تمت إزالته من السلة',
          type: SnackBarType.warning,
        );

        _cart.refresh();
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في إزالة المنتج من السلة',
        type: SnackBarType.error,
      );
    }
  }

  /// 🔹 تحديث كمية منتج
  Future<void> updateItemQuantity(String productId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      _cart.value.updateItemQuantity(productId, newQuantity);
      _cartRepository.saveCart(_cart.value);

      _cart.refresh();
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في تحديث الكمية',
        type: SnackBarType.error,
      );
    }
  }

  /// 🔹 زيادة الكمية
  Future<void> incrementQuantity(String productId) async {
    final item = _cart.value.getItem(productId);
    if (item != null) {
      await updateItemQuantity(productId, item.quantity + 1);
    }
  }

  /// 🔹 تقليل الكمية
  Future<void> decrementQuantity(String productId) async {
    final item = _cart.value.getItem(productId);
    if (item != null) {
      await updateItemQuantity(productId, item.quantity - 1);
    }
  }

  /// 🔹 تفريغ السلة
  Future<void> clearCart() async {
    try {
      _cart.value.clear();
      await _cartRepository.saveCart(_cart.value);

      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تم إفراغ السلة بنجاح',
        type: SnackBarType.warning,
      );

      _cart.refresh();
    } catch (e) {
      _errorMessage.value = e.toString();
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'فشل في إفراغ السلة',
        type: SnackBarType.error,
      );
    }
  }

  /// 🔹 هل المنتج موجود في السلة؟
  bool isInCart(String productId) => _cart.value.contains(productId);

  /// 🔹 الحصول على كمية منتج في السلة
  int getProductQuantity(String productId) =>
      _cart.value.getItem(productId)?.quantity ?? 0;

  /// 🔹 الحصول على عنصر السلة عبر الـ ID
  CartItem? getCartItem(String productId) => _cart.value.getItem(productId);


  /// 🔹 ضبط أجور الشحن

  /// 🔹 تجهيز عناصر الطلب من السلة
  List<OrderItem> getOrderItems() => _cart.value.toOrderItems();

  /// 🔹 مسح رسالة الخطأ
  void clearErrorMessage() => _errorMessage.value = '';

  /// 🔹 عرض ملخص السلة في Dialog
  void showCartSummary() {
    Get.dialog(
      AlertDialog(
        title: const Text('ملخص السلة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العناصر: $itemCount'),
            Text('الإجمالي: ${subtotal.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              'المجموع: ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/checkout');
            },
            child: const Text('إتمام الطلب'),
          ),
        ],
      ),
    );
  }
}