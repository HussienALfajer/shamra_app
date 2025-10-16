// lib/core/bindings/repository_binding.dart
import 'package:get/get.dart';
import 'package:shamra_app/data/repositories/auth_repository.dart';
import 'package:shamra_app/data/repositories/banner_repository.dart';
import 'package:shamra_app/data/repositories/branch_repository.dart';
import 'package:shamra_app/data/repositories/cart_repository.dart';
import 'package:shamra_app/data/repositories/category_repository.dart';
import 'package:shamra_app/data/repositories/order_repository.dart';
import 'package:shamra_app/data/repositories/product_repository.dart';
import 'package:shamra_app/data/repositories/sub_category_repository.dart';
import 'package:shamra_app/data/repositories/notification_repository.dart';

/// Binding for all repository dependencies.
/// Repositories handle data layer operations (API calls, caching, etc.).
class RepositoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.lazyPut<BannerRepository>(() => BannerRepository(), fenix: true);
    Get.lazyPut<BranchRepository>(() => BranchRepository(), fenix: true);
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<SubCategoryRepository>(
          () => SubCategoryRepository(),
      fenix: true,
    );
    Get.lazyPut<NotificationRepository>(
          () => NotificationRepository(),
      fenix: true,
    );
  }
}