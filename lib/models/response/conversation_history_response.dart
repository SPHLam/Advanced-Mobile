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
      cursor: json['cursor'],
      hasMore: json['has_more'],
      limit: json['limit'],
      items: (json['items'] as List)
          .map((item) => ConversationMessage.fromJson(item))
          .toList(),
    );
  }
}

class ConversationMessage {
  final String answer;
  final int createdAt;
  final List<String> files;
  final String query;

  ConversationMessage({
    required this.answer,
    required this.createdAt,
    required this.files,
    required this.query,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      answer: json['answer'],
      createdAt: json['createdAt'],
      files: List<String>.from(json['files']),
      query: json['query'],
    );
  }
}
