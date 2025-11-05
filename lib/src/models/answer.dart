import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'sentiment.dart';

part 'answer.g.dart';

@HiveType(typeId: 2)
class Answer {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String questionId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final Sentiment? sentiment;

  @HiveField(5)
  final List<String> keywords;

  @HiveField(6)
  final bool? wasHelpful;

  Answer({
    String? id,
    required this.questionId,
    required this.text,
    DateTime? createdAt,
    this.sentiment,
    List<String>? keywords,
    this.wasHelpful,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        keywords = keywords ?? [];

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String?,
      questionId: json['question_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sentiment: json['sentiment'] != null
          ? Sentiment.fromJson(json['sentiment'] as Map<String, dynamic>)
          : null,
      keywords: List<String>.from(json['keywords'] as List? ?? []),
      wasHelpful: json['was_helpful'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'sentiment': sentiment?.toJson(),
      'keywords': keywords,
      'was_helpful': wasHelpful,
    };
  }

  Answer copyWith({
    String? id,
    String? questionId,
    String? text,
    DateTime? createdAt,
    Sentiment? sentiment,
    List<String>? keywords,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      sentiment: sentiment ?? this.sentiment,
      keywords: keywords ?? this.keywords,
    );
  }
}