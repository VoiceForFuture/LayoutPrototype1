// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_test_1/main.dart';

void main() {
  testWidgets('Create Post Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    expect(find.text('SuperSecretTitle'), findsNothing);

    // Tap the '+' icon
    await tester.tap(find.byIcon(Icons.add));

    // Wait for the dialog to appear
    await tester.pumpAndSettle();

    // Verify that our dialog has appeared
    expect(find.text('New Post'), findsOneWidget);

    // Enter the title
    await tester.enterText(find.bySemanticsLabel('Title'), 'SuperSecretTitle');

    // Post
    await tester.tap(find.text('Post'));

    // Wait for the dialog to disappear
    await tester.pumpAndSettle();

    // Verify that our post has been created
    expect(find.text('SuperSecretTitle'), findsOneWidget);
  });
}
