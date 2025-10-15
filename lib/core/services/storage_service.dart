// lib/core/services/storage_service.dart
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

/// Lightweight wrapper over GetStorage for auth/session persistence.
class StorageService {
  static final GetStorage storage = GetStorage();

  static const String _branchAuthKey = 'branch_auth';

  // ========================== Token management ==========================
  static Future<void> saveToken(String token) async {
    await storage.write(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return storage.read<String>(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await storage.remove(AppConstants.tokenKey);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(AppConstants.refreshTokenKey, refreshToken);
  }

  static String? getRefreshToken() {
    return storage.read<String>(AppConstants.refreshTokenKey);
  }

  static Future<void> removeRefreshToken() async {
    await storage.remove(AppConstants.refreshTokenKey);
  }

  // ========================== Branch & user ==========================
  static Future<void> saveBranchId(String branchId) async {
    await storage.write(AppConstants.branchIdKey, branchId);
  }

  static String? getBranchId() {
    return storage.read<String>(AppConstants.branchIdKey);
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await storage.write(AppConstants.userKey, userData);
  }

  static Map<String, dynamic>? getUserData() {
    final data = storage.read(AppConstants.userKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  static Future<void> removeUserData() async {
    await storage.remove(AppConstants.userKey);
  }

  // ========================== App prefs ==========================
  static Future<void> saveLanguage(String languageCode) async {
    await storage.write(AppConstants.languageKey, languageCode);
  }

  static String getLanguage() {
    return storage.read<String>(AppConstants.languageKey) ?? 'en';
  }

  static Future<void> saveThemeMode(String themeMode) async {
    await storage.write(AppConstants.themeKey, themeMode);
  }

  static String getThemeMode() {
    return storage.read<String>(AppConstants.themeKey) ?? 'light';
  }

  // ========================== Branch auth map ==========================
  static Future<void> saveBranchAuth(
      String branchId, {
        required String token,
        String? refreshToken,
      }) async {
    final raw = storage.read(_branchAuthKey);
    final Map<String, dynamic> map =
    raw is Map ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};

    map[branchId] = {
      'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'savedAt': DateTime.now().toIso8601String(),
    };

    await storage.write(_branchAuthKey, map);
  }

  static Map<String, dynamic>? getBranchAuth(String branchId) {
    final raw = storage.read(_branchAuthKey);
    if (raw is! Map) return null;
    final rec = (raw as Map)[branchId];
    if (rec is Map) return Map<String, dynamic>.from(rec as Map);
    return null;
  }

  static Future<void> removeBranchAuth(String branchId) async {
    final raw = storage.read(_branchAuthKey);
    if (raw is! Map) return;
    final map = Map<String, dynamic>.from(raw as Map);
    map.remove(branchId);
    await storage.write(_branchAuthKey, map);
  }

  static Future<void> clearAllBranchAuth() async {
    await storage.remove(_branchAuthKey);
  }

  // ========================== Utils ==========================
  static Future<void> clearAll() async {
    await storage.erase();
  }

  static bool isLoggedIn() {
    return getToken() != null;
  }
}
