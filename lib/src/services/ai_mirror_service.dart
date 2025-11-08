import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/services/mirror_pattern_service.dart';

class AiMirrorService {
  final _patternService = MirrorPatternService();
  static const int _requiredAnswersThreshold = 5;
  final _logger = Logger('AiMirrorService');

  bool useCloud = false; // toggle manually or from settings
  final List<String> _recentEchoes = [];

  String? get _apiKey => dotenv.env['OPENAI_API_KEY'];

  /// Checks if cloud AI is configured
  bool get hasCloudAI => _apiKey != null && _apiKey!.isNotEmpty;

  /// Check if we have enough answers to switch to mirror mode
  bool shouldEnterMirrorMode(List<Answer> answers) =>
      answers.length >= _requiredAnswersThreshold;

  /// Pick a meaningful phrase from recent answers
  String pickRecentPhrase(List<Answer> recentAnswers) {
    if (recentAnswers.isEmpty) return '';

    final sortedAnswers = List.of(recentAnswers)
      ..sort((a, b) =>
          (b.sentiment?.score ?? 0).compareTo(a.sentiment?.score ?? 0));

    final meaningfulAnswer = sortedAnswers.first;
    final text = meaningfulAnswer.text;

    final segments = text.split(RegExp(r'[.!?]'));
    if (segments.isNotEmpty) {
      final phrase = segments.first.trim();
      if (phrase.length > 10) return phrase;
    }

    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  /// Detect sentiment trend
  String detectTrend(List<Answer> recentAnswers) {
    if (recentAnswers.isEmpty) return 'neutral';

    double total = 0;
    int count = 0;

    for (final answer in recentAnswers) {
      if (answer.sentiment != null) {
        total += answer.sentiment!.score;
        count++;
      }
    }

    if (count == 0) return 'neutral';
    final avg = total / count;
    if (avg > 0.3) return 'positive';
    if (avg < -0.3) return 'negative';
    return 'neutral';
  }

  /// Generate local mirror reflection
  String _localReflection(List<Answer> recentAnswers) {
    if (recentAnswers.isEmpty) {
      return "I don't have enough context yet to mirror your thoughts.";
    }

    final emotionalPatterns = _patternService.findEmotionalPatterns(recentAnswers);
    final temporalPatterns = _patternService.findTemporalPatterns(recentAnswers);
    final echo = pickRecentPhrase(recentAnswers);
    final trend = detectTrend(recentAnswers);

    if (emotionalPatterns.isNotEmpty && recentAnswers.length % 2 == 0) {
      final patternInsight = _patternService.generatePatternInsight(emotionalPatterns);
      if (patternInsight.isNotEmpty) return patternInsight;
    }

    if (temporalPatterns['timeOfDay']?.isNotEmpty == true && recentAnswers.length % 3 == 0) {
      final timeInsight = _patternService.generateTimePatternInsight(temporalPatterns);
      if (timeInsight.isNotEmpty) return timeInsight;
    }

    switch (trend) {
      case 'positive':
        return "You said '$echo'. That seemed to bring you joy – what makes this reflection particularly meaningful to you?";
      case 'negative':
        return "You once shared '$echo'. Those words carried weight – how has your perspective evolved since then?";
      default:
        final themes = _patternService.findRecurringThemes(recentAnswers);
        if (themes.isNotEmpty) {
          final theme = themes.first;
          return "You reflected '$echo'. I notice '$theme' comes up in your thoughts – what draws you to this theme?";
        } else {
          return "You reflected '$echo'. What new insights have emerged as you revisit this thought?";
        }
    }
  }

  /// Cloud AI call (OpenAI/Gemini style)
  Future<String?> _callCloudAI(String prompt) async {
    if (!hasCloudAI) return null;

    final key = _apiKey!;
    const url = 'https://api.openai.com/v1/chat/completions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4o-mini",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an empathetic reflection assistant named Paradox. Respond gently, with insight but not judgment."
            },
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['choices']?[0]?['message']?['content']?.toString().trim();
        return content;
      } else {
        _logger.warning('Cloud AI request failed: ${response.statusCode}');
        return null;
      }
    } catch (e, st) {
      _logger.severe('Error calling cloud AI', e, st);
      return null;
    }
  }

  /// Unified async mirror reflection
  Future<String> generateMirrorResponse(List<Answer> recentAnswers) async {
    final localReflection = _localReflection(recentAnswers);
    if (!useCloud || !hasCloudAI) return localReflection;

    final contextText = recentAnswers
        .take(5)
        .map((a) => "- ${a.text}")
        .join("\n");

    final prompt =
        "These are my recent reflections:\n$contextText\nBased on these, mirror back a single reflective message or question.";

    final aiResponse = await _callCloudAI(prompt);
    if (aiResponse != null && aiResponse.isNotEmpty) {
      _recentEchoes.add(aiResponse);
      if (_recentEchoes.length > 5) _recentEchoes.removeAt(0);
      return aiResponse;
    }

    // fallback
    return localReflection;
  }

  /// Generate quick echo (phase 1)
  Future<String> generateEcho(List<Answer> recentAnswers) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final phrase = pickRecentPhrase(recentAnswers);
    if (phrase.isEmpty) {
      return "I'm listening. What have you been reflecting on lately?";
    }
    return "You mentioned '$phrase'. Tell me more about that moment.";
  }

  /// Generate follow-up reflection (phase 3)
  Future<String> generateFollowUp(List<Answer> recentAnswers) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final trend = detectTrend(recentAnswers);
    switch (trend) {
      case 'positive':
        return "That sounds uplifting. What helped you hold onto that feeling?";
      case 'negative':
        return "That seems heavy. How are you choosing to move forward from it?";
      default:
        return "You've been thinking deeply. What do you feel this reflection is teaching you?";
    }
  }

  /// Optional pattern training
  Future<void> updateMirrorPatterns(List<Answer> answers) async {
    try {
      _logger.info('Updating mirror patterns...');
      await _patternService.refreshPatternCache();
      final emotional = _patternService.findEmotionalPatterns(answers);
      final temporal = _patternService.findTemporalPatterns(answers);
      _patternService.storeLearnedPatterns({'emotional': emotional, 'temporal': temporal});
    } catch (e, st) {
      _logger.severe('Pattern update failed', e, st);
    }
  }
    /// Legacy alias for backward compatibility
  Future<String> generateReply(List<Answer> recentAnswers) async {
    return await generateMirrorResponse(recentAnswers);
  }

}
