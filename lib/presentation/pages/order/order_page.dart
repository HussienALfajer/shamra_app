import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/order.dart';

/// 📌 صفحة عرض جميع الطلبات (الكل، قيد التنفيذ، مكتملة، ملغية)
/// - تعتمد على [OrderController] لعرض الطلبات.
/// - تستخدم [AuthController] للتحقق من تسجيل الدخول.
/// - منظمة باستخدام [TabBar] مع 4 تبويبات.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();
    final authController = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CustomAppBar(title: "طلباتي"),
          body: Obx(() {
            if (!authController.isLoggedIn) {
              return _buildLoginRequired(context);
            }

            return Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildOrdersList(
                        orders: orderController.orders,
                        isLoading: orderController.isLoading,
                        emptyMessage: "لا توجد طلبات",
                      ),
                      _buildOrdersList(
                        orders: orderController.activeOrders,
                        isLoading: orderController.isLoading,
                        emptyMessage: "لا توجد طلبات قيد التنفيذ",
                      ),
                      _buildOrdersList(
                        orders: orderController.completedOrders,
                        isLoading: orderController.isLoading,
                        emptyMessage: "لا توجد طلبات مكتملة",
                      ),
                      _buildOrdersList(
                        orders: orderController.cancelledOrders,
                        isLoading: orderController.isLoading,
                        emptyMessage: "لا توجد طلبات ملغية",
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// ✅ تبويب الفئات (الكل - قيد التنفيذ - مكتملة - ملغية)
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TabBar(
        indicator: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: [
          Tab(text: 'الكل'),
          Tab(text: 'قيد التنفيذ'),
          Tab(text: 'مكتملة'),
          Tab(text: 'ملغية'),
        ],
      ),
    );
  }

  /// ✅ قائمة الطلبات
  Widget _buildOrdersList({
    required List<Order> orders,
    required bool isLoading,
    required String emptyMessage,
  }) {
    if (isLoading && orders.isEmpty) {
      return const LoadingWidget(message: "جاري تحميل الطلبات...");
    }

    if (orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: emptyMessage,
        message: "ابدأ التسوق الآن",
        action: ShamraButton(
          text: "تسوق الآن",
          icon: Icons.shopping_bag_outlined,
          onPressed: () =>  Get.offAllNamed(Routes.main),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: Get.find<OrderController>().refreshOrders,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }

  /// ✅ كرت عرض تفاصيل الطلب
  Widget _buildOrderCard(Order order) {
    return ShamraCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      onTap: () => Get.toNamed('/order-details', arguments: order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 العنوان والتاريخ + الحالة
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("طلب #${order.orderNumber}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        )),
                    Text(
                      order.createdAt.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 تفاصيل: عدد المنتجات + حالة الدفع + المجموع
          Row(
            children: [
              Expanded(
                child: _buildOrderDetail(
                  Icons.shopping_cart,
                  "${order.totalItems}",
                  "منتج",
                ),
              ),
              Expanded(
                child: _buildOrderDetail(
                  order.isPaid ? Icons.check_circle : Icons.pending,
                  order.isPaid ? "مدفوع" : "معلق",
                  "الدفع",
                  color: order.isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildOrderDetail(
                  Icons.attach_money,
                  "${order.totalAmount.toStringAsFixed(0)}",
                  "ر.س",
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 الأزرار (عرض التفاصيل - إلغاء إذا كان Pending)
          Row(
            children: [
              Expanded(
                child: ShamraButton(
                  text: "عرض التفاصيل",
                  isOutlined: true,
                  onPressed: () =>
                      Get.toNamed('/order-details', arguments: order),
                ),
              ),
              if (order.status.toLowerCase() == "pending") ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ShamraButton(
                    text: "إلغاء الطلب",
                    backgroundColor: AppColors.error,
                    onPressed: () => ShamraSnackBar.show(
                      context: Get.context!,
                      message: "تم إلغاء الطلب بنجاح",
                      type: SnackBarType.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ عنصر تفاصيل داخل الكرت (أيقونة + قيمة + وسم)
  Widget _buildOrderDetail(IconData icon, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.textSecondary, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            )),
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }

  /// ✅ Chip لحالة الطلب
  Widget _buildStatusChip(String status) {
    Color bg, txt;
    String text;

    switch (status.toLowerCase()) {
      case "pending":
        bg = AppColors.warning.withOpacity(0.15);
        txt = AppColors.warning;
        text = "قيد الانتظار";
        break;
      case "delivered":
        bg = AppColors.success.withOpacity(0.15);
        txt = AppColors.success;
        text = "تم التسليم";
        break;
      case "cancelled":
        bg = AppColors.error.withOpacity(0.15);
        txt = AppColors.error;
        text = "ملغي";
        break;
      default:
        bg = AppColors.grey.withOpacity(0.15);
        txt = AppColors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(color: txt, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  /// ✅ واجهة تسجيل الدخول مطلوبة
  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.login,
        title: "تسجيل دخول مطلوب",
        message: "يرجى تسجيل الدخول لعرض طلباتك",
        action: ShamraButton(
          text: "تسجيل دخول",
          icon: Icons.login,
          onPressed: () => Get.toNamed('/login'),
        ),
      ),
    );
  }
}
