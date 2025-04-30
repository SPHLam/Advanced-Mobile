class MyAiBotMessage {
  final String role;
  final String content;
  final bool? isErrored;

  MyAiBotMessage({
    required this.role,
    required this.content,
    this.isErrored,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        if (isErrored != null) 'isErrored': isErrored,
      };

  factory MyAiBotMessage.fromJson(Map<String, dynamic> json) {
    final contentArray = json['content'] as List<dynamic>;
    final contentText = contentArray.isNotEmpty
        ? contentArray[0]['text']['value'] as String
        : '';

    return MyAiBotMessage(
      role: json['role'] as String,
      content: contentText,
      isErrored: json['isErrored'] as bool?,
    );
  }
}
