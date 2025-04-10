import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jarvis/models/prompt_model.dart';
import 'package:jarvis/utils/dio/dio_jarvis.dart';
import 'package:jarvis/models/prompt_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PromptService {
  final dio = DioJarvis().dio;

  Future<PromptList> fetchAllPrompts() async {
    try {
      final Response response;
      response = await dio.get('/prompts');

      if (kDebugMode) {
        print('✅ RESPONSE DATA: ${response.data}');
      }

      return PromptList.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException:');
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Message: ${e.message}');
      }

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<PromptList> fetchPrompts(PromptRequest request) async {
    try {
      final requestData = request.toJson();

      if (kDebugMode) {
        print('🚀 REQUEST DATA: $requestData');
      }

      final Response response;
      if (request.category == 'all') {
        response = await dio.get(
            '/prompts?query=${request.query}&offset=${request.offset}&limit=${request.limit}&isFavorite=${request.isFavorite}&isPublic=${request.isPublic}');
      } else {
        response = await dio.get(
            '/prompts?query=${request.query}&offset=${request.offset}&limit=${request.limit}&category=${request.category}&isFavorite=${request.isFavorite}&isPublic=${request.isPublic}');
      }

      if (kDebugMode) {
        print('✅ RESPONSE DATA: ${response.data}');
      }

      return PromptList.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException:');
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Message: ${e.message}');
      }

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<bool> toggleFavorite(String promptId, bool isFavorite) async {
    try {
      final Response response;
      if (!isFavorite) {
        response = await dio.post('/prompts/$promptId/favorite');
      } else {
        response = await dio.delete('/prompts/$promptId/favorite');
      }

      if (kDebugMode) {
        print('✅ TOGGLE FAVORITE RESPONSE: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException khi toggle favorite:');
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Message: ${e.message}');
      }

      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Cannot change favorite status',
      );
    }
  }

  Future<bool> deletePrompt(String promptId) async {
    try {
      final response = await dio.delete('/prompts/$promptId');

      if (kDebugMode) {
        print('✅ DELETE PROMPT RESPONSE CODE: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException khi xóa prompt:');
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Message: ${e.message}');
      }

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Cannot delete prompt',
      );
    }
  }

  Future<bool> createPrompt(PromptRequest newPrompt) async {
    try {
      final requestData = newPrompt.toJson();

      if (kDebugMode) {
        print('🚀 REQUEST DATA: $requestData');
      }

      final response = await dio.post(
        '/prompts',
        data: requestData,
      );

      if (kDebugMode) {
        print('✅ CREATE PROMPT RESPONSE: ${response.data}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException:');
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Message: ${e.message}');
      }

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }

  Future<bool> updatePrompt(PromptRequest newPrompt, String promptId) async {
    try {
      final requestData = newPrompt.toJson();

      if (kDebugMode) {
        print('🚀 REQUEST DATA: $requestData');
      }

      final response = await dio.patch(
        '/prompts/$promptId',
        data: requestData,
      );

      if (kDebugMode) {
        print('✅ UPDATE PROMPT RESPONSE: ${response.data}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException:');
        print('Status: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Message: ${e.message}');
      }

      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối tới server',
      );
    }
  }
}
