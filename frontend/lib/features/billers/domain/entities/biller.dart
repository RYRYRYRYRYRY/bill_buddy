class BillerField {
  final String key;
  final String label;
  final String regex;

  const BillerField({
    required this.key,
    required this.label,
    required this.regex,
  });

  factory BillerField.fromJson(Map<String, dynamic> json) {
    return BillerField(
      key: json['key'] as String,
      label: json['label'] as String,
      regex: json['regex'] as String,
    );
  }
}

class Biller {
  final String id;
  final String name;
  final String category;
  final String state;
  final List<BillerField> fields;
  final bool allowsPartial;

  const Biller({
    required this.id,
    required this.name,
    required this.category,
    required this.state,
    required this.fields,
    required this.allowsPartial,
  });

  factory Biller.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'] as List<dynamic>? ?? [];

    return Biller(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      state: json['state'] as String,
      fields: rawFields
          .map(
            (field) => BillerField.fromJson(
              field as Map<String, dynamic>,
            ),
          )
          .toList(),
      allowsPartial: json['allowsPartial'] as bool,
    );
  }
}