import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

class BillBuddyApp extends ConsumerWidget {
  const BillBuddyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router =
        ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BillBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}