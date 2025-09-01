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
    return AuthResponseApi(
      success: json['success'],
      message: json['message'],
      data: AuthResponse.fromJson(json['data']),
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
    return AuthResponse(
      token: json['access_token'],
      refreshToken: json['refresh_token'],
      user: User.fromJson(json['user']),
    );
  }
}
