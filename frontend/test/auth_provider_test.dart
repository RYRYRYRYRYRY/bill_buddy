import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/core/errors/bank_error.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repo/auth_repo.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

class FakeAuthRepository implements AuthRepository {
  User? user;
  Object? loginError;
  bool logoutCalled = false;

  @override
  Future<User?> restoreSession() async {
    return user;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    if (loginError != null) {
      throw loginError!;
    }

    return user!;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    return user!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  const user = User(id: 'user-1', email: 'test@example.com');

  test('restoreSession returns authenticated state', () async {
    final repository = FakeAuthRepository()..user = user;

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final state = await container.read(authProvider.future);

    expect(state.initialized, isTrue);
    expect(state.isAuthenticated, isTrue);
    expect(state.user?.email, 'test@example.com');
  });

  test('restoreSession returns unauthenticated state', () async {
    final repository = FakeAuthRepository();

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final state = await container.read(authProvider.future);

    expect(state.initialized, isTrue);
    expect(state.isAuthenticated, isFalse);
    expect(state.user, isNull);
  });

  test('login authenticates the user', () async {
    final repository = FakeAuthRepository()..user = user;

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    await container.read(authProvider.future);

    await container
        .read(authProvider.notifier)
        .login(email: 'test@example.com', password: 'password123');

    final state = container.read(authProvider);

    expect(state.hasValue, isTrue);
    expect(state.value?.isAuthenticated, isTrue);
    expect(state.value?.user?.email, 'test@example.com');
  });

  test('login converts errors to BankError', () async {
    final repository = FakeAuthRepository()
      ..loginError = const BankError(
        code: 'INVALID_CREDENTIALS',
        message: 'The email or password is incorrect.',
      );

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    await container.read(authProvider.future);

    await container
        .read(authProvider.notifier)
        .login(email: 'test@example.com', password: 'wrong');

    final state = container.read(authProvider);

    expect(state.hasError, isTrue);
    expect(state.error, isA<BankError>());

    final error = state.error as BankError;

    expect(error.code, 'INVALID_CREDENTIALS');
  });

  test('logout clears the authenticated user', () async {
    final repository = FakeAuthRepository()..user = user;

    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    await container.read(authProvider.future);

    await container.read(authProvider.notifier).logout();

    final state = container.read(authProvider);

    expect(state.hasValue, isTrue);
    expect(state.value?.isAuthenticated, isFalse);
    expect(state.value?.user, isNull);
    expect(repository.logoutCalled, isTrue);
  });
}
