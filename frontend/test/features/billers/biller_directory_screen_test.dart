import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/features/billers/domain/entities/biller.dart';
import 'package:frontend/features/billers/domain/entities/saved_biller.dart';
import 'package:frontend/features/billers/domain/repo/biller_repository.dart';
import 'package:frontend/features/billers/presentation/providers/biller_provider.dart';
import 'package:frontend/features/billers/presentation/screens/biller_directory_screen.dart';

class FakeBillerRepository implements BillerRepository {
  @override
  Future<List<String>> getCategories() async {
    return [
      'electricity',
      'water',
    ];
  }

  @override
  Future<List<Biller>> getBillers({
    String? category,
    String? query,
    String? state,
  }) async {
    return [
      const Biller(
        id: 'demo-electricity',
        name: 'Demo Electricity Board',
        category: 'electricity',
        state: 'MH',
        fields: [],
        allowsPartial: true,
      ),
      const Biller(
        id: 'demo-water',
        name: 'Demo Water Board',
        category: 'water',
        state: 'MH',
        fields: [],
        allowsPartial: false,
      ),
    ];
  }

  @override
  Future<Biller> getBiller(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<SavedBiller> saveBiller({required String billerId, required String nickname, required Map<String, String> params}) {
    // TODO: implement saveBiller
    throw UnimplementedError();
  }
}

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        billerRepositoryProvider.overrideWithValue(
          FakeBillerRepository(),
        ),
      ],
      child: const MaterialApp(
        home: BillerDirectoryScreen(),
      ),
    );
  }

  testWidgets(
    'directory screen renders billers',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Billers'),
        findsOneWidget,
      );

      expect(
        find.text('Demo Electricity Board'),
        findsOneWidget,
      );

      expect(
        find.text('Demo Water Board'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'directory screen renders search field',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(),
      );

      await tester.pumpAndSettle();

      expect(
        find.byType(TextField),
        findsOneWidget,
      );

      expect(
        find.text('Search billers'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'directory screen renders category filters',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('All'),
        findsOneWidget,
      );

      expect(
        find.text('Electricity'),
        findsOneWidget,
      );

      expect(
        find.text('Water'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'directory screen renders state filter',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('State'),
        findsOneWidget,
      );
    },
  );
}