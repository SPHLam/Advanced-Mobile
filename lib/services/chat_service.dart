import 'package:dio/dio.dart';
import 'package:project_ai_chat/models/response/api_response.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
import 'package:project_ai_chat/models/response/chat_response.dart';
import 'package:project_ai_chat/models/response/conversation_history_response.dart';
import 'package:project_ai_chat/models/response/message_response.dart';
import 'package:project_ai_chat/models/response/token_usage_response.dart';
import 'package:project_ai_chat/utils/dio/dio_jarvis.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  late final Dio dio;

  ChatService() {
    dio = DioJarvis().dio;
  }

  Future<ChatResponse> sendMessage({
    required String content,
    required String assistantId,
    String? conversationId,
    List<Message>? previousMessages,
  }) async {
    try {
      // Log request data
      final requestData = {
        "content": content,
        "metadata": {
          "conversation": {
            "id": conversationId ?? const Uuid().v4(),
            "messages": previousMessages?.map((msg) => msg.toJson()).toList() ?? [],
          }
        },
        "assistant": {
          "id": assistantId,
          "model": "dify",
        }
      };

      print('🚀 REQUEST DATA:');
      print('URL: ${dio.options.baseUrl}/api/v1/ai-chat/messages');
      print('Headers: ${dio.options.headers}');
      print('Body: $requestData');

      final response = await dio.post(
        '/ai-chat/messages',
        data: requestData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ChatResponse> sendImageMessages({
    required String content,
    required List<String> files,
    required String assistantId,
    String? conversationId,
    List<Message>? previousMessages,
  }) async {
    try {
      // Tải file lên Firebase Storage và lấy download URL
      final requestFiles = [];
      for(var file in files){
        requestFiles.add(file);
      }

      // Log request data
      final requestData = {
        "content": content,
        "files": requestFiles,
        "metadata": {
          "conversation": {
            "id": conversationId ?? const Uuid().v4(),
            "messages": previousMessages?.map((msg) => msg.toJson()).toList() ?? [],
          }
        },
        "assistant": {
          "id": assistantId,
          "model": "dify",
        }
      };

      print('🚀 REQUEST DATA:');
      print('URL: ${dio.options.baseUrl}/api/v1/ai-chat/messages');
      print('Headers: ${dio.options.headers}');
      print('Body: $requestData');

      final response = await dio.post(
        '/ai-chat/messages',
        data: requestData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ChatResponse> fetchAIChat({
    required String content,
    required String assistantId,
    List<String>? files,
  }) async {
    try {
      // Tải file lên Firebase Storage và lấy download URL
      final requestFiles = <String>[];
      if (files != null && files.isNotEmpty) {
        for(var file in files){
          requestFiles.add(file);
        }
      }

      final requestData = {
        "assistant": {"id": assistantId, "model": "dify"},
        "content": content,
        "files": requestFiles,
      };

      print('🚀 REQUEST DATA:');
      print('URL: ${dio.options.baseUrl}/api/v1/ai-chat');
      print('Headers: ${dio.options.headers}');
      print('Body: $requestData');

      final response = await dio.post(
        '/ai-chat',
        data: requestData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      return ChatResponse(
        conversationId: response.data['conversationId'],
        message: response.data['message'],
        remainingUsage: response.data['remainingUsage'],
      );
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> getAllConversations(
      String assistantId, String assistantModel, String? cursor) async {
    try {
      final response = await dio.get(
        '/ai-chat/conversations',
        queryParameters: {
          'cursor': cursor,
          'limit': 20,
          'assistantId': assistantId,
          'assistantModel': assistantModel,
        },
      );

      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Lấy thông tin user thành công',
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized, Please Login again';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Internal Server Error';
        }

        final errorData = e.response!.data;
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ConversationMessagesResponse> fetchConversationHistory({
    required String conversationId,
    required String assistantId,
  }) async {
    try {
      final queryParams = {
        'assistantId': assistantId,
        'assistantModel': 'dify',
      };

      print('🚀 REQUEST DATA:');
      print(
          'URL: ${dio.options.baseUrl}/api/v1/ai-chat/conversations/$conversationId/messages');
      print('Headers: ${dio.options.headers}');
      print('Query params: $queryParams');

      final response = await dio.get(
        '/ai-chat/conversations/$conversationId/messages',
        queryParameters: queryParams,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      return ConversationMessagesResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<TokenUsageResponse> fetchTokenUsage() async {
    try {
      final response = await dio.get(
        '/tokens/usage',
      );

      return TokenUsageResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> deleteConversationHistory({
    required String conversationId,
    required String assistantId,
  }) async {
    try {
      final queryParams = {
        'assistantId': assistantId,
        'assistantModel': 'dify',
      };

      print('🚀 REQUEST DATA:');
      print(
          'URL: ${dio.options.baseUrl}/api/v1/ai-chat/conversations/$conversationId');
      print('Headers: ${dio.options.headers}');
      print('Query params: $queryParams');

      final response = await dio.delete(
        '/ai-chat/conversations/$conversationId',
        queryParameters: queryParams,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ChatException(
          message: 'Failed to delete conversation',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<void> updateConversationTitle({
    required String conversationId,
    required String assistantId,
    required String title,
  }) async {
    try {
      final queryParams = {
        'assistantId': assistantId,
        'assistantModel': 'dify',
      };

      final requestData = {
        'name': title,
      };

      print('🚀 REQUEST DATA:');
      print(
          'URL: ${dio.options.baseUrl}/api/v1/ai-chat/conversations/$conversationId/name');
      print('Headers: ${dio.options.headers}');
      print('Query params: $queryParams');
      print('Body: $requestData');

      final response = await dio.post(
        '/ai-chat/conversations/$conversationId/name',
        queryParameters: queryParams,
        data: requestData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      if (response.statusCode != 200) {
        throw ChatException(
          message: 'Failed to update conversation name',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}