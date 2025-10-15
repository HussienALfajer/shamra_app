import 'package:shamra_app/data/models/user.dart';

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
    // ✅ يدعم شكلين:
    // أ) login/select-branch: { access_token, refresh_token, user:{...} }
    // ب) register:         { data:{ user:{...} } } (بدون توكنات)
    final token = (json['access_token'] ?? json['token'] ?? '').toString();
    final refreshToken = (json['refresh_token'] ?? '').toString();

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
