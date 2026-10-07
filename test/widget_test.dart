import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acorn/main.dart';

void main() {
  testWidgets('Import screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ImportScreen()));

    expect(find.text('Add your medications'), findsOneWidget);
    expect(find.text('Scan a label'), findsOneWidget);
  });
}
