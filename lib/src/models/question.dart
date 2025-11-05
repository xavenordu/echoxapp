import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 1)
class Question {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final DateTime date;

  const Question({
    required this.id,
    required this.text,
    required this.category,
    required this.date,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  Question copyWith({
    String? id,
    String? text,
    String? category,
    DateTime? date,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}