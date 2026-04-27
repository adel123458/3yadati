import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders placeholder', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('قيد التطوير'))));
    expect(find.text('قيد التطوير'), findsOneWidget);
  });
}
