// Model cho một Prompt
class Prompt {
  final String id;
  final String category;
  final String content;
  final String createdAt;
  final String description;
  bool isFavorite;
  final bool isPublic;
  final String language;
  final String title;
  final String updatedAt;
  final String userId;
  final String userName;

  Prompt({
    required this.id,
    required this.category,
    required this.content,
    required this.createdAt,
    required this.description,
    required this.isFavorite,
    required this.isPublic,
    required this.language,
    required this.title,
    required this.updatedAt,
    required this.userId,
    required this.userName,
  });

  // Tạo từ JSON
  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      description: json['description'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      isPublic: json['isPublic'] ?? false,
      language: json['language'] ?? '',
      title: json['title'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
    );
  }

  // Convert về JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'content': content,
      'createdAt': createdAt,
      'description': description,
      'isFavorite': isFavorite,
      'isPublic': isPublic,
      'language': language,
      'title': title,
      'updatedAt': updatedAt,
      'userId': userId,
      'userName': userName,
    };
  }
}