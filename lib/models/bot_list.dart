import 'package:project_ai_chat/models/bot.dart';

class BotList {
  final List<Bot> data;
  final int limit;
  final int total;
  final int offset;
  final bool hasNext;

  BotList.empty()
      : hasNext = false,
        data = [],
        limit = 0,
        offset = 0,
        total = -1;

  BotList({
    required this.data,
    required this.limit,
    required this.total,
    required this.offset,
    required this.hasNext,
  });

  factory BotList.fromJson(Map<String, dynamic> json) {
    return BotList(
      data: (json['data'] as List<dynamic>).map((e) => Bot.fromJson(e)).toList() ?? [],
      limit: json['meta']['limit'] ?? 0,
      total: json['meta']['total'] ?? 0,
      offset: json['meta']['offset'] ?? 0,
      hasNext: json['meta']['hasNext'] ?? false,
    );
  }
}
