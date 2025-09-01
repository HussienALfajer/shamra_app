import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class StorageService {
  static final storage = GetStorage();

  // Token management
  static Future<void> saveToken(String token) async {
    await storage.write(AppConstants.tokenKey, token);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(AppConstants.refreshTokenKey, refreshToken);
  }

  static String? getToken() {
    return storage.read<String>(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await storage.remove(AppConstants.tokenKey);
  }

  // User data management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await storage.write(AppConstants.userKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    return storage.read<Map<String, dynamic>>(AppConstants.userKey);
  }

  static Future<void> removeUserData() async {
    await storage.remove(AppConstants.userKey);
  }

  // Language management
  static Future<void> saveLanguage(String languageCode) async {
    await storage.write(AppConstants.languageKey, languageCode);
  }

  static String getLanguage() {
    return storage.read<String>(AppConstants.languageKey) ?? 'en';
  }

  // Theme management
  static Future<void> saveThemeMode(String themeMode) async {
    await storage.write(AppConstants.themeKey, themeMode);
  }

  static String getThemeMode() {
    return storage.read<String>(AppConstants.themeKey) ?? 'light';
  }

  // Clear all data
  static Future<void> clearAll() async {
    await storage.erase();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null;
  }
}
