import 'package:dio/dio.dart';

class DioAuth {
  static final DioAuth _instance = DioAuth._internal();
  late Dio dio;

  factory DioAuth() {
    return _instance;
  }

  DioAuth._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://auth-api.dev.jarvis.cx/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'X-Stack-Access-Type': 'client',
          'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
          'X-Stack-Publishable-Client-Key': 'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
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
  }
}
