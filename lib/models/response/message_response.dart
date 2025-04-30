import 'package:jarvis/models/response/assistant_response.dart';

class Message {
  final String role;
  final String content;
  final List<String>? imagePaths;
  final Assistant assistant;
  final bool? isErrored;

  Message({
    required this.role,
    required this.content,
    this.imagePaths,
    required this.assistant,
    this.isErrored,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'assistant': assistant.toJson(),
        if (isErrored != null) 'isErrored': isErrored,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        role: json['role'],
        content: json['content'],
        assistant: Assistant.fromJson(json['assistant']),
        isErrored: json['isErrored'],
      );
}
