import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repo/auth_repo.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final SecureStorage storage;

  AuthRepositoryImpl({
    required this.api,
    required this.storage,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final data = await api.login(
      email: email,
      password: password,
    );

    await _saveTokens(data);

    return User.fromJson(
      Map<String, dynamic>.from(
        data['user'] as Map,
      ),
    );
  }

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    final data = await api.register(
      email: email,
      password: password,
    );

    await _saveTokens(data);

    return User.fromJson(
      Map<String, dynamic>.from(
        data['user'] as Map,
      ),
    );
  }

  @override
  Future<User?> restoreSession() async {
    final accessToken =
        await storage.getAccessToken();

    final refreshToken =
        await storage.getRefreshToken();

    if (accessToken == null ||
        refreshToken == null) {
      return null;
    }

    try {
      final data = await api.me();

      return User.fromJson(data);
    } catch (_) {
      await storage.clear();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final refreshToken =
        await storage.getRefreshToken();

    if (refreshToken != null) {
      try {
        await api.logout(
          refreshToken: refreshToken,
        );
      } catch (_) {
        // Local logout must still happen.
      }
    }

    await storage.clear();
  }

  Future<void> _saveTokens(
    Map<String, dynamic> data,
  ) async {
    await storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}