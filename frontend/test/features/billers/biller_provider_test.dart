import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/features/billers/domain/entities/biller.dart';
import 'package:frontend/features/billers/domain/entities/saved_biller.dart';
import 'package:frontend/features/billers/domain/repo/biller_repository.dart';
import 'package:frontend/features/billers/presentation/providers/biller_provider.dart';

class FakeBillerRepository implements BillerRepository {
  @override
  Future<List<String>> getCategories() async {
    return [
      'electricity',
      'water',
      'gas',
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
    ];
  }

  @override
  Future<Biller> getBiller(String id) async {
    return const Biller(
      id: 'demo-electricity',
      name: 'Demo Electricity Board',
      category: 'electricity',
      state: 'MH',
      fields: [],
      allowsPartial: true,
    );
  }

  @override
  Future<SavedBiller> saveBiller({required String billerId, required String nickname, required Map<String, String> params}) {
    // TODO: implement saveBiller
    throw UnimplementedError();
  }
}

void main() {
  test(
    'categories provider returns categories',
    () async {
      final container = ProviderContainer(
        overrides: [
          billerRepositoryProvider.overrideWithValue(
            FakeBillerRepository(),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = await container.read(
        billerCategoriesProvider.future,
      );

      expect(
        result,
        ['electricity', 'water', 'gas'],
      );
    },
  );

  test(
    'directory provider returns billers',
    () async {
      final container = ProviderContainer(
        overrides: [
          billerRepositoryProvider.overrideWithValue(
            FakeBillerRepository(),
          ),
        ],
      );

      addTearDown(container.dispose);

      final result = await container.read(
        billerDirectoryProvider(
          const BillerDirectoryFilter(
            category: 'electricity',
          ),
        ).future,
      );

      expect(result.length, 1);
      expect(
        result.first.name,
        'Demo Electricity Board',
      );
    },
  );
}