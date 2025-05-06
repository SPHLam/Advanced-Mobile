import 'package:project_ai_chat/models/prompt.dart';

// Model cho PromptList
class PromptList {
  final bool hasNext;
  List<Prompt> items;
  final int limit;
  final int offset;
  int total;

  // Constructor rỗng
  PromptList.empty()
      : hasNext = false,
        items = [],
        limit = 0,
        offset = 0,
        total = -1;

  PromptList({
    required this.hasNext,
    required this.items,
    required this.limit,
    required this.offset,
    required this.total,
  });

  // Tạo từ JSON
  factory PromptList.fromJson(Map<String, dynamic> json) {
    return PromptList(
      hasNext: json['hasNext'] ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => Prompt.fromJson(item))
              .toList() ??
          [],
      limit: json['limit'] ?? 0,
      offset: json['offset'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  // Convert về JSON
  Map<String, dynamic> toJson() {
    return {
      'hasNext': hasNext,
      'items': items.map((item) => item.toJson()).toList(),
      'limit': limit,
      'offset': offset,
      'total': total,
    };
  }
}
