import 'package:dio/dio.dart';
import 'package:jarvis/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  AuthInterceptor({required this.dio});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (options.path.contains('/auth/sessions/current/refresh')) {
      handler.next(options);
      return;
    }

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/sessions/current/refresh')) {
      final isTokenRefreshed = await _refreshAccessToken();
      if (isTokenRefreshed) {
        try {
          final retryResponse = await dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          handler.resolve(retryResponse);
          return;
        } catch (retryError) {
          if (retryError is DioException) {
            handler.next(retryError);
            return;
          }
        }
      } else {
        await _logout();
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      try {
        final response = await dio.post(
          '/auth/sessions/current/refresh',
          options: Options(
            headers: {
              'X-Stack-Refresh-Token': refreshToken,
            },
          ),
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['token']['accessToken'];
          await prefs.setString('accessToken', newAccessToken);
          return true;
        }
      } catch (e) {
        print('❌ Refresh token failed: $e');
        return false;
      }
    }
    return false;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false, arguments: true);
  }
}