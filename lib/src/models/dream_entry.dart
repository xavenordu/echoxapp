class DreamEntry {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  DreamEntry({
    required this.id,
    required this.title,
    required this.body,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DreamEntry.fromMap(Map<String, dynamic> map, String id) {
    final raw = map['createdAt'];
    DateTime created;
    try {
      if (raw is int) {
        created = DateTime.fromMillisecondsSinceEpoch(raw);
      } else if (raw is String) {
        created = DateTime.tryParse(raw) ?? DateTime.now();
      } else if (raw is Map && raw.containsKey('_seconds')) {
        // Firestore Timestamp serialized form
        final seconds = raw['_seconds'] as int? ?? 0;
        final nanos = raw['_nanoseconds'] as int? ?? 0;
        created = DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanos ~/ 1000000));
      } else {
        created = DateTime.now();
      }
    } catch (_) {
      created = DateTime.now();
    }

    return DreamEntry(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      // store as ISO string for portability; Firestore can also accept Timestamp if desired
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
