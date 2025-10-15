// lib/routes/app_routes.dart

/// Centralized route names used across the app.
/// Keep routes stable to avoid breaking navigation.
class Routes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';

  // Branch & Location
  static const String branchSelection = '/branch-selection';
  static const String selectLocation = '/select-location';

  // Main & Home
  static const String main = '/main';
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Products & Categories
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String productsByCategory = '/products-by-category';
  static const String featuredProducts = '/products/featured';
  static const String saleProducts = '/products/sale';
  static const String search = '/search';
  static const String categories = '/categories';
  static const String categoryDetails = '/category-details';
  static const String favorites = '/favorites';

  // Cart & Orders
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';

  // Profile & Settings
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String settings = '/settings';

  // Misc
  static const String notifications = '/notifications';
  static const String about = '/about';
  static const String contactUs = '/contact-us';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
}
