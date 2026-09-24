class SavedBiller {
  final String id;
  final String userId;
  final String billerId;
  final String nickname;
  final Map<String, String> params;
  final bool autopayEnabled;
  final int autopayMaxPaise;

  const SavedBiller({
    required this.id,
    required this.userId,
    required this.billerId,
    required this.nickname,
    required this.params,
    required this.autopayEnabled,
    required this.autopayMaxPaise,
  });

  factory SavedBiller.fromJson(Map<String, dynamic> json) {
    final rawParams = json['params'] as Map<String, dynamic>;

    final params = rawParams.map(
      (key, value) => MapEntry(
        key,
        value.toString(),
      ),
    );

    final autopay =
        json['autopay'] as Map<String, dynamic>? ?? {};

    return SavedBiller(
      id: json['id'].toString(),
      userId: json['userId'].toString(),
      billerId: json['billerId'].toString(),
      nickname: json['nickname'].toString(),
      params: params,
      autopayEnabled: autopay['enabled'] == true,
      autopayMaxPaise:
          (autopay['maxPaise'] as num?)?.toInt() ?? 0,
    );
  }
}