import 'dart:developer';
import 'package:jarvis/utils/dio/dio_client.dart';
import '../models/user_model.dart';
import '../models/response/api_response.dart';
import 'package:dio/dio.dart';

class AuthService {
  final dio = DioClient().dio;

  Future<ApiResponse> register(User user) async {
    try {
      final response = await dio.post(
        '/auth/sign-up',
        data: user.toJson(),
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
        final errorData = e.response!.data;
        String errorMessage = 'Sign up failed';

        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
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
        message: 'Connection error: $e',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/sign-in',
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
        final errorData = e.response!.data;

        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
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

        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
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
      final response = await dio.get('/auth/sign-out');
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
        final errorData = e.response!.data;

        if (errorData['details'] != null && errorData['details'].isNotEmpty) {
          log('errorData: ${errorData['details']}');
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
}
