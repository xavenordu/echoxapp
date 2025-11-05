import 'package:hive/hive.dart';

part 'sentiment.g.dart';

@HiveType(typeId: 3)
class Sentiment {
  @HiveField(0)
  final double score;

  @HiveField(1)
  final String label;

  const Sentiment({
    required this.score,
    required this.label,
  });

  factory Sentiment.fromJson(Map<String, dynamic> json) {
    return Sentiment(
      score: json['score'] as double,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'label': label,
    };
  }
}