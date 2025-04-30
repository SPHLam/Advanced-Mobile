class Conversation {
  final String title;
  final String id;
  final String createdAt;

  Conversation({
    required this.title,
    required this.id,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      title: json['title'] ?? '',
      id: json['id'] ?? '',
      createdAt: json['createdAt'] ?? '',
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