import 'dart:developer';
import 'package:jarvis/utils/dio/dio_auth.dart';
import '../models/user_model.dart';
import '../models/response/api_response.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final dio = DioAuth().dio;

  Future<ApiResponse> register(User user) async {
    try {
      final response = await dio.post(
        '/auth/password/sign-up',
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
        message: 'Connection error: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/password/sign-in',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        if (accessToken == null || refreshToken == null) {
          return ApiResponse(
            success: false,
            message:
                'Login failed: Missing accessToken or refreshToken in response',
            statusCode: 400,
          );
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);

        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Login successful',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Login failed: ${response.data}',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response != null) {
        final errorData = e.response!.data['error'];

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
          message: 'Get user information failed: ${response.data}',
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
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        return ApiResponse(
          success: false,
          message: 'Refresh token not found. Please login again.',
          statusCode: 401,
        );
      }

      final response = await dio.delete(
        '/auth/sessions/current',
        options: Options(
          headers: {
            'X-Stack-Refresh-Token': refreshToken,
          },
        ),
        data: {},
      );

      if (response.statusCode == 200) {
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');

        return ApiResponse(
          success: true,
          data: response.data,
          message: 'Logout successful',
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Logout failed: ${response.data ?? 'Unknown error'}',
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
}
