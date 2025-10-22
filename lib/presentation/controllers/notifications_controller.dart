import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../data/models/order_notification.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  final repo = NotificationRepository();
  final RxList<OrderNotification> items = <OrderNotification>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _ensureStorageReady();
    load();
  }

  void _ensureStorageReady() {
    // تأكد من تهيئة GetStorage بمشروعك (عادة في main). اتركه فارغاً لو جاهز.
  }

  void load() {
    isLoading.value = true;
    items.assignAll(repo.load());
    isLoading.value = false;
  }

  Future<void> addFromFCM({
    required String id,
    required String title,
    required String body,
    required String orderId,
    DateTime? createdAt,
  }) async {
    await repo.add(OrderNotification(
      id: id,
      title: title,
      body: body,
      orderId: orderId,
      createdAt: createdAt ?? DateTime.now(),
    ));
    load();
  }

  Future<void> markRead(String id) async {
    await repo.markRead(id);
    load();
  }

  Future<void> remove(String id) async {
    await repo.remove(id);
    load();
  }

  Future<void> clear() async {
    await repo.clear();
    load();
  }

  void openNotification(OrderNotification n) {
    markRead(n.id);
    Get.toNamed(Routes.orderDetails, arguments: n.orderId);
  }
}