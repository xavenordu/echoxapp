import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:echoxapp/src/models/question.dart';
import 'package:echoxapp/src/models/answer.dart';
import 'package:echoxapp/src/models/sentiment.dart';
import 'package:echoxapp/src/services/text_analysis_service.dart';
import 'package:echoxapp/src/services/ai_mirror_service.dart';
import 'package:echoxapp/src/models/mirror_response.dart';

class QuestionRepository {
  final _logger = Logger('QuestionRepository');
  static const _boxName = 'questions';
  static const _answersBoxName = 'answers';
  static const _lastQuestionDateKey = 'last_question_date';
  static const _useCloudKey = 'use_cloud_storage';
  static const _mirrorModeKey = 'mirror_mode_enabled';
  
  final SupabaseClient? supabase;
  final SharedPreferences? preferences;
  final TextAnalysisService _textAnalysisService = TextAnalysisService();
  final AiMirrorService _aiMirrorService = AiMirrorService();
  
  QuestionRepository({this.supabase, this.preferences});
  
  // Singleton instance
  static QuestionRepository? _instance;
  static Future<QuestionRepository> get instance async {
    if (_instance != null) return _instance!;
    
    final prefs = await SharedPreferences.getInstance();
    final supabase = Supabase.instance.client;
    
    _instance = QuestionRepository(
      supabase: supabase,
      preferences: prefs,
    );
    return _instance!;
  }
  
  bool get useCloud => preferences?.getBool(_useCloudKey) ?? false;
  set useCloud(bool value) => preferences?.setBool(_useCloudKey, value);

  bool get mirrorModeEnabled => preferences?.getBool(_mirrorModeKey) ?? false;
  set mirrorModeEnabled(bool value) => preferences?.setBool(_mirrorModeKey, value);

  Future<int> getAnswerCount() async {
    final box = await Hive.openBox<Answer>(_answersBoxName);
    return box.length;
  }
  
  // Singleton instance for easy provider access
  // Note: Removed old singleton in favor of async factory above

  /// Loads questions from local JSON file
  Future<List<Question>> loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/questions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> questionsJson = jsonData['questions'];
      
      return questionsJson
          .map((q) => Question.fromJson(q))
          .toList();
    } catch (e, st) {
      _logger.warning('Error loading questions', e, st);
      return [];
    }
  }

  /// Gets today's content - either a question or an AI mirror response
  Future<dynamic> getTodayContent() async {
    // Check if we should be in mirror mode
    final answerCount = await getAnswerCount();
    if (answerCount >= 5) {
      mirrorModeEnabled = true;
      // Generate mirror response from recent answers
      final recentAnswers = await fetchAnswers();
      final lastFiveAnswers = recentAnswers.take(5).toList();
      
      final response = _aiMirrorService.generateReply(lastFiveAnswers);
      final basedOn = _aiMirrorService.pickRecentPhrase(lastFiveAnswers);
      
      return MirrorResponse(
        text: response,
        basedOnPhrase: basedOn,
      );
    }
    
    // Not in mirror mode - get regular question
    List<Question> questions = [];
    
    // Try to get questions from Supabase first if cloud is enabled
    if (useCloud && supabase != null) {
      try {
        final response = await supabase!
            .from('questions')
            .select()
            .gte('date', DateTime.now().toIso8601String())
            .order('date')
            .limit(1)
            .maybeSingle();
            
        if (response != null) {
          return Question.fromJson(response);
        }
      } catch (e, st) {
        _logger.warning('Error fetching from Supabase', e, st);
        // Fall through to local JSON
      }
    }
    
    // Fall back to local JSON if needed
    questions = await loadQuestions();
    if (questions.isEmpty) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // If this is a new day, update last-question metadata and return a question
    try {
      final box = await Hive.openBox(_boxName);
      final String? lastDateRaw = box.get(_lastQuestionDateKey) as String?;
      if (lastDateRaw == null) {
        // first time, set last date and return first question
        await updateLastQuestionDate(today);
        return questions.first;
      }

      final lastDate = DateTime.tryParse(lastDateRaw);
      final lastDay = lastDate != null ? DateTime(lastDate.year, lastDate.month, lastDate.day) : null;

      if (lastDay == null || !today.isAtSameMomentAs(lastDay)) {
        // new day: update and (for now) return first question
        await updateLastQuestionDate(today);
        return questions.first;
      }

      // same day: if we stored a chosen question index in the box, try to use it
      final int? idx = box.get('today_question_index') as int?;
      if (idx != null && idx >= 0 && idx < questions.length) {
        return questions[idx];
      }

      // fallback
      return questions.first;
    } catch (e, st) {
      // On error, fall back to first question
      _logger.warning('Error in getTodayQuestion', e, st);
      return questions.first;
    }
  }

  /// Saves an answer for the current question
  Future<void> saveAnswer(String questionId, String answerText) async {
    // Analyze the text
    final sentimentResult = _textAnalysisService.analyzeSentiment(answerText);
    final keywords = _textAnalysisService.extractKeywords(answerText);

    final answer = Answer(
      questionId: questionId,
      text: answerText,
      sentiment: Sentiment(
        score: sentimentResult['score'] as double,
        label: sentimentResult['label'] as String,
      ),
      keywords: keywords,
    );

    // Save locally first
    final box = await Hive.openBox<Answer>(_answersBoxName);
    await box.add(answer);

    // If cloud sync is enabled and we have Supabase client, save there too
    if (useCloud && supabase != null) {
      try {
        final userId = supabase!.auth.currentUser?.id;
        if (userId != null) {
          await supabase!.from('answers').insert({
            'id': answer.id,
            'question_id': answer.questionId,
            'user_id': userId,
            'text': answer.text,
            'created_at': answer.createdAt.toIso8601String(),
            'sentiment': answer.sentiment?.toJson(),
            'keywords': answer.keywords,
          });
        }
      } catch (e, st) {
        _logger.warning('Error saving answer to Supabase', e, st);
        // Continue since we already saved locally
      }
    }
  }

  /// Gets all answers with their sentiment analysis and keywords
  Future<List<Answer>> fetchAnswers() async {
    final box = await Hive.openBox<Answer>(_answersBoxName);
    final answers = box.values.toList();

    // If cloud sync is enabled, merge with cloud data
    if (useCloud && supabase != null) {
      try {
        final response = await supabase!
            .from('answers')
            .select()
            .order('created_at', ascending: false);

        final cloudAnswers = response.map((json) => Answer.fromJson(json)).toList();
        
        // Merge cloud and local answers, preferring cloud versions
        final mergedAnswers = <Answer>[];
        final seenIds = <String>{};

        // Add cloud answers first
        for (final answer in cloudAnswers) {
          mergedAnswers.add(answer);
          seenIds.add(answer.id);
        }

        // Add local answers that aren't in cloud
        for (final answer in answers) {
          if (!seenIds.contains(answer.id)) {
            mergedAnswers.add(answer);
          }
        }

        return mergedAnswers;
      } catch (e, st) {
        _logger.warning('Error fetching answers from Supabase', e, st);
        // Fall back to local answers
      }
    }

    return answers;
  }

  /// Returns raw answer texts for a given question id, ordered by creation time
  /// (oldest first). This matches the shape expected by some UI consumers.
  Future<List<String>> getAnswers(String questionId) async {
    final all = await fetchAnswers();
    final filtered = all.where((a) => a.questionId == questionId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered.map((a) => a.text).toList();
  }

  /// Returns answers grouped by day (date-only keys). The returned map
  /// preserves iteration order: most recent day first when [descending] is true.
  Future<Map<DateTime, List<Answer>>> fetchAnswersGroupedByDay({bool descending = true}) async {
    final answers = await fetchAnswers();

    // Sort by createdAt
    answers.sort((a, b) => descending ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt));

    final grouped = <DateTime, List<Answer>>{};

    for (final answer in answers) {
      final day = DateTime(answer.createdAt.year, answer.createdAt.month, answer.createdAt.day);
      grouped.putIfAbsent(day, () => []).add(answer);
    }

    // If descending, ensure the map iteration order starts with newest day
    if (descending) {
      final ordered = <DateTime, List<Answer>>{};
      final days = grouped.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      for (final d in days) {
        ordered[d] = grouped[d]!;
      }
      return ordered;
    }

    return grouped;
  }

  /// Fetch answers filtered by optional keyword and/or sentiment label.
  ///
  /// - [keyword]: case-insensitive substring search across `text` and `keywords`.
  /// - [sentimentLabel]: matches `answer.sentiment?.label` (case-insensitive).
  Future<List<Answer>> fetchAnswersFiltered({String? keyword, String? sentimentLabel}) async {
    var answers = await fetchAnswers();

    if (keyword != null && keyword.trim().isNotEmpty) {
      final q = keyword.toLowerCase();
      answers = answers.where((a) {
        final inText = a.text.toLowerCase().contains(q);
        final inKeywords = a.keywords.any((k) => k.toLowerCase().contains(q));
        return inText || inKeywords;
      }).toList();
    }

    if (sentimentLabel != null && sentimentLabel.trim().isNotEmpty) {
      final label = sentimentLabel.toLowerCase();
      answers = answers.where((a) => a.sentiment?.label.toLowerCase() == label).toList();
    }

    // Return newest-first by default
    answers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return answers;
  }

  /// Updates the last question date
  Future<void> updateLastQuestionDate(DateTime date) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_lastQuestionDateKey, date.toIso8601String());
  }

  /// Checks if we need a new question (different day)
  Future<bool> needsNewQuestion() async {
    final box = await Hive.openBox(_boxName);
    final String? raw = box.get(_lastQuestionDateKey) as String?;
    if (raw == null) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    return !today.isAtSameMomentAs(lastDay);
  }
}