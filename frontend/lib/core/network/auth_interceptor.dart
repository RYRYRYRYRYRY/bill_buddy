import 'package:dio/dio.dart';
import 'package:frontend/core/storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorage storage;

  Future<String?>? _refreshing;

  AuthInterceptor({required this.dio, required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await storage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle expired/invalid access tokens.
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't try to refresh the refresh request itself.
    if (err.requestOptions.path.endsWith('/auth/refresh')) {
      await storage.clear();
      handler.next(err);
      return;
    }

    try {
      final newAccessToken = await _refreshAccessToken();

      if (newAccessToken == null) {
        await storage.clear();
        handler.next(err);
        return;
      }

      final requestOptions = err.requestOptions;

      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final response = await dio.fetch(requestOptions);

      handler.resolve(response);
    } catch (_) {
      await storage.clear();
      handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() async {
    // If another request is already refreshing,
    // wait for that refresh instead of starting another one.
    if (_refreshing != null) {
      return _refreshing!;
    }

    _refreshing = _performRefresh();

    try {
      return await _refreshing!;
    } finally {
      _refreshing = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await storage.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    // Use a separate Dio instance so the refresh
    // request doesn't trigger this interceptor again.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final data = Map<String, dynamic>.from(response.data as Map);

    final accessToken = data['accessToken'] as String;

    final newRefreshToken = data['refreshToken'] as String;

    await storage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );

    return accessToken;
  }
}
