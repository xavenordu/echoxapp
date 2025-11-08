import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:echoxapp/src/models/answer.dart';

/// Service for analyzing patterns in user's answers over time
class MirrorPatternService {
  final _logger = Logger('MirrorPatternService');

  // In-memory caches
  Map<String, Map<String, int>> _cachedEmotionalPatterns = {};
  Map<String, Map<String, double>> _cachedTemporalPatterns = {};
  List<String> _cachedThemes = [];

  /// Finds emotional patterns by analyzing keyword occurrences across different sentiments
  Map<String, Map<String, int>> findEmotionalPatterns(List<Answer> answers) {
    final patterns = <String, Map<String, int>>{};

    for (final answer in answers) {
      for (final keyword in answer.keywords) {
        patterns.putIfAbsent(keyword, () => {});
        final sentiment = answer.sentiment?.label ?? 'neutral';
        patterns[keyword]![sentiment] =
            (patterns[keyword]![sentiment] ?? 0) + 1;
      }
    }

    // Filter out single-occurrence patterns
    return Map.fromEntries(
      patterns.entries.where(
        (e) => e.value.values.sum >= 2, // Keyword appears at least twice
      ),
    );
  }

  /// Analyzes temporal patterns in answers (time of day, day of week)
  Map<String, Map<String, double>> findTemporalPatterns(List<Answer> answers) {
    final dayPatterns = <String, List<double>>{
      'morning': [], // 5–11
      'afternoon': [], // 12–17
      'evening': [], // 18–23
      'night': [], // 0–4
    };

    for (final answer in answers) {
      final hour = answer.createdAt.hour;
      final score = answer.sentiment?.score ?? 0;

      if (hour >= 5 && hour <= 11) {
        dayPatterns['morning']!.add(score);
      } else if (hour >= 12 && hour <= 17) {
        dayPatterns['afternoon']!.add(score);
      } else if (hour >= 18 && hour <= 23) {
        dayPatterns['evening']!.add(score);
      } else {
        dayPatterns['night']!.add(score);
      }
    }

    // Calculate average sentiment for each time period
    final averages = <String, Map<String, double>>{
      'timeOfDay': {},
    };

    dayPatterns.forEach((period, scores) {
      if (scores.isNotEmpty) {
        averages['timeOfDay']![period] = scores.average;
      }
    });

    return averages;
  }

  /// Generates an insight message based on emotional patterns
  String generatePatternInsight(Map<String, Map<String, int>> patterns) {
    try {
      if (patterns.isEmpty) return '';

      // Sort patterns by total occurrences
      final sortedPatterns = patterns.entries.toList()
        ..sort((a, b) => b.value.values.sum.compareTo(a.value.values.sum));

      final pattern = sortedPatterns.first;
      final keyword = pattern.key;
      final emotions = pattern.value.entries
          .where((e) => e.value > 0)
          .map((e) => "${e.key} (${e.value}×)")
          .join(" and ");

      return "I notice '$keyword' appears in your $emotions reflections. "
          "What does this connection mean to you?";
    } catch (e, st) {
      _logger.warning('Error generating pattern insight', e, st);
      return '';
    }
  }

  /// Generates an insight based on time-of-day patterns
  String generateTimePatternInsight(Map<String, Map<String, double>> patterns) {
    try {
      final timePatterns = patterns['timeOfDay'];
      if (timePatterns == null || timePatterns.isEmpty) return '';

      // Find the time period with the highest and lowest average sentiment
      final bestTime =
          timePatterns.entries.reduce((a, b) => a.value > b.value ? a : b);
      final challengingTime =
          timePatterns.entries.reduce((a, b) => a.value < b.value ? a : b);

      if (bestTime.value - challengingTime.value > 0.3) {
        return "Your reflections tend to be more positive during the ${bestTime.key}, "
            "while the ${challengingTime.key} brings different emotions. "
            "What makes these times different for you?";
      }

      return "Your emotional patterns seem fairly consistent throughout the day. "
          "How do you maintain this balance?";
    } catch (e, st) {
      _logger.warning('Error generating time pattern insight', e, st);
      return '';
    }
  }

  /// Identifies recurring themes in answers
  List<String> findRecurringThemes(List<Answer> answers) {
    final keywordCounts = <String, int>{};

    // Count all keyword occurrences
    for (final answer in answers) {
      for (final keyword in answer.keywords) {
        keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
      }
    }

    // Find keywords that appear multiple times
    return keywordCounts.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .toList();
  }

  /// 🔄 Refreshes all cached pattern data
  ///
  /// [answers] is optional to allow compatibility with AiMirrorService.
  Future<void> refreshPatternCache([List<Answer>? answers]) async {
    try {
      _logger.info('Refreshing mirror pattern cache...');
      if (answers == null || answers.isEmpty) {
        _logger.info('No answers provided; cache unchanged.');
        return;
      }

      _cachedEmotionalPatterns = findEmotionalPatterns(answers);
      _cachedTemporalPatterns = findTemporalPatterns(answers);
      _cachedThemes = findRecurringThemes(answers);

      _logger.info(
        'Pattern cache refreshed: '
        '${_cachedEmotionalPatterns.length} emotional, '
        '${_cachedTemporalPatterns["timeOfDay"]?.length ?? 0} temporal, '
        '${_cachedThemes.length} themes.',
      );
    } catch (e, st) {
      _logger.severe('Failed to refresh pattern cache', e, st);
    }
  }

  /// Stores learned patterns into the cache (from AiMirrorService training)
  Future<void> storeLearnedPatterns(Map<String, dynamic> learnedData) async {
    try {
      final emotional =
          (learnedData['emotional'] as Map<String, Map<String, int>>?) ?? {};
      final temporal =
          (learnedData['temporal'] as Map<String, Map<String, double>>?) ?? {};

      if (emotional.isNotEmpty) {
        _cachedEmotionalPatterns.addAll(emotional);
      }
      if (temporal.isNotEmpty) {
        _cachedTemporalPatterns.addAll(temporal);
      }

      _logger.info(
        'Stored learned patterns: ${emotional.length} emotional, '
        '${temporal.length} temporal entries.',
      );
    } catch (e, st) {
      _logger.severe('Error storing learned patterns', e, st);
    }
  }

  /// Accessors for cached data
  Map<String, Map<String, int>> get emotionalPatterns =>
      _cachedEmotionalPatterns;
  Map<String, Map<String, double>> get temporalPatterns =>
      _cachedTemporalPatterns;
  List<String> get recurringThemes => _cachedThemes;
}
