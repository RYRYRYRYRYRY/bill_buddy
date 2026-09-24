import 'package:dio/dio.dart';

class BillerApi {
  final Dio dio;

  const BillerApi(this.dio);

  Future<List<String>> getCategories() async {
    final response =
        await dio.get(
      '/biller-categories',
    );

    final data =
        response.data
            as Map<String, dynamic>;

    return (data['categories']
            as List<dynamic>)
        .map(
          (value) => value as String,
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>>
      getBillers({
    String? category,
    String? query,
    String? state,
  }) async {
    final response = await dio.get(
      '/billers',
      queryParameters: {
        if (category != null)
          'category': category,
        if (query != null &&
            query.trim().isNotEmpty)
          'q': query.trim(),
        if (state != null &&
            state.trim().isNotEmpty)
          'state': state,
      },
    );

    final data =
        response.data
            as Map<String, dynamic>;

    return (data['billers']
            as List<dynamic>)
        .map(
          (value) =>
              value as Map<String, dynamic>,
        )
        .toList();
  }

  Future<Map<String, dynamic>>
      getBiller(
    String id,
  ) async {
    final response =
        await dio.get(
      '/billers/$id',
    );

    return response.data
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>>
      saveBiller({
    required String billerId,
    required String nickname,
    required Map<String, String> params,
  }) async {
    final response = await dio.post(
      '/my-billers',
      data: {
        'billerId': billerId,
        'nickname': nickname,
        'params': params,
      },
    );

    return response.data
        as Map<String, dynamic>;
  }
}