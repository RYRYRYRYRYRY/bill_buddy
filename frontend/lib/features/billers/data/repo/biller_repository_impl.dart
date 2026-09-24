import 'package:frontend/core/errors/bank_error_mapper.dart';
import 'package:frontend/features/billers/data/biller_api.dart';
import 'package:frontend/features/billers/domain/entities/biller.dart';
import 'package:frontend/features/billers/domain/entities/saved_biller.dart';
import 'package:frontend/features/billers/domain/repo/biller_repository.dart';

class BillerRepositoryImpl
    implements BillerRepository {
  final BillerApi api;

  const BillerRepositoryImpl({
    required this.api,
  });

  @override
  Future<List<String>> getCategories() async {
    try {
      return await api.getCategories();
    } catch (error) {
      throw BankErrorMapper.map(error);
    }
  }

  @override
  Future<List<Biller>> getBillers({
    String? category,
    String? query,
    String? state,
  }) async {
    try {
      final response =
          await api.getBillers(
        category: category,
        query: query,
        state: state,
      );

      return response
          .map(Biller.fromJson)
          .toList();
    } catch (error) {
      throw BankErrorMapper.map(error);
    }
  }

  @override
  Future<Biller> getBiller(
    String id,
  ) async {
    try {
      final response =
          await api.getBiller(id);

      return Biller.fromJson(response);
    } catch (error) {
      throw BankErrorMapper.map(error);
    }
  }

  @override
  Future<SavedBiller> saveBiller({
    required String billerId,
    required String nickname,
    required Map<String, String> params,
  }) async {
    try {
      final response =
          await api.saveBiller(
        billerId: billerId,
        nickname: nickname,
        params: params,
      );

      return SavedBiller.fromJson(
        response,
      );
    } catch (error) {
      throw BankErrorMapper.map(error);
    }
  }
}