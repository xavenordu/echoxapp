import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoxapp/src/models/question.dart';
import 'package:echoxapp/src/models/mirror_response.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/repositories/question_repository.dart';
import 'package:echoxapp/src/widgets/answer_card.dart';
import 'package:echoxapp/src/widgets/sentiment_journey_chart.dart';
import 'package:echoxapp/src/widgets/word_cloud.dart';
import 'package:echoxapp/src/widgets/reaction_buttons.dart';

import 'package:echoxapp/providers.dart';

class QuestionPage extends ConsumerWidget {
  const QuestionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(todayContentProvider);
    final answerCountAsync = ref.watch(answerCountProvider);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: contentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
          data: (content) {
            if (content == null) {
              return const Center(
                child: Text('No content available for today.'),
              );
            }

            // Show answer count progress
            final progressRow = answerCountAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (count) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_edu,
                      color: Colors.deepPurple.withAlpha(180),
                    ),
                    const SizedBox(width: 8),
                    Text('$count answers so far'),
                  ],
                ),
              ),
            );

            if (content is MirrorResponse) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mirror Mode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  // Mirror mode chip
                  Chip(
                    label: const Text('AI-You'),
                    backgroundColor: Colors.teal.withAlpha(25),
                    avatar: const Icon(Icons.auto_awesome, size: 16),
                  ),
                  progressRow,
                  // The reflection prompt
                  // Sentiment journey chart
                  FutureBuilder<List<Answer>>(
                    future: ref.watch(filteredAnswersProvider.future),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final answers = snapshot.data!;
                      if (answers.isEmpty) return const SizedBox.shrink();

                      // Calculate word frequencies
                      final wordFreq = <String, int>{};
                      for (final answer in answers) {
                        for (final keyword in answer.keywords) {
                          wordFreq[keyword] = (wordFreq[keyword] ?? 0) + 1;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Journey',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SentimentJourneyChart(
                              answers: answers,
                              height: 120,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Key Themes',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            WordCloud(
                              wordFrequencies: wordFreq,
                              height: 160,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Mirror response
                  Text(
                    content.text,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reaction buttons
                  Center(
                    child: ReactionButtons(
                      onReaction: (isHelpful) async {
                        final repo = await ref.read(questionRepositoryProvider.future);
                        final answer = Answer(
                          questionId: content.basedOnPhrase,
                          text: content.text,
                          wasHelpful: isHelpful,
                        );
                        await repo.saveAnswer(answer.questionId, answer.text);
                        // Refresh content
                        ref.invalidate(filteredAnswersProvider);
                      },
                    ),
                  ),
                ],
              );
            }

            final question = content as Question;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Question',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                // Category chip
                Chip(
                  label: Text(question.category),
                  backgroundColor: Colors.deepPurple.withAlpha(25),
                ),
                progressRow,
                // The question
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                // Answer card
                Consumer(
                  builder: (context, ref, _) {
                    final answersAsync = ref.watch(filteredAnswersProvider);
                    return answersAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                      data: (answers) {
                        // Find answers for this question
                        final questionAnswers = answers
                            .where((a) => a.questionId == question.id)
                            .map((a) => a.text)
                            .toList();
                        final lastAnswer = questionAnswers.isNotEmpty ? questionAnswers.last : null;
                        
                        return AnswerCard(
                          questionId: question.id,
                          initialAnswer: lastAnswer,
                          onSubmit: (answer) async {
                            final repo = await ref.read(questionRepositoryProvider.future);
                            await repo.saveAnswer(question.id, answer);
                            // Refresh answers
                            ref.invalidate(filteredAnswersProvider);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}