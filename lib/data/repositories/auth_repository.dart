import 'package:shamra_app/data/models/auth_res.dart';
import '../../core/services/notification_service.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {
  // Login user
  Future<AuthResponseApi> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      // Save token if login successful
      if (response.data.token != null) {
        await StorageService.saveToken(response.data.token);
      }
      if (response.data.refreshToken != null) {
        await StorageService.saveRefreshToken(response.data.refreshToken);
      }

      // Save user data if available
      if (response.data.user != null) {
        await StorageService.saveUserData(response.data.user.toJson());
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseApi> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      // 👇 get FCM token
      final fcmToken = await NotificationService.getToken();

      final response = await AuthService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        fcmToken: fcmToken, // أرسله للـ backend
      );

      print('Response user: ${response.data.user.toJson()}');

      if (response.data.token != null) {
        await StorageService.saveToken(response.data.token);
      }
      if (response.data.refreshToken != null) {
        await StorageService.saveRefreshToken(response.data.refreshToken);
      }
      if (response.data.user != null) {
        await StorageService.saveUserData(response.data.user.toJson());
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }


  // select branch return new access_token and refresh_token
  Future<AuthResponseApi> selectBranch({required String branchId}) async {
    try {
      final response = await AuthService.selectBranch(branchId: branchId);

      // حفظ التوكن النشط الحالي
      if (response.data.token != null) {
        await StorageService.saveToken(response.data.token);
      }
      if (response.data.refreshToken != null) {
        await StorageService.saveRefreshToken(response.data.refreshToken);
      }

      // حفظ بيانات المستخدم
      if (response.data.user != null) {
        await StorageService.saveUserData(response.data.user.toJson());
      }

      // حفظ الفرع
      await StorageService.saveBranchId(branchId);

      if (response.data.token != null) {
        await StorageService.saveBranchAuth(
          branchId,
          token: response.data.token!,
          refreshToken: response.data.refreshToken,
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<User> getProfile() async {
    try {
      final user = await AuthService.getProfile();
      print("THIS IS FROM PROFILE ENDPOINT ${user.toJson()}");
      await StorageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Update profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    try {
      final user = await AuthService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      await StorageService.saveUserData(user.toJson());
      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await AuthService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMerchantRequest({
    required String storeName,
    required String address,
    required String phoneNumber,
  }) async {
    try {
      await AuthService.addMerchantRequest(
        address: address,
        phoneNumber: phoneNumber,
        storeName: storeName,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getMyMerchantRequest() async {
    try {
      return await AuthService.getMyMerchantRequest();
    } catch (e) {
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await StorageService.clearAll();
    }
  }

  bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }

  User? getCurrentUser() {
    final userData = StorageService.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  String? getToken() {
    return StorageService.getToken();
  }
}
