import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/core/services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/branch.dart';
import '../../../data/models/order.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common_widgets.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  OrderController get orderController => Get.find<OrderController>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic args = Get.arguments;
      if (args is String) {
        if (orderController.currentOrder?.id != args) {
          orderController.getOrderById(args);
        }
      } else if (args is Order) {
        if (orderController.currentOrder?.id != args.id) {
          orderController.setCurrentOrder(args);
        }
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final isLoading =
            orderController.isLoading && orderController.currentOrder == null;
        final error = orderController.errorMessage;
        final order = orderController.currentOrder;

        if (isLoading) {
          return Scaffold(
            appBar: _buildAppBar(null),
            body: const Center(
              child: LoadingWidget(message: 'جاري تحميل تفاصيل الطلب...'),
            ),
          );
        }

        if (error.isNotEmpty) {
          return Scaffold(
            appBar: _buildAppBar(null),
            body: Center(
              child: EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'خطأ في التحميل',
                message: error,
                action: ShamraButton(
                  text: 'إعادة المحاولة',
                  onPressed: () {
                    final args = Get.arguments;
                    if (args is String) {
                      orderController.getOrderById(args);
                    } else if (args is Order) {
                      orderController.setCurrentOrder(args);
                    }
                  },
                ),
              ),
            ),
          );
        }

        if (order == null) {
          return Scaffold(
            appBar: _buildAppBar(null),
            body: const Center(
              child: EmptyStateWidget(
                icon: Icons.search_off_outlined,
                title: 'طلب غير موجود',
                message: 'لم يتم العثور على تفاصيل لهذا الطلب.',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(order),
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () => orderController.getOrderById(order.id),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrderHeader(order),
                const SizedBox(height: 16),
                _buildOrderTimeline(order),
                const SizedBox(height: 16),
                _buildOrderItems(order),
                const SizedBox(height: 16),
                _buildOrderSummary(order),
                const SizedBox(height: 24),
                _buildActionButtons(order),
              ],
            ),
          ),
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(Order? order) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () {
          orderController.clearCurrentOrder();
          Get.back();
        },
      ),
      title: Text(
        order != null ? 'رقم الطلب  #${order.orderNumber}' : 'تفاصيل الطلب',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رقم الطلب  #${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.shopping_cart_outlined,
                  '${order.totalItems} منتج',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  order.isPaid
                      ? Icons.check_circle_outline
                      : Icons.pending_outlined,
                  order.isPaid ? 'مدفوع' : 'غير مدفوع',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.payments_outlined,
                  '${order.totalAmount.toStringAsFixed(0)}\$  ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final config = _getStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config['background'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config['text'],
        style: TextStyle(
          color: config['color'],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: ShamraCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مراحل الطلب',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimeline(order),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(Order order) {
    final stages = _getOrderStages(order.status);
    return Column(
      children: stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isLast = index == stages.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: stage['isActive']
                        ? stage['color']
                        : AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stage['icon'],
                    size: 14,
                    color: stage['isActive']
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 55,
                    color: stage['isActive']
                        ? stage['color']
                        : AppColors.lightGrey,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: stage['isActive']
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: stage['isActive']
                            ? AppColors.textSecondary
                            : AppColors.textLight,
                      ),
                    ),
                    if (stage['time'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        stage['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: stage['color'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getOrderStages(String currentStatus) {
    final stages = [
      {
        'title': 'تم الطلب',
        'description': 'تم استلام طلبكم بنجاح',
        'icon': Icons.shopping_cart_outlined,
        'color': AppColors.primary,
        'time': _formatDate(orderController.currentOrder!.createdAt),
      },
      {
        'title': 'تم التأكيد',
        'description': 'تم تأكيد الطلب وبدء التجهيز',
        'icon': Icons.check_circle_outline,
        'color': AppColors.primary,
        'time': null,
      },
      {
        'title': 'قيد التجهيز',
        'description': 'جاري تجهيز طلبكم',
        'icon': Icons.settings_outlined,
        'color': AppColors.primary,
        'time': null,
      },
      {
        'title': 'تم الشحن',
        'description': 'تم شحن الطلب وهو في طريقه إليكم',
        'icon': Icons.local_shipping_outlined,
        'color': AppColors.primary,
        'time': null,
      },
      {
        'title': 'تم التسليم',
        'description': 'تم تسليم الطلب بنجاح',
        'icon': Icons.check_circle,
        'color': AppColors.success,
        'time': null,
      },
    ];

    final order = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
    ];
    final idx = order.indexOf(currentStatus.toLowerCase());
    for (int i = 0; i < stages.length; i++) stages[i]['isActive'] = i <= idx;

    if (currentStatus.toLowerCase() == 'cancelled') {
      stages[0]['isActive'] = true;
      for (int i = 1; i < stages.length; i++) stages[i]['isActive'] = false;
      stages.add({
        'title': 'تم الإلغاء',
        'description': 'تم إلغاء الطلب',
        'icon': Icons.cancel_outlined,
        'color': AppColors.error,
        'isActive': true,
        'time': null,
      });
    }
    return stages;
  }

  Widget _buildOrderItems(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المنتجات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            final showDivider = idx < order.items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: () => Get.toNamed(
                    Routes.productDetails,
                    arguments: item.productId,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'الكمية: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.price.toStringAsFixed(2)} \$',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.total.toStringAsFixed(2)}\$',
                              style: const TextStyle(
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
                ),
                if (showDivider)
                  const Divider(height: 1, color: AppColors.lightGrey),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ملخص الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            'المجموع الفرعي:',
            '${order.subtotal.toStringAsFixed(2)} \$',
          ),
          if (order.discountAmount > 0)
            _summaryRow(
              'الخصم:',
              '-${order.discountAmount.toStringAsFixed(2)} \$',
              isDiscount: true,
            ),
          if (order.taxAmount > 0)
            _summaryRow('الضريبة:', '${order.taxAmount.toStringAsFixed(2)} \$'),
          const Divider(height: 20),
          _summaryRow(
            'المجموع النهائي:',
            '${order.totalAmount.toStringAsFixed(2)} \$',
            isTotal: true,
          ),
          const SizedBox(height: 12),
          _buildPaymentStatus(order),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value, {
        bool isTotal = false,
        bool isDiscount = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? AppColors.error
                  : isTotal
                  ? AppColors.primary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: order.isPaid
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            order.isPaid ? Icons.check_circle_outline : Icons.pending_outlined,
            color: order.isPaid ? AppColors.success : AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            order.isPaid ? 'مدفوع بالكامل' : 'في انتظار الدفع',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: order.isPaid ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    final canCancel = order.status.toLowerCase() == 'pending';

    return Column(
      children: [
        if (canCancel) ...[
          ShamraButton(
            text: 'إلغاء الطلب',
            icon: Icons.cancel_outlined,
            isOutlined: true,
            backgroundColor: AppColors.error,
            onPressed: () => _cancelOrder(order),
          ),
          const SizedBox(height: 12),
        ],
        ShamraButton(
          text: 'الاتصال بالدعم',
          icon: Icons.phone_outlined,
          isOutlined: true,
          onPressed: _showSupportDialog,
        ),
      ],
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

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }

  void _cancelOrder(Order order) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('تأكيد الإلغاء'),
        content: Text('هل تريد إلغاء طلب #${order.orderNumber}؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('تراجع')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await orderController.cancelOrder(order.id);
              if (success) Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    final phone =
        Branch.fromJson(
          StorageService.getUserData()?['selectedBranchObject'],
        ).phone ??
            "";

    print('Original phone number: $phone');

    ShamraBottomSheet.show(
      context: Get.context!,
      title: 'الدعم الفني',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (phone.isNotEmpty)
            ListTile(
              leading: const Icon(
                Icons.phone_outlined,
                color: AppColors.primary,
              ),
              title: const Text('الاتصال بالدعم'),
              subtitle: Text(phone),
              onTap: () {
                Get.back();
                _launchWhatsApp(phone);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    try {
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'https://wa.me/$cleanPhone',
        );
        await intent.launch();
      } else {
        // لـ iOS
        final Uri uri = Uri.parse('https://wa.me/$cleanPhone');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('خطأ', 'تعذر فتح WhatsApp');
    }
  }
}