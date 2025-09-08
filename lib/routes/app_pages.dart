import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/presentation/pages/auth/login_page.dart';
import 'package:shamra_app/presentation/pages/auth/register_page.dart';
import 'package:shamra_app/presentation/pages/home/home_page.dart';
import 'package:shamra_app/presentation/pages/main/main_page.dart';
import 'package:shamra_app/presentation/pages/splash/splash_page.dart';
import 'package:shamra_app/presentation/pages/branch/branch_selection_page.dart';
import 'app_routes.dart';
import '../core/bindings/initial_binding.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/main_controller.dart';
import '../presentation/controllers/product_controller.dart';
import '../presentation/controllers/cart_controller.dart';
import '../presentation/controllers/order_controller.dart';
import '../presentation/controllers/branch_controller.dart';

// Import pages (we'll create these next)
// import '../presentation/pages/splash/splash_page.dart';
// import '../presentation/pages/auth/login_page.dart';
// import '../presentation/pages/auth/register_page.dart';
// import '../presentation/pages/home/home_page.dart';
// import '../presentation/pages/products/product_list_page.dart';
// import '../presentation/pages/products/product_details_page.dart';
// import '../presentation/pages/cart/cart_page.dart';
// import '../presentation/pages/checkout/checkout_page.dart';
// import '../presentation/pages/orders/order_list_page.dart';
// import '../presentation/pages/orders/order_details_page.dart';
// import '../presentation/pages/profile/profile_page.dart';
// import '../presentation/pages/main/main_page.dart';

class AppPages {
  static const String initial = Routes.splash;

  static final routes = [
    // Splash & Onboarding
    GetPage(
      name: Routes.splash,
      page: () => SplashPage(),
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
    GetPage(name: Routes.home, page: () => HomePage(), binding: HomeBinding()),

    // Products
    GetPage(
      name: Routes.products,
      page: () => const Scaffold(
        body: Center(child: Text('Product List Page')),
      ), // ProductListPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.productDetails,
      page: () => const Scaffold(
        body: Center(child: Text('Product Details Page')),
      ), // ProductDetailsPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.productsByCategory,
      page: () => const Scaffold(
        body: Center(child: Text('Products By Category Page')),
      ), // ProductsByCategoryPage(),
      binding: ProductBinding(),
    ),

    // Search
    GetPage(
      name: Routes.search,
      page: () => const Scaffold(
        body: Center(child: Text('Search Page')),
      ), // SearchPage(),
      binding: ProductBinding(),
    ),

    // Categories
    GetPage(
      name: Routes.categories,
      page: () => const Scaffold(
        body: Center(child: Text('Categories Page')),
      ), // CategoriesPage(),
      binding: ProductBinding(),
    ),

    // Cart & Checkout
    GetPage(
      name: Routes.cart,
      page: () =>
          const Scaffold(body: Center(child: Text('Cart Page'))), // CartPage(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const Scaffold(
        body: Center(child: Text('Checkout Page')),
      ), // CheckoutPage(),
      binding: OrderBinding(),
    ),

    // Orders
    GetPage(
      name: Routes.orders,
      page: () => const Scaffold(
        body: Center(child: Text('Order List Page')),
      ), // OrderListPage(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => const Scaffold(
        body: Center(child: Text('Order Details Page')),
      ), // OrderDetailsPage(),
      binding: OrderBinding(),
    ),

    // Profile
    GetPage(
      name: Routes.profile,
      page: () => const Scaffold(
        body: Center(child: Text('Profile Page')),
      ), // ProfilePage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const Scaffold(
        body: Center(child: Text('Edit Profile Page')),
      ), // EditProfilePage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const Scaffold(
        body: Center(child: Text('Change Password Page')),
      ), // ChangePasswordPage(),
      binding: AuthBinding(),
    ),

    // Settings & Info
    GetPage(
      name: Routes.settings,
      page: () => const Scaffold(
        body: Center(child: Text('Settings Page')),
      ), // SettingsPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const Scaffold(
        body: Center(child: Text('About Page')),
      ), // AboutPage(),
    ),
    GetPage(
      name: Routes.contactUs,
      page: () => const Scaffold(
        body: Center(child: Text('Contact Us Page')),
      ), // ContactUsPage(),
    ),
  ];
}

// Binding Classes
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<CartController>(() => CartController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CartController>(() => CartController());
  }
}

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
  }
}

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
  }
}

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
  }
}

class BranchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BranchController>(() => BranchController());
  }
}
