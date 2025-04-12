import 'package:dio/dio.dart';
import 'package:jarvis/utils/dio/interceptor.dart/auth_interceptor.dart';

class DioJarvis {
  static final DioJarvis _instance = DioJarvis._internal();
  late Dio dio;

  factory DioJarvis() {
    return _instance;
  }

  DioJarvis._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.dev.jarvis.cx/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'x-jarvis-guid': '',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    dio.interceptors.add(AuthInterceptor(dio: dio));
  }
}