// lib/presentation/controllers/favorite_controller.dart
// Favorites controller - store product IDs in local storage.
// EN comments only.

import 'package:get/get.dart';
import 'package:shamra_app/core/services/storage_service.dart';

class FavoriteController extends GetxController {
  final _storage = StorageService.storage;
  final RxSet<String> favorites = <String>{}.obs;

  static const key = 'favorite_ids';

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.read<List>(key) ?? [];
    favorites.addAll(saved.map((e) => e.toString()));
  }

  /// Toggle favorite state and persist
  void toggleFavorite(String productId) {
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }
    _storage.write(key, favorites.toList());
  }

  /// Check if product is favorite
  bool isFavorite(String id) => favorites.contains(id);

  /// Filter a list of items by favorite ids.
  /// `getId` extracts id from generic T.
  List<T> filterFavorites<T>(List<T> products, String Function(T) getId) {
    return products.where((p) => favorites.contains(getId(p))).toList();
  }
}
