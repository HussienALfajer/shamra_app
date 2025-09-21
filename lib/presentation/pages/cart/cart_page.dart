import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../data/utils/helpers.dart';
import '../../../data/models/cart.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common_widgets.dart';

/// 🛒 صفحة السلة Cart Page
/// - تعرض المنتجات المضافة إلى السلة
/// - تسمح بتغيير الكميات أو حذف منتج
/// - تعرض المجموع النهائي مع زر "إتمام الطلب"
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    // التأكد من وجود OrderController
    Get.put(OrderController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "السلة",
          actions: [
            IconButton(
              onPressed: cartController.showCartSummary,
              icon: Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.black,
                size: 25,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        body: GetBuilder<CartController>(
          init: CartController(),
          builder: (cartController) => Obx(() {
            if (cartController.isLoading) {
              return const LoadingWidget(message: "جاري تحميل السلة...");
            }

            if (cartController.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                /// 🔹 قائمة المنتجات
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartController.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartController.items[index];
                      return _buildCartItemCard(cartItem, cartController);
                    },
                  ),
                ),

                /// 🔹 قسم المجموع وزر إتمام الطلب
                _buildBottomSection(cartController, context),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// 🔹 عنصر منتج داخل السلة
  Widget _buildCartItemCard(CartItem cartItem, CartController cartController) {
    return ShamraCard(
      onTap: () =>
          Get.toNamed(Routes.productDetails, arguments: cartItem.product),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          /// صورة المنتج
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: HelperMethod.getImageUrl(cartItem.product.mainImage),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(
                Icons.image_outlined,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),

          /// تفاصيل المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                /// السعر
                Text(
                  "${cartItem.price.toStringAsFixed(0)} ${AppConstants.currency}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                /// أدوات التحكم في الكمية
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          cartController.decrementQuantity(cartItem.product.id),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      cartItem.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          cartController.incrementQuantity(cartItem.product.id),
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// زر الحذف
          IconButton(
            onPressed: () => cartController.removeFromCart(cartItem.product.id),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  /// 🔹 قسم المجموع وزر إتمام الطلب
  Widget _buildBottomSection(
      CartController cartController,
      BuildContext context,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          /// تفاصيل الحساب
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildPriceRow('المجموع الفرعي', cartController.subtotal),
                const SizedBox(height: 8),
                _buildPriceRow('الضريبة', cartController.taxAmount),
                if (cartController.shippingFee > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow('الشحن', cartController.shippingFee),
                ],
                const Divider(thickness: 1),
                _buildPriceRow(
                  'المجموع النهائي',
                  cartController.total,
                  isTotal: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// زر إتمام الطلب
          ShamraButton(
            text: "إتمام الطلب (${cartController.itemCount} منتج)",
            onPressed: () => _handleCheckout(cartController, context),
            icon: Icons.shopping_cart_checkout,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  /// 🔹 صف السعر
  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          "${amount.toStringAsFixed(0)} ${AppConstants.currency}",
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 🔹 حالة السلة الفارغة
  Widget _buildEmptyCart() {
    return EmptyStateWidget(
      action: ShamraButton(
        text: 'ابدأ التسوق الان',
        onPressed: () => Get.offAllNamed(Routes.main),
      ),
      icon: Icons.shopping_cart_outlined,
      title: "سلة التسوق فارغة",
      message: "ابدأ بإضافة منتجات رائعة إلى السلة الآن",
    );
  }

  /// 🔹 معالجة الضغط على زر "إتمام الطلب" - محدثة
  void _handleCheckout(CartController cartController, BuildContext context) async {
    final authController = Get.find<AuthController>();

    // التحقق من تسجيل الدخول
    if (!authController.isLoggedIn) {
      ShamraSnackBar.show(
        context: context,
        message: "يرجى تسجيل الدخول أولاً",
        type: SnackBarType.warning,
        actionLabel: "تسجيل دخول",
        onAction: () => Get.toNamed(Routes.login),
      );
      return;
    }

    // التحقق من وجود منتجات في السلة
    if (cartController.isEmpty) {
      ShamraSnackBar.show(
        context: context,
        message: "سلة التسوق فارغة",
        type: SnackBarType.warning,
      );
      return;
    }

    // التحقق من اختيار الفرع
    final branchId = authController.currentUser?.selectedBranch ??
        authController.savedBranchId;

    if (branchId == null || branchId.isEmpty) {
      ShamraSnackBar.show(
        context: context,
        message: "يرجى اختيار الفرع أولاً",
        type: SnackBarType.warning,
        actionLabel: "اختيار فرع",
        onAction: () => Get.toNamed(Routes.branchSelection),
      );
      return;
    }

    try {
      // عرض dialog تأكيد الطلب
      final confirmed = await _showOrderConfirmationDialog(context, cartController);
      if (!confirmed) return;

      // إنشاء الطلب
      final orderController = Get.find<OrderController>();

      final success = await orderController.createOrderFromCart(
        branchId: branchId,
        notes: null,
        customTaxAmount: cartController.taxAmount,
        discountAmount: 0.0,
      );

      if (success) {
        // الطلب تم بنجاح - الانتقال لصفحة الطلبات
        Get.offNamed(Routes.orders);
      }

    } catch (e) {
      ShamraSnackBar.show(
        context: context,
        message: "حدث خطأ أثناء إنشاء الطلب: $e",
        type: SnackBarType.error,
      );
    }
  }

  /// 🔹 عرض dialog تأكيد الطلب
  Future<bool> _showOrderConfirmationDialog(
      BuildContext context,
      CartController cartController
      ) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.shopping_cart_checkout, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'تأكيد الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من إتمام هذا الطلب؟',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('عدد المنتجات:'),
                      Text(
                        '${cartController.itemCount} منتج',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المجموع الفرعي:'),
                      Text(
                        '${cartController.subtotal.toStringAsFixed(0)} ر.س',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الضريبة:'),
                      Text(
                        '${cartController.taxAmount.toStringAsFixed(0)} ر.س',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المجموع النهائي:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${cartController.total.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تأكيد الطلب',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}