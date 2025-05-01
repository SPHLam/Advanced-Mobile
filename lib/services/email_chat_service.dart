import 'package:dio/dio.dart';
import 'package:jarvis/utils/dio/dio_jarvis.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:jarvis/models/response/email_chat_response.dart';

class EmailChatService {
  late final Dio dio;
  EmailChatService() {
    dio = DioJarvis().dio;
  }
  Future<List<String>> suggestEmailIdeas({
    required String action,
    required String email,
    required String subject,
    required String sender,
    required String receiver,
    required String language,
  }) async {
    try {
      final requestData = {
        "action": action,
        "email": email,
        "metadata": {
          "context": [],
          "subject": subject,
          "sender": sender,
          "receiver": receiver,
          "language": language,
        }
      };

      print('🚀 REQUEST DATA: $requestData');

      final response = await dio.post(
        '/ai-email/reply-ideas',
        data: requestData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['ideas']);
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

  Future<EmailChatResponse> responseEmail({
    required String mainIdea,
    required String action,
    required String email,
    required String subject,
    required String sender,
    required String receiver,
    required String language,
  }) async {
    try {
      final requestData = {
        "mainIdea": mainIdea,
        "action": action,
        "email": email,
        "metadata": {
          "context": [],
          "subject": subject,
          "sender": sender,
          "receiver": receiver,
          "style": {
            "length": "long",
            "formality": "neutral",
            "tone": "friendly",
          },
          "language": language,
        }
      };

      print('🚀 REQUEST DATA: $requestData');

      final response = await dio.post(
        '/ai-email',
        data: requestData,
      );

      print('✅ RESPONSE DATA: ${response.data}');

      if (response.statusCode == 200) {
        return EmailChatResponse.fromJson(response.data);
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
}
