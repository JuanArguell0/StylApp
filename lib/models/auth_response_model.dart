import 'user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? json['accessToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }

  // Constructores de fábrica para respuestas comunes
  factory AuthResponseModel.success({
    required String message,
    String? token,
    UserModel? user,
  }) {
    return AuthResponseModel(
      success: true,
      message: message,
      token: token,
      user: user,
    );
  }

  factory AuthResponseModel.error({required String message}) {
    return AuthResponseModel(success: false, message: message);
  }
}
