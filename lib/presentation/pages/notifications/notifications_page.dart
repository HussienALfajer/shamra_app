import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NotificationsController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إشعارات الطلبات'),
          actions: [
            IconButton(
              tooltip: 'حذف الكل',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                if (c.items.isEmpty) return;
                Get.defaultDialog(
                  title: 'تأكيد',
                  middleText: 'هل تريد حذف جميع الإشعارات؟',
                  textCancel: 'إلغاء',
                  textConfirm: 'حذف',
                  confirmTextColor: Colors.white,
                  onConfirm: () { c.clear(); Get.back(); },
                );
              },
            ),
          ],
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.items.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات حتى الآن'));
          }
          return ListView.separated(
            itemCount: c.items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final n = c.items[i];
              return Dismissible(
                key: ValueKey(n.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => c.remove(n.id),
                child: ListTile(
                  leading: Icon(
                    n.isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: n.isRead ? AppColors.grey : AppColors.primary,
                  ),
                  title: Text(
                    n.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _ago(n.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () => c.openNotification(n),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'الآن';
    if (d.inMinutes < 60) return '${d.inMinutes} د';
    if (d.inHours < 24) return '${d.inHours} س';
    return '${d.inDays} يوم';
  }
}