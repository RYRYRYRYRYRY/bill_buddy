import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';


String? sessionGuard(
  Ref ref,
  String location,
) {
  final authState =
      ref.read(authProvider);

  if (authState.isLoading) {
    return null;
  }

  if (authState.hasError) {
    return '/login';
  }

  final authenticated =
      authState.value?.isAuthenticated ?? false;

  final isAuthRoute =
      location == '/login' ||
      location == '/register';

  if (!authenticated && !isAuthRoute) {
    return '/login';
  }

  if (authenticated && isAuthRoute) {
    return '/home';
  }

  return null;
}