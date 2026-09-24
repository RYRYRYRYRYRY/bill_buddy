import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/billers/domain/entities/biller.dart';
import 'package:frontend/features/billers/presentation/widgets/biller_list_tile.dart';

void main() {
  const biller = Biller(
    id: 'demo-electricity',
    name: 'Demo Electricity Board',
    category: 'electricity',
    state: 'MH',
    fields: [],
    allowsPartial: true,
  );

  testWidgets(
    'list tile displays biller information',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BillerListTile(
              biller: biller,
              onTap: _noop,
            ),
          ),
        ),
      );

      expect(
        find.text('Demo Electricity Board'),
        findsOneWidget,
      );

      expect(
        find.text('electricity • MH'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'list tile calls callback',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillerListTile(
              biller: biller,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(
        find.text('Demo Electricity Board'),
      );

      expect(tapped, isTrue);
    },
  );
}

void _noop() {}