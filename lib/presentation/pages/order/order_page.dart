import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/order.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final main = Get.find<MainController>();
    final orderController = Get.find<OrderController>();
    final authController = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 4,
        child: Builder(
          builder: (ctx) {
            final tabController = DefaultTabController.of(ctx);
            return WillPopScope(
              onWillPop: () async {
                if (tabController.index > 0) {
                  tabController.animateTo(tabController.index - 1);
                  return false;
                }
                return !main.backToPreviousTab();
              },
              child: Scaffold(
                backgroundColor: AppColors.background,
                appBar: _buildAppBar(),
                body: Obx(() {
                  if (!authController.isLoggedIn) return _buildLoginRequired();
                  return _buildOrdersContent(orderController, main);
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: const Text(
        "طلباتي",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return const TabBar(
      indicatorColor: AppColors.primary,
      indicatorWeight: 2,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      tabs: [
        Tab(text: 'الكل'),
        Tab(text: 'نشطة'),
        Tab(text: 'مكتملة'),
        Tab(text: 'ملغية'),
      ],
    );
  }

  Widget _buildOrdersContent(OrderController oc, MainController main) {
    return TabBarView(
      children: [
        _buildOrdersList(
          scrollController: main.ordersScrollController,
          orders: oc.orders,
          isLoading: oc.isLoading,
          emptyMessage: "لا توجد طلبات",
        ),
        _buildOrdersList(
          scrollController: main.ordersScrollController,
          orders: oc.activeOrders,
          isLoading: oc.isLoading,
          emptyMessage: "لا توجد طلبات نشطة",
        ),
        _buildOrdersList(
          scrollController: main.ordersScrollController,
          orders: oc.completedOrders,
          isLoading: oc.isLoading,
          emptyMessage: "لا توجد طلبات مكتملة",
        ),
        _buildOrdersList(
          scrollController: main.ordersScrollController,
          orders: oc.cancelledOrders,
          isLoading: oc.isLoading,
          emptyMessage: "لا توجد طلبات ملغية",
        ),
      ],
    );
  }

  Widget _buildOrdersList({
    required ScrollController scrollController,
    required List<Order> orders,
    required bool isLoading,
    required String emptyMessage,
  }) {
    if (isLoading && orders.isEmpty) {
      return const Center(
        child: LoadingWidget(message: "جاري تحميل الطلبات..."),
      );
    }

    if (orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: emptyMessage,
        message: "ابدأ التسوق الآن",
      );
    }

    // ترتيب الطلبات من الأحدث إلى الأقدم
    final sortedOrders = List<Order>.from(orders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RefreshIndicator(
      onRefresh: Get.find<OrderController>().refreshOrders,
      color: AppColors.primary,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: sortedOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildMinimalOrderCard(sortedOrders[index]),
      ),
    );
  }

  Widget _buildMinimalOrderCard(Order order) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.orderDetails, arguments: order.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#${order.orderNumber}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(order.createdAt),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${order.totalItems} منتج",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  "${order.totalAmount.toStringAsFixed(2)}\$",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config['background'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config['text'],
        style: TextStyle(
          color: config['color'],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return {
          'background': AppColors.warning.withOpacity(0.1),
          'color': AppColors.warning,
          'text': "قيد الانتظار",
        };
      case "confirmed":
      case "processing":
        return {
          'background': AppColors.info.withOpacity(0.1),
          'color': AppColors.info,
          'text': "قيد التجهيز",
        };
      case "shipped":
        return {
          'background': AppColors.primary.withOpacity(0.1),
          'color': AppColors.primary,
          'text': "تم الشحن",
        };
      case "delivered":
        return {
          'background': AppColors.success.withOpacity(0.1),
          'color': AppColors.success,
          'text': "تم التسليم",
        };
      case "cancelled":
        return {
          'background': AppColors.error.withOpacity(0.1),
          'color': AppColors.error,
          'text': "ملغي",
        };
      default:
        return {
          'background': AppColors.grey.withOpacity(0.1),
          'color': AppColors.grey,
          'text': status,
        };
    }
  }

  Widget _buildLoginRequired() {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.login_outlined,
        title: "تسجيل دخول مطلوب",
        message: "يرجى تسجيل الدخول لعرض طلباتك",
        action: ShamraButton(
          text: "تسجيل دخول",
          icon: Icons.login,
          onPressed: () => Get.toNamed(Routes.login),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }
}