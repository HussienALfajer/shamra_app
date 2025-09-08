import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/data/utils/helpers.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/cart.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: const Text(
            'سلة التسوق',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            GetBuilder<CartController>(
              builder: (cartController) => Obx(() {
                if (cartController.isNotEmpty) {
                  return IconButton(
                    onPressed: () => _showClearCartDialog(cartController),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'إفراغ السلة',
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
        body: GetBuilder<CartController>(
          init: CartController(),
          builder: (cartController) => Obx(() {
            if (cartController.isLoading) {
              return const LoadingWidget(message: 'جاري تحميل السلة...');
            }

            if (cartController.isEmpty) {
              return _buildEmptyCart();
            }

            return Column(
              children: [
                // Cart Items
                Expanded(child: _buildCartItems(cartController)),

                // Cart Summary and Checkout
                _buildCartSummary(cartController),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppColors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'سلة التسوق فارغة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'ابدأ بإضافة منتجات إلى سلة التسوق',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ShamraButton(
              text: 'تسوق الآن',
              onPressed: () => Get.back(),
              icon: Icons.shopping_bag_outlined,
              isSecondary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(CartController cartController) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartController.items.length,
      itemBuilder: (context, index) {
        final cartItem = cartController.items[index];
        return _buildCartItemCard(cartItem, cartController);
      },
    );
  }

  Widget _buildCartItemCard(CartItem cartItem, CartController cartController) {
    return ShamraCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12),
              image: cartItem.product.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(
                        HelperMethod.getImageUrl(cartItem.product.mainImage),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: cartItem.product.images.isEmpty
                ? const Icon(
                    Icons.image_outlined,
                    color: AppColors.grey,
                    size: 32,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // Product Details
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                if (cartItem.product.hasDiscount) ...[
                  Row(
                    children: [
                      Text(
                        '${cartItem.product.price.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${cartItem.product.discountPercentage?.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],

                Text(
                  '${cartItem.price.toStringAsFixed(0)} ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'المجموع: ${cartItem.total.toStringAsFixed(0)} ر.س',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Quantity Controls
          Column(
            children: [
              _buildQuantityControls(cartItem, cartController),

              const SizedBox(height: 8),

              IconButton(
                onPressed: () =>
                    cartController.removeFromCart(cartItem.product.id),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  minimumSize: const Size(40, 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(
    CartItem cartItem,
    CartController cartController,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () =>
                cartController.decrementQuantity(cartItem.product.id),
            icon: const Icon(Icons.remove, size: 16),
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),

          Container(
            width: 40,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppColors.outline),
              ),
            ),
            child: Text(
              cartItem.quantity.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          IconButton(
            onPressed: () =>
                cartController.incrementQuantity(cartItem.product.id),
            icon: const Icon(Icons.add, size: 16),
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartController cartController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary Details
          _buildSummaryRow('عدد المنتجات', '${cartController.itemCount}'),
          _buildSummaryRow(
            'المجموع الفرعي',
            '${cartController.subtotal.toStringAsFixed(0)} ر.س',
          ),
          _buildSummaryRow(
            'الضريبة',
            '${cartController.taxAmount.toStringAsFixed(0)} ر.س',
          ),
          if (cartController.shippingFee > 0)
            _buildSummaryRow(
              'رسوم الشحن',
              '${cartController.shippingFee.toStringAsFixed(0)} ر.س',
            ),

          const ShamraDivider(),

          _buildSummaryRow(
            'المجموع الكلي',
            '${cartController.total.toStringAsFixed(0)} ر.س',
            isTotal: true,
          ),

          const SizedBox(height: 20),

          // Checkout Button
          ShamraButton(
            text: 'متابعة للدفع',
            onPressed: () => _handleCheckout(cartController),
            icon: Icons.payment_rounded,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(CartController cartController) {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'يرجى تسجيل الدخول أولاً',
        type: SnackBarType.warning,
        actionLabel: 'تسجيل دخول',
        onAction: () => Get.toNamed('/login'),
      );
      return;
    }

    // Navigate to checkout page
    Get.toNamed('/checkout');
  }

  void _showClearCartDialog(CartController cartController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'إفراغ السلة',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من إفراغ سلة التسوق؟ سيتم حذف جميع المنتجات.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ShamraButton(
            text: 'إفراغ السلة',
            onPressed: () {
              Get.back();
              cartController.clearCart();
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }
}
