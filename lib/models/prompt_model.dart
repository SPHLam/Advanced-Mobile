class PromptRequest {
  final String? category;
  final bool? isFavorite;
  final bool? isPublic;
  final int? limit;
  final int? offset;
  final String? query;
  final String? language;
  final String? title;
  final String? content;
  final String? description;

  PromptRequest({
    this.category,
    this.isFavorite,
    this.isPublic,
    this.limit,
    this.offset,
    this.query,
    this.language,
    this.title,
    this.content,
    this.description,
  });

  PromptRequest copyWith({
    String? category, // Thay đổi từ String? thành Category?
    bool? isFavorite,
    bool? isPublic,
    int? limit,
    int? offset,
    String? query,
    String? language,
    String? title,
    String? content,
    String? description,
  }) {
    return PromptRequest(
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPublic: isPublic ?? this.isPublic,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      query: query ?? this.query,
      language: language ?? this.language,
      title: title ?? this.title,
      content: content ?? this.content,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (category != null) 'category': category, // Chuyển Category sang String
      if (isFavorite != null) 'isFavorite': isFavorite,
      if (isPublic != null) 'isPublic': isPublic,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
      if (query != null) 'query': query,
      if (language != null) 'language': language,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (description != null) 'description': description,
    };
  }
}
