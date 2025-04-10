class Conversation {
  final String title;
  final String id;
  final int createdAt;

  Conversation({
    required this.title,
    required this.id,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      title: json['title'] ?? '',
      id: json['id'] ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'createdAt': createdAt,
    };
  }
}
