class MirrorResponse {
  final String text;
  final String basedOnPhrase;
  final DateTime createdAt;

  MirrorResponse({
    required this.text,
    required this.basedOnPhrase,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'basedOnPhrase': basedOnPhrase,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MirrorResponse.fromJson(Map<String, dynamic> json) => MirrorResponse(
    text: json['text'] as String,
    basedOnPhrase: json['basedOnPhrase'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}