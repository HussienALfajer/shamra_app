import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/utils/helpers.dart';
import '../../../data/models/cart.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/branch_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common_widgets.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final main = Get.find<MainController>();

    // Ensure OrderController is available
    Get.put(OrderController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () async {
          final handled = main.backToPreviousTab();
          return !handled;
        },
        child: Scaffold(
          appBar: CustomAppBar(title: "السلة"),
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

              final main = Get.find<MainController>();
              return Column(
                children: [
                  // Cart items list
                  Expanded(
                    child: ListView.builder(
                      controller: main.cartScrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: cartController.items.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartController.items[index];
                        return _buildCartItemCard(cartItem, cartController);
                      },
                    ),
                  ),
                  // Totals section + Checkout button
                  _buildBottomSection(cartController, context),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // Single cart item card
  Widget _buildCartItemCard(CartItem cartItem, CartController cartController) {
    return ShamraCard(
      onTap: () =>
          Get.toNamed(Routes.productDetails, arguments: cartItem.product.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product image
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

          // Product details
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
                Text(
                  "${cartItem.price.toStringAsFixed(1)} ${AppConstants.currency}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity controls
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

          // Delete with confirmation
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text('تأكيد الحذف'),
                  content: const Text(
                    'هل أنت متأكد أنك تريد إزالة هذا المنتج من السلة؟',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        cartController.removeFromCart(cartItem.product.id);
                        Get.back();
                      },
                      child: const Text('حذف'),
                    ),
                  ],
                ),
                barrierDismissible: false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Bottom totals + checkout
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
          // Total summary box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'المجموع النهائي لا يتضمن مصاريف الشحن',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
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

          // Checkout button
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

  // Price line
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

  // Empty cart state
  Widget _buildEmptyCart() {
    return const EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: "سلة التسوق فارغة",
      message: "ابدأ بإضافة منتجات رائعة إلى السلة الآن",
    );
  }

  // Checkout flow with map selection and notes
  // في cart_page.dart - تحديث _handleCheckout
  void _handleCheckout(
    CartController cartController,
    BuildContext context,
  ) async {
    final authController = Get.find<AuthController>();

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
    if (cartController.isEmpty) {
      ShamraSnackBar.show(
        context: context,
        message: "سلة التسوق فارغة",
        type: SnackBarType.warning,
      );
      return;
    }

    // 🎯 عرض dialog لاختيار النقاط
    final pointsData = await _showPointsDialog(
      context,
      authController,
      cartController,
    );
    if (pointsData == null) return; // المستخدم ألغى

    final result = await Get.toNamed(Routes.selectLocation);
    if (result is! Map) return;

    final lat = (result['lat'] as num?)?.toDouble();
    final lng = (result['lng'] as num?)?.toDouble();
    final address = result['address'] as String?;

    if (lat == null || lng == null) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'تعذّر قراءة موقع الاستلام، حاول مجددًا',
        type: SnackBarType.error,
      );
      return;
    }

    final branchId = await _resolveBranchId();
    if (branchId.isEmpty) {
      ShamraSnackBar.show(
        context: Get.context!,
        message: 'لم يتم تحديد الفرع. الرجاء اختيار الفرع أولاً.',
        type: SnackBarType.warning,
      );
      return;
    }

    final confirmed = await _showOrderConfirmationDialog(
      context,
      cartController,
      pointsData['points'] as int?,
      pointsData['discount'] as double?,
    );
    if (!confirmed) return;

    final orderController = Get.find<OrderController>();
    await orderController.placeOrderWithLocation(
      branchId: branchId,
      lat: lat,
      lng: lng,
      address: address,
      pointsToRedeem: pointsData['points'] as int?,
      // 🎯 إضافة
      currency: 'USD', // 🎯 يمكن جعلها dynamic
    );
  }

  // 🎯 Dialog جديد لاختيار النقاط
  Future<Map<String, dynamic>?> _showPointsDialog(
    BuildContext context,
    AuthController authController,
    CartController cartController,
  ) async {
    final user = authController.currentUser;
    if (user == null || user.points <= 0) {
      // لا توجد نقاط - متابعة مباشرة
      return {'points': null, 'discount': 0.0};
    }

    final pointsController = TextEditingController();
    final RxInt selectedPoints = 0.obs;
    final RxDouble discount = 0.0.obs;

    return await Get.dialog<Map<String, dynamic>?>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'استخدام نقاط المكافآت',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('نقاطك المتاحة:'),
                    Text(
                      '${user.points} نقطة',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد النقاط للاستخدام',
                  hintText: 'أدخل عدد النقاط',
                  prefixIcon: Icon(Icons.stars_rounded),
                ),
                onChanged: (value) {
                  final points = int.tryParse(value) ?? 0;
                  if (points > user.points) {
                    selectedPoints.value = user.points;
                    pointsController.text = user.points.toString();
                  } else {
                    selectedPoints.value = points;
                  }
                  // حساب الخصم (مثال: 1 نقطة = 0.1$)
                  discount.value = selectedPoints.value * 0.1;
                },
              ),
              const SizedBox(height: 12),
              Obx(
                () => discount.value > 0
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الخصم المتوقع:'),
                            Text(
                              '${discount.value.toStringAsFixed(2)} \$',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Get.back(result: {'points': null, 'discount': 0.0}),
            child: const Text('تخطي'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(
              result: {
                'points': selectedPoints.value > 0
                    ? selectedPoints.value
                    : null,
                'discount': discount.value,
              },
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  // 🎯 تحديث confirmation dialog
  Future<bool> _showOrderConfirmationDialog(
    BuildContext context,
    CartController cartController,
    int? pointsUsed,
    double? discount,
  ) async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.shopping_cart_checkout, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('تأكيد الطلب'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('هل أنت متأكد من إتمام هذا الطلب؟'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('عدد المنتجات:'),
                          Text('${cartController.itemCount} منتج'),
                        ],
                      ),
                      if (pointsUsed != null && pointsUsed > 0) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('النقاط المستخدمة:'),
                            Text('$pointsUsed نقطة'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الخصم:'),
                            Text(
                              '-${discount?.toStringAsFixed(2) ?? 0} \$',
                              style: const TextStyle(color: AppColors.success),
                            ),
                          ],
                        ),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المجموع النهائي:'),
                          Text(
                            '${(cartController.total - (discount ?? 0)).toStringAsFixed(0)} \$',
                            style: const TextStyle(
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
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('تأكيد الطلب'),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Determine branchId from Auth, storage, controller, or by asking user
  Future<String> _resolveBranchId() async {
    try {
      final auth = Get.find<AuthController>();
      final fromAuth = auth.currentUser?.selectedBranch ?? auth.savedBranchId;
      if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
    } catch (_) {}

    try {
      final fromStorage = StorageService.getBranchId();
      if (fromStorage != null && fromStorage.isNotEmpty) return fromStorage;
    } catch (_) {}

    try {
      final bc = Get.find<BranchController>();
      final fromCtrl = bc.selectedBranch?.id;
      if (fromCtrl != null && fromCtrl.isNotEmpty) return fromCtrl;
    } catch (_) {}

    final picked = await Get.toNamed(
      Routes.branchSelection,
      arguments: {'returnId': true},
    );
    if (picked is String && picked.isNotEmpty) {
      try {
        await StorageService.saveBranchId(picked);
      } catch (_) {}
      return picked;
    }
    if (picked is Map &&
        picked['branchId'] is String &&
        (picked['branchId'] as String).isNotEmpty) {
      final id = picked['branchId'] as String;
      try {
        await StorageService.saveBranchId(id);
      } catch (_) {}
      return id;
    }

    return '';
  }
}
