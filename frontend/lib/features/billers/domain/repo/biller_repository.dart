import '../entities/biller.dart';
import '../entities/saved_biller.dart';

abstract interface class BillerRepository {
  Future<List<String>> getCategories();

  Future<List<Biller>> getBillers({
    String? category,
    String? query,
    String? state,
  });

  Future<Biller> getBiller(String id);

  Future<SavedBiller> saveBiller({
    required String billerId,
    required String nickname,
    required Map<String, String> params,
  });
}