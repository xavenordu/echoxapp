import 'package:logging/logging.dart';
import 'package:echoxapp/src/utils/stop_words.dart';

class TextAnalysisService {
  final _logger = Logger('TextAnalysisService');

  /// Common positive sentiment word patterns
  static final _positivePatterns = {
    RegExp(r'\b(good|great|excellent|amazing|awesome)\b'),
    RegExp(r'\b(wonderful|fantastic|terrific|outstanding)\b'),
    RegExp(r'\b(happy|love|best|perfect|better|positive)\b'),
    RegExp(r'\b(helpful|useful|clear|well|success|right)\b'),
    RegExp(r'\b(easy|nice|beautiful|correct|solved)\b'),
    RegExp(r'\b(thank|thanks|appreciated|like|enjoy)\b'),
  };

  /// Common negative sentiment word patterns
  static final _negativePatterns = {
    RegExp(r'\b(bad|poor|terrible|horrible|awful)\b'),
    RegExp(r'\b(wrong|difficult|hard|confusing|confused)\b'),
    RegExp(r'\b(unclear|problem|issue|error|fail)\b'),
    RegExp(r'\b(worse|worst|negative|unhappy|hate)\b'),
    RegExp(r'\b(dislike|sorry|frustrated|disappointing)\b'),
    RegExp(r'\b(useless|impossible|struggle|trouble)\b'),
  };

  /// Emotional context patterns
  static final _emotionalPatterns = {
    'nostalgic': RegExp(r'\b(miss|remember|recalled?|thought of)\b'),
    'calm': RegExp(r'\b(calm|peaceful|quiet|still)\b'),
    'forward-looking': RegExp(r'\b(hope|future|will|going to)\b'),
  };

  /// Analyzes text and returns a sentiment score between -1.0 and 1.0
  /// along with a human-readable label
  Map<String, dynamic> analyzeSentiment(String text) {
    try {
      final lowerText = text.toLowerCase();
      int positiveCount = 0;
      int negativeCount = 0;

      // Count positive and negative patterns
      for (final pattern in _positivePatterns) {
        positiveCount += pattern.allMatches(lowerText).length;
      }
      
      for (final pattern in _negativePatterns) {
        negativeCount += pattern.allMatches(lowerText).length;
      }

      // Calculate sentiment score
      double score = 0.0;
      if (positiveCount > 0 || negativeCount > 0) {
        score = (positiveCount - negativeCount) / (positiveCount + negativeCount);
      }

      // Determine base label
      String label;
      if (score > 0.5) {
        label = 'very positive';
      } else if (score > 0.2) {
        label = 'positive';
      } else if (score > -0.2) {
        label = 'neutral';
      } else if (score > -0.5) {
        label = 'negative';
      } else {
        label = 'very negative';
      }

      // Add emotional context if present
      for (final entry in _emotionalPatterns.entries) {
        if (entry.value.hasMatch(lowerText)) {
          label = entry.key;
          break;
        }
      }

      return {
        'score': score,
        'label': label,
      };
    } catch (e) {
      _logger.warning('Error analyzing sentiment: $e');
      return {
        'score': 0.0,
        'label': 'neutral',
      };
    }
  }

  /// Extracts important keywords from text by removing stop words
  /// and selecting words that appear frequently
  List<String> extractKeywords(String text) {
    try {
      // Convert to lowercase and split into words
      final words = text.toLowerCase().split(RegExp(r'\W+'))
        ..removeWhere((word) => word.isEmpty || word.length < 3);

      // Remove stop words using our custom list
      final keywords = words.where((word) => !stopWords.contains(word)).toList();

      // Count word frequencies
      final wordFreq = <String, int>{};
      for (final word in keywords) {
        wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      }

      // Sort by frequency and length
      final sortedWords = wordFreq.entries.toList()
        ..sort((a, b) {
          final freqDiff = b.value.compareTo(a.value);
          return freqDiff != 0 ? freqDiff : b.key.length.compareTo(a.key.length);
        });

      // Take top 5 keywords
      return sortedWords.take(5).map((e) => e.key).toList();
    } catch (e) {
      _logger.warning('Error extracting keywords: $e');
      return [];
    }
  }
}