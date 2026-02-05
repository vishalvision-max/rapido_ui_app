// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rapido_ui_app/main.dart';

void main() {
  testWidgets('App starts with splash screen test', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RapidoApp());
    await tester.pump(); // Start building

    // Verify that our splash screen shows the 'RAPIDO' logo text.
    expect(find.text('RAPIDO'), findsOneWidget);

    // Verify that certain icons are present
    expect(find.byIcon(Icons.two_wheeler), findsOneWidget);

    // To prevent "A Timer is still pending" error, we need to exhaust the 3s timer.
    // We use pump with a duration to skip ahead in time.
    await tester.pump(const Duration(seconds: 3));
  });
}
