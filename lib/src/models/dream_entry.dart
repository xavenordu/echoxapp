import 'package:cloud_firestore/cloud_firestore.dart';

class DreamEntry {
  final String id;
  final String? title;
  final String text;
  final String? originalText;
  final bool edited;
  final DateTime createdAt;
  final DateTime? lastEditedAt;
  final String? moodTag;
  final String syncState; // 'pending', 'synced', 'conflict'
  final int version;

  DreamEntry({
    required this.id,
    this.title,
    required this.text,
    this.originalText,
    this.edited = false,
    DateTime? createdAt,
    this.lastEditedAt,
    this.moodTag,
    this.syncState = 'pending',
    this.version = 1,
  }) : createdAt = createdAt ?? DateTime.now();

  // --- Firestore serialization helpers ---

  factory DreamEntry.fromMap(Map<String, dynamic> map, String id) {
    Timestamp? createdTs = map['createdAt'];
    Timestamp? editedTs = map['lastEditedAt'];

    return DreamEntry(
      id: id,
      title: map['title'] as String?,
      text: map['text'] as String? ?? map['body'] as String? ?? '',
      originalText: map['originalText'] as String?,
      edited: map['edited'] as bool? ?? false,
      createdAt: createdTs?.toDate() ?? DateTime.now(),
      lastEditedAt: editedTs?.toDate(),
      moodTag: map['moodTag'] as String?,
      syncState: map['syncState'] as String? ?? 'pending',
      version: map['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'text': text,
      'originalText': originalText,
      'edited': edited,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastEditedAt':
          lastEditedAt != null ? Timestamp.fromDate(lastEditedAt!) : null,
      'moodTag': moodTag,
      'syncState': syncState,
      'version': version,
    };
  }

  DreamEntry copyWith({
    String? id,
    String? title,
    String? text,
    String? originalText,
    bool? edited,
    DateTime? createdAt,
    DateTime? lastEditedAt,
    String? moodTag,
    String? syncState,
    int? version,
  }) {
    return DreamEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      originalText: originalText ?? this.originalText,
      edited: edited ?? this.edited,
      createdAt: createdAt ?? this.createdAt,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      moodTag: moodTag ?? this.moodTag,
      syncState: syncState ?? this.syncState,
      version: version ?? this.version,
    );
  }
}
