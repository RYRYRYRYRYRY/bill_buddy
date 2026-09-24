import 'package:flutter/material.dart';

class BillerCategoryChip
    extends StatelessWidget {
  final String category;
  final bool selected;
  final VoidCallback onTap;

  const BillerCategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  String get displayName {
    if (category.isEmpty) {
      return category;
    }

    return category[0].toUpperCase() +
        category.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(displayName),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}