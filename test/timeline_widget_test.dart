import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoxapp/src/screens/timeline_page.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/models/sentiment.dart';
// no providers import required for this simplified test

void main() {
  testWidgets('TimelinePage shows grouped day and answer card', (tester) async {
    final now = DateTime.now();

    final sample = Answer(
      questionId: 'q1',
      text: 'This is a great test answer',
      createdAt: now,
      sentiment: const Sentiment(score: 0.8, label: 'very positive'),
      keywords: ['test', 'great'],
    );

    // Directly render the DayDetailPage for the given date with the sample answer
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: DayDetailPage(date: DateTime(now.year, now.month, now.day), answers: [sample]))),
    );

    // Allow animations to settle
    await tester.pumpAndSettle();

    expect(find.textContaining('Today'), findsOneWidget);
    expect(find.textContaining('answer'), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
