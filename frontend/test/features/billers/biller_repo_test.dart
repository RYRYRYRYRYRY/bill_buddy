import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/billers/data/biller_api.dart';
import 'package:frontend/features/billers/data/repo/biller_repository_impl.dart';

class FakeBillerApi extends BillerApi {
  FakeBillerApi() : super(Dio());

  @override
  Future<List<String>> getCategories() async {
    return [
      'electricity',
      'water',
      'gas',
      'broadband',
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getBillers({
    String? category,
    String? query,
    String? state,
  }) async {
    return [
      {
        'id': 'demo-electricity',
        'name': 'Demo Electricity Board',
        'category': 'electricity',
        'state': 'MH',
        'fields': [
          {
            'key': 'consumerNumber',
            'label': 'Consumer Number',
            'regex': '^[0-9]{8,12}\$',
          },
        ],
        'allowsPartial': true,
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getBiller(
    String id,
  ) async {
    return {
      'id': id,
      'name': 'Demo Electricity Board',
      'category': 'electricity',
      'state': 'MH',
      'fields': [],
      'allowsPartial': true,
    };
  }
}

void main() {
  test(
    'repository maps billers from API',
    () async {
      final repository = BillerRepositoryImpl(
        api: FakeBillerApi(),
      );

      final result = await repository.getBillers();

      expect(result.length, 1);
      expect(
        result.first.id,
        'demo-electricity',
      );
      expect(
        result.first.name,
        'Demo Electricity Board',
      );
    },
  );

  test(
    'repository loads categories',
    () async {
      final repository = BillerRepositoryImpl(
        api: FakeBillerApi(),
      );

      final result =
          await repository.getCategories();

      expect(
        result,
        contains('electricity'),
      );
      expect(
        result,
        contains('water'),
      );
      expect(
        result,
        contains('gas'),
      );
    },
  );
}