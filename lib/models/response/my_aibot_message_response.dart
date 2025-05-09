class MyAiBotMessage {
  final String role;
  final String content;
  final List<String>? files;
  final bool? isErrored;

  MyAiBotMessage({
    required this.role,
    required this.content,
    this.files,
    this.isErrored,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'files': files,
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
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      isErrored: json['isErrored'] as bool?,
    );
  }
}
