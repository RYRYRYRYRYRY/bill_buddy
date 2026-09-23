
class BankError implements Exception {
  final String code;
  final String message;

  const BankError({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}

