import 'dart:developer';
import 'package:project_ai_chat/models/response/subscription_response.dart';
import 'package:project_ai_chat/models/response/token_usage_response.dart';
import 'package:project_ai_chat/utils/dio/dio_auth.dart';
import 'package:project_ai_chat/utils/dio/dio_jarvis.dart';
import 'package:project_ai_chat/utils/dio/dio_knowledge_base.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          }
        ),
        data: {
          'email': user.email,
          'password': user.password,
          'verification_callback_url': 'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess',
        },
      );


      return ApiResponse(
        success: true,
        message: 'Sign up successful',
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
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
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          }
        ),
        data: {
          'email': email,
          'password': password,
        },
      );

      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Login successful',
        statusCode: response.statusCode ?? 200,
      );
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

      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Get user information successful',
        statusCode: response.statusCode ?? 200,
      );
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


      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Logout successful',
        statusCode: response.statusCode ?? 200,
      );
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

      return SubscriptionResponse.fromJson(response.data);
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

      return TokenUsageResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ChatException(
        message: e.response?.data?['message'] ??
            e.message ??
            'Lỗi kết nối tới server',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  Future<ApiResponse> loginGoogle(String code, String codeVerifier) async {
    try {
      final formData = {
      'redirect_uri': 'https://dev.jarvis.cx/auth/handler/oauth-callback',
      'code_verifier': codeVerifier,
      'code': code,
      'grant_type': 'authorization_code',
      'client_id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
      'client_secret': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
      };

      final response = await dioAuth.post(
        '/auth/oauth/token',
        options: Options(
            headers: {
              'Content-Type': 'application/json',
            }
        ),
        data: formData,
      );

      return ApiResponse(
        success: true,
        data: response.data,
        message: 'Login successful',
        statusCode: response.statusCode ?? 200,
      );
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
}
