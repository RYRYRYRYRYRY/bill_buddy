import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/errors/bank_error_mapper.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/storage/secure_storage.dart';
import 'package:frontend/features/auth/data/auth_api.dart';
import 'package:frontend/features/auth/data/repo/auth_repository_impl.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repo/auth_repo.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return DioClient(storage: storage);
});

final authApiProvider = Provider<AuthApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);

  return AuthApi(dioClient.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.watch(authApiProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

class AuthState {
  final User? user;
  final bool initialized;

  const AuthState({required this.user, required this.initialized});

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final repository = ref.read(authRepositoryProvider);

    final user = await repository.restoreSession();

    return AuthState(user: user, initialized: true);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);

      final user = await repository.login(email: email, password: password);

      state = AsyncData(AuthState(user: user, initialized: true));
    } catch (error, stackTrace) {
      final bankError = BankErrorMapper.map(error);

      state = AsyncError(bankError, stackTrace);
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(authRepositoryProvider);

      final user = await repository.register(email: email, password: password);

      state = AsyncData(AuthState(user: user, initialized: true));
    } catch (error, stackTrace) {
      final bankError = BankErrorMapper.map(error);

      state = AsyncError(bankError, stackTrace);
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);

    await repository.logout();

    state = const AsyncData(AuthState(user: null, initialized: true));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
