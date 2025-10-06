import 'package:get/get.dart';
import 'package:shamra_app/core/services/storage_service.dart';

class FavoriteController extends GetxController {
  final _storage = StorageService.storage;
  final favorites = <String>{}.obs; // فقط ids

  static const key = 'favorite_ids';

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.read<List>(key) ?? [];
    favorites.addAll(saved.map((e) => e.toString()));
  }

  void toggleFavorite(String productId) {
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }
    _storage.write(key, favorites.toList());
  }

  bool isFavorite(String id) => favorites.contains(id);

  List<T> filterFavorites<T>(List<T> products, String Function(T) getId) {
    return products.where((p) => favorites.contains(getId(p))).toList();
  }
}
