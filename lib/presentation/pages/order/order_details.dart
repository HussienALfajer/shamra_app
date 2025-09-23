import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../core/constants/colors.dart';
import '../../../data/models/order.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common_widgets.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.find<OrderController>();
    final dynamic args = Get.arguments;

    // Check if an Order object was passed directly
    Order? order = args is Order ? args : null;

    // If not, try to get orderId from arguments and fetch the order
    if (order == null && args is String) {
      // Assuming args is orderId
      orderController.getOrderById(args);
    } else if (order != null) {
      orderController.setCurrentOrder(order);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'تفاصيل الطلب',
          showBackButton: true,
          actions: [
            if (orderController.currentOrder != null &&
                orderController.currentOrder!.status.toLowerCase() == 'pending')
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                onPressed: () {
                  // TODO: Implement cancel order logic
                  ShamraSnackBar.show(
                    context: Get.context!,
                    message: 'وظيفة إلغاء الطلب غير متاحة حاليًا.',
                    type: SnackBarType.info,
                  );
                },
              ),
          ],
        ),
        body: Obx(() {
          if (orderController.isLoading && orderController.currentOrder == null) {
            return const Center(child: LoadingWidget(message: 'جاري تحميل تفاصيل الطلب...'));
          }

          if (orderController.errorMessage.isNotEmpty) {
            return Center(
              child: EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'خطأ',
                message: orderController.errorMessage,
                action: ShamraButton(
                  text: 'إعادة المحاولة',
                  onPressed: () {
                    if (args is String) {
                      orderController.getOrderById(args);
                    } else {
                      Get.back(); // Go back if no ID to retry with
                    }
                  },
                ),
              ),
            );
          }

          final currentOrder = orderController.currentOrder;

          if (currentOrder == null) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.info_outline,
                title: 'لا يوجد طلب',
                message: 'لم يتم العثور على تفاصيل لهذا الطلب.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderController.getOrderById(currentOrder.id),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildOrderSummaryCard(currentOrder),
                const SizedBox(height: 16),
                _buildOrderItemsCard(currentOrder.items),
                const SizedBox(height: 16),
                _buildPaymentSummaryCard(currentOrder),
                const SizedBox(height: 16),
                _buildNotesSection(currentOrder.notes),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderSummaryCard(Order order) {
    return ShamraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('رقم الطلب:', '#${order.orderNumber}', Icons.receipt_long),
          _buildDetailRow('الحالة:', _buildStatusChip(order.status), Icons.info_outline),
          _buildDetailRow('تاريخ الطلب:', DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt), Icons.calendar_today_outlined),
          _buildDetailRow('الفرع:', order.branchId, Icons.store_outlined), // Assuming branchId is a displayable name or can be fetched
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(List<OrderItem> items) {
    return ShamraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المنتجات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.lightGrey),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  '${item.quantity} x ${item.price.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.total.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(Order order) {
    return ShamraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.lightGrey),
          _buildSummaryRow('المجموع الفرعي:', '${order.subtotal.toStringAsFixed(2)} ر.س'),
          _buildSummaryRow('الخصم:', '-${order.discountAmount.toStringAsFixed(2)} ر.س', isDiscount: true),
          _buildSummaryRow('الضريبة:', '${order.taxAmount.toStringAsFixed(2)} ر.س'),
          const Divider(height: 24, thickness: 1, color: AppColors.lightGrey),
          _buildSummaryRow('المجموع الكلي:', '${order.totalAmount.toStringAsFixed(2)} ر.س', isTotal: true),
          _buildDetailRow('حالة الدفع:', order.isPaid ? 'مدفوع' : 'معلق', order.isPaid ? Icons.check_circle : Icons.pending, color: order.isPaid ? AppColors.success : AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String? notes) {
    if (notes == null || notes.isEmpty) {
      return const SizedBox.shrink();
    }
    return ShamraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملاحظات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.lightGrey),
          Text(
            notes,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const Spacer(),
          if (value is String)
            Text(
              value,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary),
            )
          else if (value is Widget)
            value,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isDiscount ? AppColors.error : (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg, txt;
    String text;

    switch (status.toLowerCase()) {
      case "pending":
        bg = AppColors.warning.withOpacity(0.15);
        txt = AppColors.warning;
        text = "قيد الانتظار";
        break;
      case "confirmed":
        bg = AppColors.info.withOpacity(0.15);
        txt = AppColors.info;
        text = "تم التأكيد";
        break;
      case "processing":
        bg = AppColors.info.withOpacity(0.15);
        txt = AppColors.info;
        text = "قيد التجهيز";
        break;
      case "shipped":
        bg = AppColors.primary.withOpacity(0.15);
        txt = AppColors.primary;
        text = "تم الشحن";
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
}


