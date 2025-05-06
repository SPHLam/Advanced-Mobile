import 'package:project_ai_chat/models/user_model.dart';

class SignInResponse {
  final String token;
  final User user;

  SignInResponse({
    required this.token,
    required this.user,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
