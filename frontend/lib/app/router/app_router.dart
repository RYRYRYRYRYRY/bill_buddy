import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/register_screen.dart';
import 'package:frontend/features/billers/presentation/screens/biller_directory_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/billers/presentation/screens/add_biller_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/billers',
        builder: (context, state) {
          return const BillerDirectoryScreen();
        },
      ),

      GoRoute(
        path: '/billers/:id/add',
        builder: (context, state) {
          final billerId = state.pathParameters['id']!;

          return AddBillerScreen(billerId: billerId);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (authState.isLoading) {
        return null;
      }

      if (authState.hasError) {
        return '/login';
      }

      final authenticated = authState.value?.isAuthenticated ?? false;

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!authenticated && !isAuthRoute) {
        return '/login';
      }

      if (authenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
  );

  ref.listen<AsyncValue<AuthState>>(authProvider, (_, _) {
    router.refresh();
  });

  ref.onDispose(router.dispose);

  return router;
});
