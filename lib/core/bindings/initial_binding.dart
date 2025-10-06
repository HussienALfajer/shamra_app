import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/app_controller.dart';
import 'package:shamra_app/presentation/controllers/banner_controller.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/favorite_controller.dart';
import '../../presentation/controllers/product_controller.dart';
import '../../presentation/controllers/cart_controller.dart';
import '../../presentation/controllers/category_controller.dart';
import '../../presentation/controllers/order_controller.dart';
import '../../presentation/pages/product/product_page.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put controllers that need to be available globally
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<SubCategoryController>(SubCategoryController(), permanent: true);
    Get.put<ProductController>(ProductController(), permanent: true);
    Get.put<CategoryController>(CategoryController(), permanent: true);
    Get.put<OrderController>(OrderController(), permanent: true);
    Get.put(FavoriteController(), permanent: true);
    Get.put<BannerController>(BannerController(),permanent: true);
    Get.put<AppController>(AppController(),permanent: true);
    Get.put(ProductsUIController());

  }
}
