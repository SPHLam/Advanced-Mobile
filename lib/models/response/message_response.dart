import 'package:project_ai_chat/models/response/assistant_response.dart';

class Message {
  final String role;
  final String content;
  final List<String>? files;
  final Assistant assistant;
  final bool? isErrored;

  Message({
    required this.role,
    required this.content,
    this.files,
    required this.assistant,
    this.isErrored,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'files': files,
        'assistant': assistant.toJson(),
        if (isErrored != null) 'isErrored': isErrored,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        role: json['role'],
        content: json['content'],
        files: json['files'] != null ? List<String>.from(json['files']) : null,
        assistant: Assistant.fromJson(json['assistant']),
        isErrored: json['isErrored'],
      );
}
