import 'package:dio/dio.dart';
import 'package:jarvis/models/response/api_response.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:jarvis/models/response/chat_response.dart';
import 'package:jarvis/models/response/conversation_history_response.dart';
import 'package:jarvis/models/response/message_response.dart';
import 'package:jarvis/models/response/token_usage_response.dart';
import 'package:jarvis/utils/dio/dio_jarvis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final SharedPreferences prefs;
  late final Dio dio;

  ChatService({required this.prefs}) {
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
            "messages":
                previousMessages?.map((msg) => msg.toJson()).toList() ?? [],
          }
        },
        "assistant": {
          "id": assistantId,
          "model": "dify",
          "name": "Claude 3 Haiku"
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
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ChatResponse> sendImageMessages({
    required String content,
    required List<String> imagePaths,
    required String assistantId,
    String? conversationId,
    List<Message>? previousMessages,
  }) async {
    try {
      // Tạo FormData để gửi hình ảnh và nội dung
      final formData = FormData();

      // Thêm nội dung vào formData
      formData.fields.add(MapEntry('content', content));
      formData.fields.add(MapEntry('assistantId', assistantId));
      formData.fields
          .add(MapEntry('conversation', conversationId ?? const Uuid().v4()));

      // Thêm metadata cho previousMessages
      formData.fields.add(MapEntry(
          'messages',
          previousMessages?.map((msg) => msg.toJson()).toList().toString() ??
              ''));

      // Thêm hình ảnh vào formData
      for (var path in imagePaths) {
        formData.files
            .add(MapEntry('files', await MultipartFile.fromFile(path)));
      }

      // Thêm metadata cho assistant
      formData.fields.add(MapEntry('assistant',
          '{"id": "$assistantId", "model": "dify", "name": "Claude 3 Haiku"}'));

      // final requestData = {
      //   "content": content,
      //   "metadata": {
      //     "conversation": {
      //       "id": conversationId ?? const Uuid().v4(),
      //       "messages":
      //           previousMessages?.map((msg) => msg.toJson()).toList() ?? [],
      //     }
      //   },
      //   "assistant": {
      //     "id": assistantId,
      //     "model": "dify",
      //     "name": "Claude 3 Haiku"
      //   },
      //   "files": [] // Khởi tạo mảng files
      // };

      // // Thêm hình ảnh vào mảng files
      // for (var path in imagePaths) {
      //   (requestData['files'] as List)
      //       .add(path); // Thêm đường dẫn hình ảnh vào mảng
      // }
      print('🚀 REQUEST DATA: $formData');

      final response = await dio.post(
        '/ai-chat/messages',
        data: formData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ChatResponse> fetchAIChat({
    required String content,
    required String assistantId,
  }) async {
    try {
      final requestData = {
        "assistant": {"id": assistantId, "model": "dify"},
        "content": content
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

      if (response.statusCode == 200) {
        return ChatResponse(
          conversationId: response.data['conversationId'],
          message: response.data['message'],
          remainingUsage: response.data['remainingUsage'],
        );
      } else {
        throw ChatException(
          message: 'Lỗi không xác định từ server',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw ChatException(
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
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
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Lấy thông tin user thành công',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Lấy thông tin user thất bại',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      String errorMessage = '';
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          errorMessage = 'Unauthorized, Please Login again';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Internal Server Error';
        }

        final errorData = e.response!.data;
        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
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
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<TokenUsageResponse> fetchTokenUsage() async {
    try {
      final response = await dio.get(
        '/tokens/usage',
      );

      if (response.statusCode == 200) {
        return TokenUsageResponse.fromJson(response.data);
      } else {
        throw ChatException(
          message: 'Lỗi không xác định từ server',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ChatException(
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
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
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
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
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
