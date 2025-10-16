// lib/data/models/auth_res.dart
import 'package:shamra_app/data/models/user.dart';

/// Wrapper for authentication API responses.
/// Standard shape: { success, message, data: AuthResponse }
class AuthResponseApi {
  final bool success;
  final String message;
  final AuthResponse data;

  AuthResponseApi({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AuthResponseApi.fromJson(Map<String, dynamic> json) {
    final success = json['success'] == true;
    final message = (json['message'] ?? '').toString();
    final dataMap = Map<String, dynamic>.from(json['data'] ?? {});
    return AuthResponseApi(
      success: success,
      message: message,
      data: AuthResponse.fromJson(dataMap),
    );
  }
}

/// Inner authentication response containing tokens and user data.
/// Supports multiple API shapes:
/// - Login/select-branch: { access_token, refresh_token, user:{...} }
/// - Register: { data:{ user:{...} } } (may not include tokens immediately)
class AuthResponse {
  final String token;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Extract tokens (support both naming conventions)
    final token = (json['access_token'] ?? json['token'] ?? '').toString();
    final refreshToken = (json['refresh_token'] ?? '').toString();

    // Extract user object (handle nested data structure)
    Map<String, dynamic> userMap = {};
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user']);
    } else if (json['data'] is Map && (json['data']['user'] is Map)) {
      userMap = Map<String, dynamic>.from(json['data']['user']);
    }

    return AuthResponse(
      token: token,
      refreshToken: refreshToken,
      user: User.fromJson(userMap),
    );
  }
}