// API Constants
class ApiConstants {
  static const String baseUrl = 'http://192.168.74.21:3000/api/v1';
  static const String storageUrl = 'http://192.168.74.21:3000';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';
  static const String selectBranch = '/auth/select-branch';
  static const String products = '/products';
  static const String categories = '/categories';
  static const String subCategories = '/sub-categories';
  static const String branches = '/branches';
  static const String customers = '/customers';
  static const String orders = '/orders';
  // my orders
  static const String myOrders = '/orders/my';

  // Product specific
  static const String featuredProducts = '/products/featured';
  static const String onSaleProducts = '/products/on-sale';
  static const String productStats = '/products/stats';

  // Order specific
  static const String recentOrders = '/orders/recent';
  static const String orderStats = '/orders/stats';

  // Reports
  static const String dashboardSummary = '/reports/dashboard';
  static const String salesReport = '/reports/sales';
}

// App Constants
class AppConstants {
  static const String appName = 'Shamra Electronics';
  static const String appVersion = '1.0.0';
  static const String currency = 'SYP';

  // Storage Keys
  static const String tokenKey = 'jwt_token';
  static const String refreshTokenKey = 'jwt_refresh_token';
  static const String userKey = 'user_data';
  static const String branchIdKey = 'branch_id';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image placeholders
  static const String productPlaceholder =
      'assets/images/product_placeholder.png';
  static const String avatarPlaceholder =
      'assets/images/avatar_placeholder.png';
  static const String logoPath = 'assets/images/shamra_logo.png';
}
