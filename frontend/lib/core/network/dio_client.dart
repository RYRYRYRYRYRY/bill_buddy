import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  static const String baseUrl =
     'http://localhost:3000/api/v1';

  final SecureStorage storage;

  late final Dio dio;

  DioClient({
    required this.storage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(seconds: 10),
        receiveTimeout:
            const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
      ),
    );
  }
}