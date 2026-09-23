import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/features/auth/domain/repo/auth_repo.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';

class FakeAuthRepository implements AuthRepository {
  User? loginUser;
  User? registerUser;

  bool logoutCalled = false;

  @override
  Future<User?> restoreSession() async {
    return null;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    return loginUser!;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    return registerUser!;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

void main() {
  const user = User(id: 'user-1', email: 'test@example.com');

  Widget testApp({
    required Widget screen,
    required FakeAuthRepository repository,
  }) {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: screen),
    );
  }

  group('LoginScreen', () {
    testWidgets('LoginScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      await tester.pump();

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
    testWidgets('accepts email and password input', (tester) async {
      final repository = FakeAuthRepository();

      await tester.pumpWidget(
        testApp(screen: const LoginScreen(), repository: repository),
      );

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'test@example.com');

      await tester.enterText(fields.at(1), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('login button can be pressed', (tester) async {
      final repository = FakeAuthRepository()..loginUser = user;

      await tester.pumpWidget(
        testApp(screen: const LoginScreen(), repository: repository),
      );

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'test@example.com');

      await tester.enterText(fields.at(1), 'password123');

      final loginButton = find.byType(FilledButton);

      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);

      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(LoginScreen)),
      );

      final state = container.read(authProvider);

      expect(state.hasValue, isTrue);
      expect(state.value?.isAuthenticated, isTrue);
      expect(state.value?.user?.email, 'test@example.com');
    });
  });

  group('RegisterScreen', () {
    testWidgets('renders registration screen', (tester) async {
      final repository = FakeAuthRepository();

      await tester.pumpWidget(
        testApp(screen: const RegisterScreen(), repository: repository),
      );

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Already have an account? Login'), findsOneWidget);
    });

    testWidgets('accepts email and password input', (tester) async {
      final repository = FakeAuthRepository();

      await tester.pumpWidget(
        testApp(screen: const RegisterScreen(), repository: repository),
      );

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'test@example.com');

      await tester.enterText(fields.at(1), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);

      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('register button can be pressed', (tester) async {
      final repository = FakeAuthRepository()..registerUser = user;

      await tester.pumpWidget(
        testApp(screen: const RegisterScreen(), repository: repository),
      );

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'test@example.com');

      await tester.enterText(fields.at(1), 'password123');

      final registerButton = find.byType(FilledButton);

      expect(registerButton, findsOneWidget);

      await tester.tap(registerButton);

      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(RegisterScreen)),
      );

      final state = container.read(authProvider);

      expect(state.hasValue, isTrue);
      expect(state.value?.isAuthenticated, isTrue);
      expect(state.value?.user?.email, 'test@example.com');
    });
  });

  group('HomeScreen', () {
    testWidgets('shows BillBuddy and user email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(() => TestAuthNotifier(user))],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BillBuddy'), findsOneWidget);

      expect(find.text('Welcome test@example.com'), findsOneWidget);

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });
}

class TestAuthNotifier extends AuthNotifier {
  final User testUser;

  TestAuthNotifier(this.testUser);

  @override
  Future<AuthState> build() async {
    return AuthState(user: testUser, initialized: true);
  }
}
