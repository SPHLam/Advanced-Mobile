class EmailChatResponse {
  final String email;
  final int remainingUsage;

  EmailChatResponse({
    required this.email,
    required this.remainingUsage,
  });

  factory EmailChatResponse.fromJson(Map<String, dynamic> json) {
    return EmailChatResponse(
      email: json['email'],
      remainingUsage: json['remainingUsage'],
    );
  }
}
