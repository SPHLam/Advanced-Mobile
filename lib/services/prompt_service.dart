import 'package:dio/dio.dart';
import 'package:project_ai_chat/models/prompt_model.dart';
import 'package:project_ai_chat/utils/dio/dio_jarvis.dart';
import 'package:project_ai_chat/models/prompt_list.dart';

class PromptService {

  final dio = DioJarvis().dio;

  Future<PromptList> fetchAllPrompts() async {
    try {
      final response;
      response = await dio.get('/prompts');

      print('✅ RESPONSE DATA: ${response.data}');

      return PromptList.fromJson(response.data);
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

  Future<PromptList> fetchPrompts(PromptRequest request) async {
    try {
      final requestData = request.toJson();

      print('🚀 REQUEST DATA: $requestData');

      final response;
      if (request.category == 'all') {
        response = await dio.get(
            '/prompts?query=${request.query}&offset=${request.offset}&limit=${request.limit}&isFavorite=${request.isFavorite}&isPublic=${request.isPublic}');
      } else {
        response = await dio.get(
            '/prompts?query=${request.query}&offset=${request.offset}&limit=${request.limit}&category=${request.category}&isFavorite=${request.isFavorite}&isPublic=${request.isPublic}');
      }

      print('✅ RESPONSE DATA: ${response.data}');

      // Parse dữ liệu từ JSON thành PromptList
      return PromptList.fromJson(response.data);
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

  Future<bool> toggleFavorite(String promptId, bool isFavorite) async {
    try {
      final response;
      if (!isFavorite) {
        response = await dio.post('/prompts/$promptId/favorite');
      } else {
        response = await dio.delete('/prompts/$promptId/favorite');
      }

      print('✅ TOGGLE FAVORITE RESPONSE: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      print('❌ DioException khi toggle favorite:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Không thể thay đổi trạng thái yêu thích',
      );
    }
  }

  Future<bool> deletePrompt(String promptId) async {
    try {
      final response = await dio.delete('/prompts/$promptId');

      print('✅ DELETE PROMPT RESPONSE CODE: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('❌ DioException khi xóa prompt:');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('Message: ${e.message}');

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Không thể xóa prompt',
      );
    }
  }

  Future<bool> createPrompt(PromptRequest newPrompt) async {
    try {
      final requestData = newPrompt.toJson();

      print('🚀 REQUEST DATA: $requestData');

      final response = await dio.post(
        '/prompts',
        data: requestData,
      );

      print('✅ CREATE PROMPT RESPONSE: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
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

  Future<bool> updatePrompt(PromptRequest newPrompt, String promptId) async {
    try {
      final requestData = newPrompt.toJson();

      print('🚀 REQUEST DATA: $requestData');

      final response = await dio.patch(
        '/prompts/$promptId',
        data: requestData,
      );

      print('✅ UPDATE PROMPT RESPONSE: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
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
}
