import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/billers/presentation/widgets/biller_category_chip.dart';

void main() {
  testWidgets(
    'category chip displays category',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillerCategoryChip(
              category: 'electricity',
              selected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Electricity'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'category chip calls callback',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillerCategoryChip(
              category: 'water',
              selected: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Water'));

      expect(tapped, isTrue);
    },
  );
}