import 'package:project_ai_chat/models/bot_request.dart';

class Bot {
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String updatedBy;
  final String id;
  final String assistantName;
  final String openAiAssistantId;
  final String instructions;
  final String description;
  final String openAiThreadIdPlay;
  final String openAiVectorStoreId;

  Bot({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.id,
    required this.assistantName,
    required this.openAiAssistantId,
    required this.instructions,
    required this.description,
    required this.openAiThreadIdPlay,
    required this.openAiVectorStoreId,
  });

  factory Bot.empty() {
    return Bot(
      createdAt: '',
      updatedAt: '',
      createdBy: '',
      updatedBy: '',
      id: '',
      assistantName: '',
      openAiAssistantId: '',
      instructions: '',
      description: '',
      openAiThreadIdPlay: '',
      openAiVectorStoreId: '',
    );
  }

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
      id: json['id'] ?? '',
      assistantName: json['assistantName'] ?? '',
      openAiAssistantId: json['openAiAssistantId'] ?? '',
      instructions: json['instructions'] ?? '',
      description: json['description'] ?? '',
      openAiThreadIdPlay: json['openAiThreadIdPlay'] ?? '',
      openAiVectorStoreId: json['openAiVectorStoreId'] ?? '',
    );
  }
}

extension BotToRequest on Bot {
  BotRequest toBotRequest() {
    return BotRequest(
      assistantName: assistantName,
      instructions: instructions,
      description: description,
    );
  }
}
