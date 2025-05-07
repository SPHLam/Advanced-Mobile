import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:project_ai_chat/models/bot_request.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:project_ai_chat/utils/dio/dio_knowledge_base.dart';

import '../models/bot.dart';
import '../models/bot_list.dart';

class BotService {
  final dioKB = DioKnowledgeBase().dio;

  Future<BotList> fetchBots(
      {required int offset, required int limit, String? query}) async {
    try {
      print('🚀 REQUEST PARAM: offset=${offset}&limit=${limit}&q=${query}');

      final response;
      response = await dioKB
          .get('/ai-assistant?offset=${offset}&limit=${limit}&q=${query}');

      print('✅ RESPONSE BOTS DATA: ${response.data}');

      // Parse dữ liệu từ JSON thành PromptList
      return BotList.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<bool> deleteBot(String id) async {
    try {
      final response = await dioKB.delete('/ai-assistant/$id');

      print('✅ DELETE PROMPT RESPONSE CODE: ${response.statusCode}');

      return true;
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<bool> createBot(BotRequest newBot) async {
    try {
      final requestData = newBot.toJson();

      print('🚀 REQUEST DATA: $requestData');

      final response = await dioKB.post(
        '/ai-assistant',
        data: requestData,
      );

      print('✅ CREATE NEW BOT RESPONSE: ${response.data}');

      // String assistantId = Bot.fromJson(response.data).id;
      // return createThread(assistantId);
      return true;
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<bool> updateBot(BotRequest newBot, String id) async {
    try {
      final requestData = newBot.toJson();

      print('🚀 REQUEST DATA: $requestData');

      final response = await dioKB.patch(
        '/ai-assistant/$id',
        data: requestData,
      );

      print('✅ UPDATE BOT RESPONSE: ${response.data}');

      return true;
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  // Future<bool> createThread(String assistantId) async {
  //   try {
  //     // Chuẩn bị dữ liệu request
  //     final threadData = {"assistantId": assistantId, "firstMessage": ""};

  //     // Log request data
  //     print('🚀 REQUEST DATA: $threadData');

  //     // Gửi request POST để tạo thread mới
  //     final response = await dioKB.post(
  //       '/ai-assistant/thread',
  //       data: threadData,
  //     );

  //     // Log response
  //     print('✅ CREATE THREAD RESPONSE: ${response.data}');

  //     // Kiểm tra status code của response
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } on DioException catch (e) {
  //     // Log chi tiết lỗi
  //     print('❌ DioException:');
  //     print('Status: ${e.response?.statusCode}');
  //     print('Data: ${e.response?.data}');
  //     print('Message: ${e.message}');

  //     // Ném ra ngoại lệ với thông điệp phù hợp
  //     throw Exception(
  //       e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
  //     );
  //   }
  // }

  // Future<String> getThread(String assistantId) async {
  //   try {
  //     // Log request data
  //     //print('🚀 REQUEST DATA: $threadData');

  //     // Gửi request POST để tạo thread mới
  //     final response = await dioKB.get(
  //       '/ai-assistant/${assistantId}/threads',
  //     );

  //     // Log response
  //     print('✅ GET THREAD RESPONSE: ${response.data}');

  //     // Kiểm tra status code của response
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       final threads = response.data['data'] as List;

  //       // Kiểm tra danh sách threads
  //       if (threads.isNotEmpty) {
  //         // Lấy thread đầu tiên
  //         final thread = threads[0] as Map<String, dynamic>;

  //         // Lấy giá trị openAiThreadId
  //         final openAiThreadId = thread['openAiThreadId'] as String;
  //         //return openAiThreadId;
  //         return openAiThreadId;
  //       }
  //       return "";
  //     } else {
  //       return "";
  //     }
  //   } on DioException catch (e) {
  //     // Log chi tiết lỗi
  //     print('❌ DioException:');
  //     print('Status: ${e.response?.statusCode}');
  //     print('Data: ${e.response?.data}');
  //     print('Message: ${e.message}');

  //     // Ném ra ngoại lệ với thông điệp phù hợp
  //     throw Exception(
  //       e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
  //     );
  //   }
  // }

  Future<String> askAssistant(String assistantId, String message) async {
    try {
      final response = await dioKB.post(
        '/ai-assistant/$assistantId/ask',
        data: {"message": message},
      );

      String fullMessage = '';
      final lines = (response.data as String).split('\n');
      for (final line in lines) {
        if (line.startsWith('data:') && line.length > 5) {
          final jsonData = jsonDecode(line.substring(5).trim());
          fullMessage += jsonData['content']?.toString() ?? '';
        }
      }

      return fullMessage;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server');
    }
  }

  // Future<List<MyAiBotMessage>?> retrieveMessageOfThread(
  //     String openAiThreadId) async {
  //   try {
  //     final response = await dioKB.get(
  //       '/ai-assistant/thread/${openAiThreadId}/messages',
  //     );

  //     // Log response
  //     print('✅ RETRIEVE MESSAGE OF THREAD RESPONSE: ${response.data}');

  //     // Kiểm tra status code của response
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       //return response.data.map((json) => MyAiBotMessage.fromJson(json)).toList();
  //       return (response.data as List)
  //           .map((json) => MyAiBotMessage.fromJson(json))
  //           .toList();
  //     } else {
  //       return null;
  //     }
  //   } on DioException catch (e) {
  //     // Log chi tiết lỗi
  //     print('❌ DioException:');
  //     print('Status: ${e.response?.statusCode}');
  //     print('Data: ${e.response?.data}');
  //     print('Message: ${e.message}');

  //     // Ném ra ngoại lệ với thông điệp phù hợp
  //     throw Exception(
  //       e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
  //     );
  //   }
  // }

  // Future<Bot> updateAiBotWithThreadPlayGround(String assistantId) async {
  //   try {
  //     // Chuẩn bị dữ liệu request
  //     final threadData = {"assistantId": assistantId, "firstMessage": ""};

  //     // Log request data
  //     print('🚀 REQUEST DATA: $threadData');

  //     // Gửi request POST để tạo thread mới
  //     final response = await dioKB.post(
  //       '/ai-assistant/thread/playground',
  //       data: threadData,
  //     );

  //     // Log response
  //     print('✅ UPDATE BOT WITH THREAD PLAY GROUND RESPONSE: ${response.data}');

  //     // Kiểm tra status code của response
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       return Bot.fromJson(response.data);
  //     } else {
  //       return Bot.empty();
  //     }
  //   } on DioException catch (e) {
  //     // Log chi tiết lỗi
  //     print('❌ DioException:');
  //     print('Status: ${e.response?.statusCode}');
  //     print('Data: ${e.response?.data}');
  //     print('Message: ${e.message}');

  //     // Ném ra ngoại lệ với thông điệp phù hợp
  //     throw Exception(
  //       e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
  //     );
  //   }
  // }

  Future<bool> importKnowledgeToAiBot(
      String assistantId, String knowledgeId) async {
    try {
      // Log request
      print('🚀 REQUEST');

      // Gửi request POST để tạo thread mới
      final response = await dioKB.post(
        '/ai-assistant/${assistantId}/knowledges/${knowledgeId}',
      );

      // Log response
      print('✅ IMPORT KNOWLEDGE TO AIBOT RESPONSE: ${response.data}');

      return true;
    } on DioException catch (e) {
      // Log chi tiết lỗi
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      // Ném ra ngoại lệ với thông điệp phù hợp
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<bool> removeKnowledgeFromAiBot(
      String assistantId, String knowledgeId) async {
    try {
      // Log request
      print('🚀 REQUEST');

      // Gửi request POST để tạo thread mới
      final response = await dioKB.delete(
        '/ai-assistant/${assistantId}/knowledges/${knowledgeId}',
      );

      // Log response
      print('✅ REMOVE KNOWLEDGE FROM AI BOT RESPONSE: ${response.data}');

      return true;
    } on DioException catch (e) {
      // Log chi tiết lỗi
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      // Ném ra ngoại lệ với thông điệp phù hợp
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<List<Knowledge>> getImportedKnowledge(String assistantId) async {
    try {
      // Log request
      print('🚀 REQUEST');

      // Gửi request POST để tạo thread mới
      final response = await dioKB.get(
        '/ai-assistant/${assistantId}/knowledges',
      );

      // Log response
      print('✅ GET IMPORTED KNOWLEDGE IN AIBOT RESPONSE: ${response.data}');

      List<Knowledge> knowledgeList = [];
      knowledgeList.addAll(
        (response.data['data'] as List<dynamic>)
            .map((item) => Knowledge.fromJson(item)),
      );

      return knowledgeList;
    } on DioException catch (e) {
      // Log chi tiết lỗi
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      // Ném ra ngoại lệ với thông điệp phù hợp
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }
}
