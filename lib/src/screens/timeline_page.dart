import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/repositories/question_repository.dart';

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  String? _selectedSentiment;
  final _keywordController = TextEditingController();

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Color _colorForScore(double score) {
    if (score > 0.2) return Colors.green.shade400;
    if (score < -0.2) return Colors.red.shade400;
    return Colors.grey.shade500;
  }

  String _emojiForScore(double score) {
    if (score > 0.2) return '😊';
    if (score < -0.2) return '😔';
    return '😐';
  }

  double _avgScoreForDay(List<Answer> answers) {
    final scores = answers.map((a) => a.sentiment?.score ?? 0.0).toList();
    if (scores.isEmpty) return 0.0;
    return scores.reduce((v, e) => v + e) / scores.length;
  }

  @override
  Widget build(BuildContext context) {
    // We'll load grouped answers directly from the repository to avoid
    // depending on Riverpod providers here. Filters are local state and
    // will re-trigger the FutureBuilder on setState.
    final future = _loadGroupedAnswers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keywordController,
                    decoration: const InputDecoration(
                      hintText: 'Filter by keyword',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (v) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _selectedSentiment,
                  hint: const Text('Sentiment'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'very positive', child: Text('Positive')),
                    DropdownMenuItem(value: 'positive', child: Text('Positive')),
                    DropdownMenuItem(value: 'neutral', child: Text('Neutral')),
                    DropdownMenuItem(value: 'negative', child: Text('Negative')),
                    DropdownMenuItem(value: 'very negative', child: Text('Very Negative')),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedSentiment = v);
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<DateTime, List<Answer>>>(
              future: future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error loading timeline: ${snap.error}'));
                }
                final grouped = snap.data ?? {};
                if (grouped.isEmpty) return const Center(child: Text('No answers yet'));

                final entries = grouped.entries.toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final day = entries[index].key;
                    final answers = entries[index].value;
                    final avg = _avgScoreForDay(answers);
                    final color = _colorForScore(avg);
                    final emoji = _emojiForScore(avg);

                    return FadeInListItem(
                      index: index,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => DayDetailPage(date: day, answers: answers),
                            ));
                          },
                          leading: CircleAvatar(
                            backgroundColor: color,
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(DateFormat.yMMMMd().format(day)),
                          subtitle: Text('${answers.length} answer${answers.length == 1 ? '' : 's'} — avg ${avg.toStringAsFixed(2)}'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Future<Map<DateTime, List<Answer>>> _loadGroupedAnswers() async {
    final repo = await QuestionRepository.instance;

    // If filters are set, fetch filtered answers and group locally
    if ((_keywordController.text.isNotEmpty) || (_selectedSentiment != null && _selectedSentiment!.isNotEmpty)) {
      final filtered = await repo.fetchAnswersFiltered(
        keyword: _keywordController.text.isNotEmpty ? _keywordController.text : null,
        sentimentLabel: _selectedSentiment,
      );

      // group by day
      final grouped = <DateTime, List<Answer>>{};
      for (final a in filtered) {
        final day = DateTime(a.createdAt.year, a.createdAt.month, a.createdAt.day);
        grouped.putIfAbsent(day, () => []).add(a);
      }
      // order descending
      final ordered = <DateTime, List<Answer>>{};
      final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
      for (final d in days) {
        ordered[d] = grouped[d]!;
      }
      return ordered;
    }

    return repo.fetchAnswersGroupedByDay();
  }
}

 

// Simple fade-in list item used for subtle staggered animations
class FadeInListItem extends StatefulWidget {
  final Widget child;
  final int index;
  const FadeInListItem({super.key, required this.child, required this.index});

  @override
  State<FadeInListItem> createState() => _FadeInListItemState();
}

class _FadeInListItemState extends State<FadeInListItem> with SingleTickerProviderStateMixin {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Staggered appearance
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _visible ? 1.0 : 0.0,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.03),
        duration: const Duration(milliseconds: 300),
        child: widget.child,
      ),
    );
  }
}

// Page showing answers for a single day
class DayDetailPage extends StatelessWidget {
  final DateTime date;
  final List<Answer> answers;

  const DayDetailPage({super.key, required this.date, required this.answers});

  String _emojiForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('positive')) return '😊';
    if (l.contains('negative') || l.contains('sad') || l.contains('frustr')) return '😔';
    return '😐';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMMd().format(date))),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: answers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final a = answers[index];
          final sentiment = a.sentiment;
          final emoji = sentiment != null ? _emojiForLabel(sentiment.label) : '😐';

          return Card(
            child: ListTile(
              title: Text(a.text, maxLines: 3, overflow: TextOverflow.ellipsis),
              subtitle: sentiment != null
                  ? Text('${sentiment.label} • ${sentiment.score.toStringAsFixed(2)}')
                  : null,
              leading: CircleAvatar(child: Text(emoji)),
              onTap: () => showDialog<void>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Answer'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.text),
                      const SizedBox(height: 12),
                      if (a.keywords.isNotEmpty) ...[
                        const Text('Keywords:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, children: a.keywords.map((k) => Chip(label: Text(k))).toList()),
                      ]
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}