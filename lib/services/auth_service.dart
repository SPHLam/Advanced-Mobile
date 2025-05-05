import 'dart:developer';
import 'package:jarvis/models/response/subscription_response.dart';
import 'package:jarvis/models/response/token_usage_response.dart';
import 'package:jarvis/utils/dio/dio_auth.dart';
import 'package:jarvis/utils/dio/dio_jarvis.dart';
import 'package:jarvis/utils/dio/dio_knowledge_base.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/response/api_response.dart';
import 'package:dio/dio.dart';

class AuthService {
  final dioAuth = DioAuth().dio;
  final dio = DioJarvis().dio;
  final dioKB = DioKnowledgeBase().dio;

  Future<ApiResponse> register(User user) async {
    try {
      final response = await dioAuth.post(
        '/auth/password/sign-up',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
        data: {
          'email': user.email,
          'password': user.password,
          'verification_callback_url':
              'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: 'Sign up successful',
          data: response.data,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        log('data: ${response.data}');
        return ApiResponse(
          success: false,
          message: 'Sign up failed: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data['error'];
        String errorMessage = 'Sign up failed';

        // Check for custom error messages in the response data
        if (errorData.isNotEmpty) {
          log('errorData: $errorData');
          errorMessage = errorData;
        }

        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: e.response!.statusCode ?? 400,
        );
      }
      return ApiResponse(
        success: false,
        message: 'Lỗi kết nối: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await dioAuth.post(
        '/auth/password/sign-in',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Login successful',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Login failed',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response != null) {
        final errorData = e.response!.data['error'];

        // Check for custom error messages in the response data
        if (errorData.isNotEmpty) {
          log('errorData: $errorData');
          errorMessage = errorData;
        }

        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: e.response!.statusCode ?? 400,
        );
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> getCurrentUser(String accessToken) async {
    try {
      final response = await dio.get('/auth/me');
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Get user information successful',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Get user information failed',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Unauthorized';
      if (e.response != null) {
        final errorData = e.response!.data;

        // Check for custom error messages in the response data
        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          // Collect all issues in `details` into a single message
          log('errorData: ${errorData['details']}');
          List<String> issues = (errorData['details'] as List<dynamic>)
              .map<String>((detail) => detail['issue'] ?? 'Unknown issue')
              .toList();
          errorMessage = issues.join(', ');
        }

        return ApiResponse(
          success: false,
          message: errorMessage,
          statusCode: e.response!.statusCode ?? 400,
        );
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final refreshToken = prefs.getString('refreshToken');

      final response = await dioAuth.delete(
        '/auth/sessions/current',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'X-Stack-Refresh-Token': refreshToken,
          },
        ),
        data: {},
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Logout successful',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Logout failed',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Unauthorized';
      if (e.response != null) {
        final errorData = e.response!.data['error'];

        if (errorData.isNotEmpty) {
          log('errorData: $errorData');
          errorMessage = errorData;
        }
      }

      return ApiResponse(
        success: false,
        message: errorMessage,
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<SubscriptionResponse> fetchSubscriptionDetails() async {
    try {
      final response = await dio.get('/subscriptions/me');
      print('✅ RESPONSE DATA SUBSCRIPTION: ${response.data}');
      if (response.statusCode == 200) {
        return SubscriptionResponse.fromJson(response.data);
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
}
