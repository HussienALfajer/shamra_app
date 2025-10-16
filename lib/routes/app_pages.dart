// lib/routes/app_pages.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Pages
import 'package:shamra_app/presentation/pages/auth/login_page.dart';
import 'package:shamra_app/presentation/pages/auth/register_page.dart';
import 'package:shamra_app/presentation/pages/google_map/select_location_page.dart';
import 'package:shamra_app/presentation/pages/main/main_page.dart';
import 'package:shamra_app/presentation/pages/notifications/notifications_page.dart';
import 'package:shamra_app/presentation/pages/order/order_details.dart';
import 'package:shamra_app/presentation/pages/order/order_page.dart';
import 'package:shamra_app/presentation/pages/splash/welcome_page.dart';
import 'package:shamra_app/presentation/pages/branch/branch_selection_page.dart';
import 'package:shamra_app/presentation/pages/auth/forgot_password_page.dart';
import 'package:shamra_app/presentation/pages/auth/otp_page.dart';
import 'package:shamra_app/presentation/pages/auth/reset_password_page.dart';
import 'package:shamra_app/presentation/pages/category/categories_page.dart';
import 'package:shamra_app/presentation/pages/category/category_details_page.dart';
import 'package:shamra_app/presentation/pages/favorite/favorites_page.dart';
import 'package:shamra_app/presentation/pages/product/product_page.dart';
import 'package:shamra_app/presentation/pages/product/product_details_page.dart';
import 'package:shamra_app/presentation/pages/profile/edit_profile_page.dart';
import 'package:shamra_app/presentation/pages/splash/splash.dart';

// Routes
import 'app_routes.dart';

// Dedicated bindings (from core/bindings/)
import 'package:shamra_app/core/bindings/initial_binding.dart';
import 'package:shamra_app/core/bindings/auth_binding.dart';
import 'package:shamra_app/core/bindings/category_binding.dart';
import 'package:shamra_app/core/bindings/cart_binding.dart';
import 'package:shamra_app/core/bindings/order_binding.dart';
import 'package:shamra_app/core/bindings/product_binding.dart';

// Controllers for local bindings (will be migrated to dedicated binding files in later waves)
import 'package:shamra_app/presentation/controllers/app_controller.dart';
import 'package:shamra_app/presentation/controllers/banner_controller.dart';
import 'package:shamra_app/presentation/controllers/sub_category_controller.dart';
import 'package:shamra_app/presentation/controllers/auth_controller.dart';
import 'package:shamra_app/presentation/controllers/branch_controller.dart';
import 'package:shamra_app/presentation/controllers/favorite_controller.dart';
import 'package:shamra_app/presentation/controllers/main_controller.dart';
import 'package:shamra_app/presentation/controllers/product_controller.dart';
import 'package:shamra_app/presentation/controllers/cart_controller.dart';
import 'package:shamra_app/presentation/controllers/category_controller.dart';
import 'package:shamra_app/presentation/controllers/order_controller.dart';

class AppPages {
  static const String initial = Routes.splash;

  static final routes = [
    // Notifications
    GetPage(name: Routes.notifications, page: () => const NotificationsPage()),

    // Auth support pages
    GetPage(
      name: Routes.otp,
      page: () => const OtpPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgotPasswordPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: AuthBinding(),
    ),

    // Location
    GetPage(
      name: Routes.selectLocation,
      page: () => const SelectLocationPage(),
      transition: Transition.cupertino,
      binding: LocationBinding(),
    ),

    // Profile
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfilePage(),
      binding: AuthBinding(),
    ),

    // Splash & Welcome
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

    // Main
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
    // Product Details
    GetPage(
      name: Routes.productDetails,
      page: () => const ProductDetailsPage(),
      binding: ProductBinding(),
    ),

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

    // Profile & Settings
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
    GetPage(
      name: Routes.settings,
      page: () => const Scaffold(body: Center(child: Text('Settings Page'))),
      binding: InitialBinding(),
    ),

    // Miscellaneous
    GetPage(
      name: Routes.about,
      page: () => const Scaffold(body: Center(child: Text('About Page'))),
    ),
    GetPage(
      name: Routes.contactUs,
      page: () => const Scaffold(body: Center(child: Text('Contact Us Page'))),
    ),
  ];
}

// ===== Local bindings (temporary, will be split in later waves) =====

/// Local binding for authentication-related pages.
/// TODO: Migrate to dedicated file if additional logic is needed.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}

/// Local binding for main navigation page.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
  }
}

/// Local binding for branch selection page.
class BranchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchController>(() => BranchController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}

/// Local binding for favorites page.
class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<FavoriteController>(() => FavoriteController(), fenix: true);
  }
}

/// Local binding for location selection page.
class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
