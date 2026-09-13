// Smoke test mínimo para o Daily Flow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke: Scaffold monta', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Daily Flow'))),
    );
    expect(find.text('Daily Flow'), findsOneWidget);
  });
}
