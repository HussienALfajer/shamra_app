import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../data/models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            'طلباتي',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            isScrollable: true,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'قيد التنفيذ'),
              Tab(text: 'مكتملة'),
              Tab(text: 'ملغية'),
            ],
          ),
        ),
        body: GetBuilder<OrderController>(
          init: OrderController(),
          builder: (orderController) => GetBuilder<AuthController>(
            builder: (authController) {
              if (!authController.isLoggedIn) {
                return _buildLoginRequired();
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildAllOrdersTab(orderController),
                  _buildActiveOrdersTab(orderController),
                  _buildCompletedOrdersTab(orderController),
                  _buildCancelledOrdersTab(orderController),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
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
                Icons.login_rounded,
                size: 60,
                color: AppColors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'تسجيل دخول مطلوب',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'يرجى تسجيل الدخول لعرض طلباتك',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ShamraButton(
              text: 'تسجيل دخول',
              onPressed: () => Get.toNamed('/login'),
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllOrdersTab(OrderController orderController) {
    return Obx(() {
      if (orderController.isLoading && orderController.orders.isEmpty) {
        return _buildOrdersShimmer();
      }

      if (orderController.orders.isEmpty) {
        return _buildEmptyOrders();
      }

      return _buildOrdersList(orderController.orders, orderController);
    });
  }

  Widget _buildActiveOrdersTab(OrderController orderController) {
    return Obx(() {
      final activeOrders = orderController.orders
          .where(
            (order) => [
              'pending',
              'confirmed',
              'processing',
              'shipped',
            ].contains(order.status.toLowerCase()),
          )
          .toList();

      if (orderController.isLoading && activeOrders.isEmpty) {
        return _buildOrdersShimmer();
      }

      if (activeOrders.isEmpty) {
        return _buildEmptyOrders(message: 'لا توجد طلبات قيد التنفيذ');
      }

      return _buildOrdersList(activeOrders, orderController);
    });
  }

  Widget _buildCompletedOrdersTab(OrderController orderController) {
    return Obx(() {
      final completedOrders = orderController.orders
          .where((order) => order.status.toLowerCase() == 'delivered')
          .toList();

      if (orderController.isLoading && completedOrders.isEmpty) {
        return _buildOrdersShimmer();
      }

      if (completedOrders.isEmpty) {
        return _buildEmptyOrders(message: 'لا توجد طلبات مكتملة');
      }

      return _buildOrdersList(completedOrders, orderController);
    });
  }

  Widget _buildCancelledOrdersTab(OrderController orderController) {
    return Obx(() {
      final cancelledOrders = orderController.orders
          .where((order) => order.status.toLowerCase() == 'cancelled')
          .toList();

      if (orderController.isLoading && cancelledOrders.isEmpty) {
        return _buildOrdersShimmer();
      }

      if (cancelledOrders.isEmpty) {
        return _buildEmptyOrders(message: 'لا توجد طلبات ملغية');
      }

      return _buildOrdersList(cancelledOrders, orderController);
    });
  }

  Widget _buildEmptyOrders({String? message}) {
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
                Icons.receipt_long_outlined,
                size: 60,
                color: AppColors.grey,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              message ?? 'لا توجد طلبات',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'ابدأ بتصفح المنتجات وإضافتها للسلة',
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

  Widget _buildOrdersList(List<Order> orders, OrderController orderController) {
    return RefreshIndicator(
      onRefresh: orderController.refreshOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, orderController);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, OrderController orderController) {
    return ShamraCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => Get.toNamed('/order-details', arguments: order),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب #${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusChip(order.status),
            ],
          ),

          const SizedBox(height: 12),

          // Order Info
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.shopping_cart_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${order.totalItems} منتج',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Order Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الكلي',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${order.totalAmount.toStringAsFixed(0)} ر.س',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Payment Status
          Row(
            children: [
              Icon(
                order.isPaid ? Icons.check_circle : Icons.pending,
                size: 16,
                color: order.isPaid ? AppColors.success : AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                order.isPaid ? 'مدفوع' : 'في انتظار الدفع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: order.isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: ShamraButton(
                  text: 'عرض التفاصيل',
                  onPressed: () =>
                      Get.toNamed('/order-details', arguments: order),
                  isOutlined: true,
                  height: 36,
                ),
              ),

              if (order.status.toLowerCase() == 'pending') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ShamraButton(
                    text: 'إلغاء الطلب',
                    onPressed: () =>
                        _showCancelOrderDialog(order, orderController),
                    height: 36,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        displayText = 'قيد الانتظار';
        break;
      case 'confirmed':
        backgroundColor = AppColors.info.withOpacity(0.2);
        textColor = AppColors.info;
        displayText = 'مؤكد';
        break;
      case 'processing':
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        displayText = 'قيد التحضير';
        break;
      case 'shipped':
        backgroundColor = AppColors.secondary.withOpacity(0.2);
        textColor = AppColors.secondary;
        displayText = 'تم الشحن';
        break;
      case 'delivered':
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        displayText = 'تم التسليم';
        break;
      case 'cancelled':
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        displayText = 'ملغي';
        break;
      default:
        backgroundColor = AppColors.grey.withOpacity(0.2);
        textColor = AppColors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildOrdersShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showCancelOrderDialog(Order order, OrderController orderController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'إلغاء الطلب',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل أنت متأكد من إلغاء الطلب #${order.orderNumber}؟',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'لا',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ShamraButton(
            text: 'نعم، إلغاء',
            onPressed: () {
              Get.back();
              // Handle order cancellation
              ShamraSnackBar.show(
                context: Get.context!,
                message: 'تم إلغاء الطلب بنجاح',
                type: SnackBarType.success,
              );
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }
}
