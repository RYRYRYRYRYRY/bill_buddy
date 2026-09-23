import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(authProvider.notifier)
        .logout();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final authState =
        ref.watch(authProvider);

    final user =
        authState.value?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BillBuddy'),
        actions: [
          IconButton(
            onPressed: () {
              _logout(context, ref);
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.email ?? ''}',
        ),
      ),
    );
  }
}