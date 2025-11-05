import 'package:logging/logging.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/services/mirror_pattern_service.dart';

class AiMirrorService {
  final _patternService = MirrorPatternService();
  static const int _requiredAnswersThreshold = 5;
  final _logger = Logger('AiMirrorService');

  /// Check if we have enough answers to switch to mirror mode
  bool shouldEnterMirrorMode(List<Answer> answers) {
    return answers.length >= _requiredAnswersThreshold;
  }

  /// Pick a meaningful phrase from recent answers
  String pickRecentPhrase(List<Answer> recentAnswers) {
    if (recentAnswers.isEmpty) return '';

    // Sort by sentiment score to find impactful answers
    final sortedAnswers = List.of(recentAnswers)
      ..sort((a, b) => 
          (b.sentiment?.score ?? 0).compareTo(a.sentiment?.score ?? 0));

    // Pick the answer with strongest sentiment
    final meaningfulAnswer = sortedAnswers.first;
    final text = meaningfulAnswer.text;

    // Try to extract a meaningful phrase (first sentence or segment)
    final segments = text.split(RegExp(r'[.!?]'));
    if (segments.isNotEmpty) {
      final phrase = segments.first.trim();
      if (phrase.length > 10) {
        return phrase;
      }
    }

    // Fallback: return first N chars if the text is very long
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  /// Detect sentiment trend in recent answers
  String detectTrend(List<Answer> recentAnswers) {
    if (recentAnswers.isEmpty) return 'neutral';

    // Calculate average sentiment
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

  /// Generate an AI mirror response based on past answers
  String generateReply(List<Answer> recentAnswers) {
    try {
      if (recentAnswers.isEmpty) {
        return "I don't have enough context yet to mirror your thoughts.";
      }

      // Find emotional and temporal patterns
      final emotionalPatterns = _patternService.findEmotionalPatterns(recentAnswers);
      final temporalPatterns = _patternService.findTemporalPatterns(recentAnswers);
      
      // Get base components
      final echo = pickRecentPhrase(recentAnswers);
      final trend = detectTrend(recentAnswers);

      // If we have interesting patterns, use them occasionally
      if (emotionalPatterns.isNotEmpty && recentAnswers.length % 2 == 0) {
        final patternInsight = _patternService.generatePatternInsight(emotionalPatterns);
        if (patternInsight.isNotEmpty) {
          return patternInsight;
        }
      }

      // Use time patterns every third response if available
      if (temporalPatterns['timeOfDay']?.isNotEmpty == true && recentAnswers.length % 3 == 0) {
        final timeInsight = _patternService.generateTimePatternInsight(temporalPatterns);
        if (timeInsight.isNotEmpty) {
          return timeInsight;
        }
      }

      // Fall back to sentiment-based templates
      switch (trend) {
        case 'positive':
          return "You said '$echo'. That seemed to bring you joy - what makes this reflection particularly meaningful to you?";
        
        case 'negative':
          return "You once shared '$echo'. Those words carried weight - how has your perspective evolved since then?";
        
        default: // neutral
          final themes = _patternService.findRecurringThemes(recentAnswers);
          if (themes.isNotEmpty) {
            final theme = themes.first;
            return "You reflected '$echo'. I notice '$theme' comes up in your thoughts - what draws you to this theme?";
          } else {
            return "You reflected '$echo'. What new insights have emerged as you revisit this thought?";
          }
      }

    } catch (e, st) {
      _logger.severe('Error generating mirror reply', e, st);
      return "I'm here to reflect with you. What's on your mind today?";
    }
  }
}