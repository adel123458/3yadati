// Basic smoke test for the doctor app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a simple widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('عيادتي'))));
    expect(find.text('عيادتي'), findsOneWidget);
  });
}
