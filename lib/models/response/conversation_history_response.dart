class ConversationMessagesResponse {
  final String cursor;
  final bool hasMore;
  final int limit;
  final List<ConversationMessage> items;

  ConversationMessagesResponse({
    required this.cursor,
    required this.hasMore,
    required this.limit,
    required this.items,
  });

  factory ConversationMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ConversationMessagesResponse(
      cursor: json['cursor'] ?? '',
      hasMore: json['has_more'],
      limit: json['limit'] ?? 100,
      items: (json['items'] as List)
          .map((item) => ConversationMessage.fromJson(item))
          .toList(),
    );
  }
}

class ConversationMessage {
  final String answer;
  final String createdAt;
  final List<String>? files;
  final String query;

  ConversationMessage({
    required this.answer,
    required this.createdAt,
    this.files,
    required this.query,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      answer: json['answer'],
      createdAt: json['createdAt'],
      files: json['files'] != null ? List<String>.from(json['files']) : null,
      query: json['query'],
    );
  }
}