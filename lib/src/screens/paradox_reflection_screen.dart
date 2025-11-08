// lib/src/screens/paradox_reflection_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:echoxapp/src/services/ai_mirror_service.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/providers.dart';

/// ---------------------------------------------------------------------------
/// Paradox Reflection Screen
/// Features:
/// - Emotion tagging + prompt navigation
/// - Animated per-question card flow
/// - AI "Echo" + optional follow-up generation
/// - Local persistence via Hive + repository integration
/// ---------------------------------------------------------------------------
class ParadoxReflectionScreen extends ConsumerStatefulWidget {
  const ParadoxReflectionScreen({super.key});

  @override
  ConsumerState<ParadoxReflectionScreen> createState() =>
      _ParadoxReflectionScreenState();
}

class _ParadoxReflectionScreenState
    extends ConsumerState<ParadoxReflectionScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final _uuid = const Uuid();

  final List<Map<String, dynamic>> _initialQuestions = [
    {
      'id': null,
      'q': 'What would you erase if no one remembered?',
      'a': null,
      'emotion': null
    },
    {
      'id': null,
      'q': 'When do you feel most yourself?',
      'a': null,
      'emotion': null
    },
    {
      'id': null,
      'q': 'Name a small ritual that grounds you — why does it matter?',
      'a': null,
      'emotion': null
    },
  ];

  late List<Map<String, dynamic>> _qa;
  int _index = 0;
  bool _saving = false;

  String? _currentEcho;
  bool _echoLoading = false;
  String? _lastSavedId;

  late AnimationController _cardAnimController;

  @override
  void initState() {
    super.initState();
    _qa = _initialQuestions.map((q) => {...q, 'id': _uuid.v4()}).toList();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _ensureHiveBox();
  }

  Future<void> _ensureHiveBox() async {
    if (!Hive.isBoxOpen('reflections')) {
      await Hive.openBox('reflections');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  /// Persist reflection entry to Hive and repository.
  Future<void> _persistAnswer(Map<String, dynamic> entry) async {
    try {
      setState(() => _saving = true);

      final payload = {
        'id': entry['id'] ?? _uuid.v4(),
        'question': entry['q'],
        'answer': entry['a'],
        'emotion': entry['emotion'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      final box = Hive.box('reflections');
      await box.put(payload['id'], payload);

      // Save to repository
      final repo = ref.read(reflectionRepositoryProvider);
      await repo.saveReflection(payload);

      setState(() => _lastSavedId = payload['id']);
      HapticFeedback.selectionClick();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('⚠️ Failed to save reflection — retrying later.')),
        );
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  /// Generate AI echo and optional follow-up.
  Future<void> _generateEchoAndFollowUp(String answer, int currentIndex) async {
  setState(() {
    _echoLoading = true;
    _currentEcho = null;
  });

  try {
    final ai = ref.read(aiMirrorServiceProvider) as AiMirrorService;

    // Wrap the user's string in an Answer-like object for compatibility
    final mockAnswer = Answer(
      questionId: _qa[currentIndex]['id'] ?? _uuid.v4(),
      text: answer,
    );
    final recentAnswers = [mockAnswer]; // AiMirrorService expects a list

    String? echo;
    String? followUp;

    try {
      echo = await ai.generateEcho(recentAnswers);
    } catch (_) {
      try {
        echo = await ai.generateMirrorResponse(recentAnswers);
      } catch (_) {
        echo = null;
      }
    }

    try {
      followUp = await ai.generateFollowUp(recentAnswers);
    } catch (_) {
      followUp = null;
    }

    setState(() {
      _currentEcho = echo ?? 'A quiet echo returns to you.';
    });

    if (followUp != null && followUp.trim().isNotEmpty) {
      final newItem = {
        'id': _uuid.v4(),
        'q': followUp.trim(),
        'a': null,
        'emotion': null,
      };
      setState(() => _qa.insert(currentIndex + 1, newItem));
    }
  } catch (e) {
    setState(() {
      _currentEcho = 'Echo unavailable right now.';
    });
  } finally {
    setState(() => _echoLoading = false);
  }
}


  /// Save current answer and trigger echo.
  Future<void> _saveCurrentAnswer() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      HapticFeedback.vibrate();
      return;
    }

    final current = _qa[_index];
    final updated = {...current, 'a': text};
    setState(() {
      _qa[_index] = updated;
      _controller.clear();
    });

    await _persistAnswer(updated);
    await _generateEchoAndFollowUp(text, _index);
  }

  void _goNext() {
    if (_index < _qa.length - 1) {
      setState(() => _index++);
      _cardAnimController.forward(from: 0);
    } else {
      _showCompletionSummary();
    }
  }

  void _goBack() {
    if (_index > 0) {
      setState(() => _index--);
      _cardAnimController.forward(from: 0);
    }
  }

  void _showCompletionSummary() {
    final answeredCount = _qa.where((e) => e['a'] != null).length;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets.add(const EdgeInsets.all(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Today\'s Insight',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (_currentEcho != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(_currentEcho!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              const SizedBox(height: 12),
              Text('Answered $answeredCount of ${_qa.length} prompts.'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmotionRow(int index) {
    const emotions = ['😊', '😐', '😢', '😠', '🤔'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: emotions.map((emo) {
        final selected = _qa[index]['emotion'] == emo;
        return GestureDetector(
          onTap: () {
            setState(() {
              _qa[index]['emotion'] = emo;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : null,
            ),
            child: Text(emo, style: const TextStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, int idx) {
    final answered = item['a'] != null;
    return Card(
      key: ValueKey(item['id']),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Prompt',
                        style: Theme.of(context).textTheme.labelLarge)),
                Text('${idx + 1}/${_qa.length}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(item['q'], style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildEmotionRow(idx),
            const SizedBox(height: 12),
            if (!answered)
              Column(
                children: [
                  TextField(
                    controller: _controller,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Write your reflection here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'Saving...' : 'Save & Echo'),
                    onPressed: _saving ? null : _saveCurrentAnswer,
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your answer:',
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item['a'] ?? ''),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {
                          setState(() {
                            _controller.text = item['a'] ?? '';
                            _qa[idx]['a'] = null;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      if (_currentEcho != null && idx == _index)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Echo',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: _echoLoading
                                    ? const SizedBox(
                                        height: 32,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator()))
                                    : Text(_currentEcho ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final completed = _qa.where((q) => q['a'] != null).length;
    return LinearProgressIndicator(
      value: completed / _qa.length,
      minHeight: 6,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _qa[_index];
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paradox — Daily Reflection'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Open reflection archive',
              onPressed: () async {
                final repo = ref.read(reflectionRepositoryProvider);
                final recent = await repo.fetchRecent(limit: 100);
                // TODO: Navigate to archive view with `recent`
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProgress(),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) {
                    final offset =
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .animate(anim);
                    return SlideTransition(
                        position: offset,
                        child: FadeTransition(opacity: anim, child: child));
                  },
                  child: _buildCard(question, _index),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _index > 0 ? _goBack : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Back'),
                  ),
                  Row(
                    children: [
                      if (_index < _qa.length - 1)
                        TextButton(
                          onPressed: _goNext,
                          child: const Text('Skip'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _index < _qa.length - 1
                            ? _goNext
                            : _showCompletionSummary,
                        icon: const Icon(Icons.chevron_right),
                        label: Text(
                            _index < _qa.length - 1 ? 'Next' : 'Finish'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
