import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/core/errors/bank_error_mapper.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';

import 'package:frontend/features/billers/data/biller_api.dart';
import 'package:frontend/features/billers/data/repo/biller_repository_impl.dart';

import 'package:frontend/features/billers/domain/entities/biller.dart';
import 'package:frontend/features/billers/domain/entities/saved_biller.dart';
import 'package:frontend/features/billers/domain/repo/biller_repository.dart';

final billerApiProvider =
    Provider<BillerApi>((ref) {
  final dioClient =
      ref.watch(dioClientProvider);

  return BillerApi(dioClient.dio);
});

final billerRepositoryProvider =
    Provider<BillerRepository>((ref) {
  return BillerRepositoryImpl(
    api: ref.watch(billerApiProvider),
  );
});

final billerCategoriesProvider =
    FutureProvider<List<String>>(
  (ref) async {
    return ref
        .watch(billerRepositoryProvider)
        .getCategories();
  },
);

final billerDirectoryProvider =
    FutureProvider.family<
        List<Biller>,
        BillerDirectoryFilter>(
  (ref, filter) async {
    return ref
        .watch(billerRepositoryProvider)
        .getBillers(
          category: filter.category,
          query: filter.query,
          state: filter.state,
        );
  },
);

class BillerDirectoryFilter {
  final String? category;
  final String? query;
  final String? state;

  const BillerDirectoryFilter({
    this.category,
    this.query,
    this.state,
  });

  @override
  bool operator ==(Object other) {
    return other
            is BillerDirectoryFilter &&
        other.category == category &&
        other.query == query &&
        other.state == state;
  }

  @override
  int get hashCode =>
      Object.hash(
        category,
        query,
        state,
      );
}

class BillerState {
  final Biller? biller;
  final SavedBiller? savedBiller;

  const BillerState({
    this.biller,
    this.savedBiller,
  });
}

class BillerNotifier
    extends AsyncNotifier<BillerState> {
  @override
  Future<BillerState> build() async {
    return const BillerState();
  }

  Future<void> loadBiller(
    String billerId,
  ) async {
    state = const AsyncLoading();

    try {
      final biller =
          await ref
              .read(
                billerRepositoryProvider,
              )
              .getBiller(billerId);

      state = AsyncData(
        BillerState(
          biller: biller,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        BankErrorMapper.map(error),
        stackTrace,
      );
    }
  }

  Future<bool> saveBiller({
    required String nickname,
    required Map<String, String> params,
  }) async {
    final biller =
        state.value?.biller;

    if (biller == null) {
      return false;
    }

    try {
      final saved =
          await ref
              .read(
                billerRepositoryProvider,
              )
              .saveBiller(
                billerId: biller.id,
                nickname: nickname,
                params: params,
              );

      state = AsyncData(
        BillerState(
          biller: biller,
          savedBiller: saved,
        ),
      );

      return true;
    } catch (error, stackTrace) {
      state = AsyncError(
        BankErrorMapper.map(error),
        stackTrace,
      );

      return false;
    }
  }
}

final billerProvider =
    AsyncNotifierProvider<
        BillerNotifier,
        BillerState>(
  BillerNotifier.new,
);