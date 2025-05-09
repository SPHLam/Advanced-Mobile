import 'package:dio/dio.dart';
import 'package:project_ai_chat/main.dart';
import 'package:project_ai_chat/utils/dio/dio_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Dio dioAuth = DioAuth().dio;
  AuthInterceptor({required this.dio});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Thêm accessToken vào mỗi request
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
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
    if (err.response?.data['message'] == 'Unauthorized' &&
        !err.requestOptions.path.contains('/auth/sessions/current/refresh')) {
      // Thử làm mới accessToken

      final isTokenRefreshed = await _refreshAccessToken();
      if (isTokenRefreshed) {
        // Gửi lại request với accessToken mới
        try {
          final retryResponse = await dio.request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              // headers: error.requestOptions.headers, do onrequest đã có rồi
            ),
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
          );
          handler.resolve(retryResponse); // Trả về response mới
          return;
        } catch (retryError) {
          if (retryError is DioException) {
            handler.next(retryError); // Hoặc xử lý lại theo cách khác
            return;
          }
        }
      } else {
        // Nếu làm mới token không thành công, đăng xuất
        await _logout();
      }
    }
    handler.next(err); // Trả về lỗi nếu không xử lý được
  }

  Future<bool> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    try {
      final response = await dioAuth.post(
        '/auth/sessions/current/refresh',
        options: Options(
          headers: {
            'X-Stack-Refresh-Token': refreshToken,
          },
        ),
      );

      final newAccessToken = response.data['access_token'];
      await prefs.setString('accessToken', newAccessToken);
      return true;
    } catch (e) {
      print('Lỗi làm mới token: $e');
      return false;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/login', (route) => false, arguments: true);
  }
}
