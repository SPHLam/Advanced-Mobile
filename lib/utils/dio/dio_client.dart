import 'package:dio/dio.dart';
import 'package:jarvis/utils/dio/interceptor.dart/auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.dev.jarvis.cx/api/v1',
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

    dio.interceptors.add(AuthInterceptor(dio: dio));
  }
}
