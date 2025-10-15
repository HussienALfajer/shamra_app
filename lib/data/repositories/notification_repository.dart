import 'package:get_storage/get_storage.dart';
import '../models/order_notification.dart';

class NotificationRepository {
  static const _boxKey = 'order_notifications';
  final GetStorage _box = GetStorage();

  List<OrderNotification> load() {
    final raw = _box.read<List>(_boxKey) ?? [];
    return raw.map((e) => OrderNotification.fromMap(Map<String, dynamic>.from(e))).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAll(List<OrderNotification> list) async {
    await _box.write(_boxKey, list.map((e) => e.toMap()).toList());
  }

  Future<void> add(OrderNotification n) async {
    final list = load();
    // امنع التكرار بنفس id
    if (list.indexWhere((e) => e.id == n.id) == -1) {
      list.insert(0, n);
      await saveAll(list);
    }
  }

  Future<void> markRead(String id) async {
    final list = load().map((e) => e.id == id ? e.copyWith(isRead: true) : e).toList();
    await saveAll(list);
  }

  Future<void> remove(String id) async {
    final list = load()..removeWhere((e) => e.id == id);
    await saveAll(list);
  }

  Future<void> clear() async => _box.remove(_boxKey);
}