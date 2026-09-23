import 'package:dio/dio.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<Map<String, dynamic>> me() async {
    final response = await dio.get(
      '/auth/me',
    );

    return Map<String, dynamic>.from(
      response.data as Map,
    );
  }

  Future<void> logout({
    required String refreshToken,
  }) async {
    await dio.post(
      '/auth/logout',
      data: {
        'refreshToken': refreshToken,
      },
    );
  }
}