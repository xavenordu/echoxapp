import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echoxapp/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
  // Build our app and trigger a frame
  await tester.pumpWidget(ProviderScope(child: const EchoXapp()));

    // Verify we can find the Unreality tab (Dream Journal)
    expect(find.text('Unreality'), findsOneWidget);
    
    // Verify the initial screen has expected elements
    expect(find.widgetWithText(TextField, 'Write your dream... fragments, images, feelings.'), findsOneWidget);
    expect(find.byIcon(Icons.bedtime), findsOneWidget);
  });
}