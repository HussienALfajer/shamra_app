import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/presentation/controllers/banner_controller.dart';
import 'package:shamra_app/presentation/pages/auth/login_page.dart';
import 'package:shamra_app/presentation/pages/auth/register_page.dart';
import 'package:shamra_app/presentation/pages/google_map/select_location_page.dart';
import 'package:shamra_app/presentation/pages/main/main_page.dart';
import 'package:shamra_app/presentation/pages/notifications/notifications_page.dart';
import 'package:shamra_app/presentation/pages/order/order_details.dart';
import 'package:shamra_app/presentation/pages/order/order_page.dart';
import 'package:shamra_app/presentation/pages/splash/welcome_page.dart';
import 'package:shamra_app/presentation/pages/branch/branch_selection_page.dart';
import '../presentation/pages/auth/forgot_password_page.dart';
import '../presentation/pages/auth/otp_page.dart';
import '../presentation/pages/auth/reset_password_page.dart';
import '../presentation/pages/category/categories_page.dart';
import '../presentation/pages/category/category_details_page.dart';
import '../presentation/pages/favorite/favorites_page.dart';
import '../presentation/pages/product/product_page.dart';
import '../presentation/pages/product/product_details_page.dart';
import '../presentation/pages/profile/edit_profile_page.dart';
import '../presentation/pages/splash/splash.dart';
import 'app_routes.dart';
import '../core/bindings/initial_binding.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/main_controller.dart';
import '../presentation/controllers/product_controller.dart';
import '../presentation/controllers/cart_controller.dart';
import '../presentation/controllers/order_controller.dart';
import '../presentation/controllers/branch_controller.dart';
import '../presentation/controllers/category_controller.dart';
import '../presentation/controllers/sub_category_controller.dart';
import '../presentation/controllers/favorite_controller.dart';
import '../presentation/controllers/app_controller.dart';

class AppPages {
  static const String initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.notifications, page: () => const NotificationsPage()),
    GetPage(name: Routes.otp, page: () => const OtpPage()),

    GetPage(
      name: Routes.selectLocation,
      page: () => const SelectLocationPage(),
      transition: Transition.cupertino, // أبقِ نفس أسلوبك المعتاد
    ),

    GetPage(name: Routes.editProfile, page: () => const EditProfilePage()),
    // Splash & Onboarding
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomePage(),
      binding: InitialBinding(),
    ),

    // Authentication
    GetPage(
      name: Routes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),

    // Branch Selection
    GetPage(
      name: Routes.branchSelection,
      page: () => const BranchSelectionPage(),
      binding: BranchBinding(),
    ),

    // Main Navigation
    GetPage(
      name: Routes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),

    // Favorites
    GetPage(
      name: Routes.favorites,
      page: () => const FavoritesPage(),
      binding: FavoriteBinding(),
    ),

    // Category Details
    GetPage(
      name: Routes.categoryDetails,
      page: () => CategoryDetailsPage(),
      binding: ProductBinding(),
    ),

    // Products
    GetPage(
      name: Routes.products,
      page: () => const ProductsPage(),
      binding: ProductBinding(),
    ),

    GetPage(
      name: Routes.featuredProducts,
      page: () => const ProductsPage(),
      binding: ProductBinding(),
      arguments: {'initialTab': 1},
    ),

    GetPage(
      name: Routes.saleProducts,
      page: () => const ProductsPage(),
      binding: ProductBinding(),
      arguments: {'initialTab': 2},
    ),

    GetPage(
      name: Routes.productsByCategory,
      page: () => const Scaffold(
        body: Center(child: Text('Products By Category Page')),
      ),
      binding: ProductBinding(),
    ),

    // Search

    // Categories
    GetPage(
      name: Routes.categories,
      page: () => const CategoriesPage(),
      binding: CategoryBinding(),
    ),

    // Cart & Checkout
    GetPage(
      name: Routes.cart,
      page: () => const Scaffold(body: Center(child: Text('Cart Page'))),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const Scaffold(body: Center(child: Text('Checkout Page'))),
      binding: OrderBinding(),
    ),

    // Orders
    GetPage(
      name: Routes.orders,
      page: () => const OrdersPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => OrderDetailsPage(),
      binding: OrderBinding(),
    ),

    // Profile
    GetPage(
      name: Routes.profile,
      page: () => const Scaffold(body: Center(child: Text('Profile Page'))),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.changePassword,
      page: () =>
      const Scaffold(body: Center(child: Text('Change Password Page'))),
      binding: AuthBinding(),
    ),

    // Settings & Info
    GetPage(
      name: Routes.settings,
      page: () => const Scaffold(body: Center(child: Text('Settings Page'))),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const Scaffold(body: Center(child: Text('About Page'))),
    ),
    GetPage(
      name: Routes.contactUs,
      page: () => const Scaffold(body: Center(child: Text('Contact Us Page'))),
    ),

    // Product Details
    GetPage(
      name: Routes.productDetails,
      page: () => const ProductDetailsPage(),
      binding: ProductBinding(),
    ),

    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgotPasswordPage(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordPage(),
    ),
  ];
}

// ============== BINDING CLASSES ==============

/// Initial Binding - يتم تحميله عند بداية التطبيق
// class AppStartBinding extends Bindings {
//   @override
//   void dependencies() {
//     // AppController - يبقى في الذاكرة طوال عمر التطبيق
//     Get.put<AppController>(AppController(), permanent: true);
//
//     // FavoriteController - يبقى في الذاكرة لحفظ المفضلة
//     Get.put<FavoriteController>(FavoriteController(), permanent: true);
//   }
// }

/// Auth Binding - لصفحات المصادقة
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<BranchController>(() => BranchController());

  }
}

/// Main Binding - للصفحة الرئيسية
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
    Get.put<FavoriteController>(FavoriteController(), permanent: true);
  }
}

/// Home Binding - لصفحة البيت
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}

/// Product Binding - لصفحات المنتجات
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductsUIController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<SubCategoryController>(() => SubCategoryController());
  }
}

/// Category Binding - لصفحات الفئات
class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<SubCategoryController>(() => SubCategoryController());
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

/// Cart Binding - لصفحات السلة
class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

/// Order Binding - لصفحات الطلبات
class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

/// Branch Binding - لصفحة اختيار الفروع
class BranchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchController>(() => BranchController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

/// Favorite Binding - لصفحة المفضلة
class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    // FavoriteController already permanent في InitialBinding
  }
}

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
