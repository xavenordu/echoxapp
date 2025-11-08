import 'package:echoxapp/src/models/dream_entry.dart';
import 'package:echoxapp/src/repositories/dream_sql_repository.dart';
import 'package:echoxapp/src/repositories/dream_firestore_repository.dart';
import 'package:uuid/uuid.dart';

class DreamRepository {
  final DreamDatabase localDb;
  final DreamFirestoreRepository remoteDb;

  DreamRepository({required this.localDb, required this.remoteDb});

  // Generate unique ID
  final _uuid = const Uuid();

  Future<List<DreamEntry>> fetchLocalDreams() async {
    final entries = await localDb.getAllDreams();
    return entries.map((e) => DreamEntry(
      id: e.id,
      title: e.title,
      text: e.text,
      originalText: e.originalText,
      edited: e.edited,
      createdAt: e.createdAt,
      lastEditedAt: e.lastEditedAt,
      moodTag: e.moodTag,
      syncState: e.syncState,
      version: e.version,
    )).toList();
  }

  Stream<List<DreamEntry>> watchLocalDreams() {
    return localDb.watchAllDreams().map((rows) => rows.map((e) => DreamEntry(
      id: e.id,
      title: e.title,
      text: e.text,
      originalText: e.originalText,
      edited: e.edited,
      createdAt: e.createdAt,
      lastEditedAt: e.lastEditedAt,
      moodTag: e.moodTag,
      syncState: e.syncState,
      version: e.version,
    )).toList());
  }

  Future<void> addDream(String text, {String? title, String? moodTag}) async {
    final entry = DreamEntry(
      id: _uuid.v4(),
      title: title,
      text: text,
      moodTag: moodTag,
      syncState: 'pending',
      createdAt: DateTime.now(),
    );

    // save local
    await localDb.insertDream(DreamEntriesCompanion.insert(
      id: entry.id,
      title: Value(entry.title),
      text: entry.text,
      originalText: Value(entry.originalText),
      edited: Value(entry.edited),
      createdAt: entry.createdAt,
      lastEditedAt: Value(entry.lastEditedAt),
      moodTag: Value(entry.moodTag),
      syncState: entry.syncState,
      version: entry.version,
    ));

    // sync to Firestore
    await remoteDb.addOrUpdateDream(entry);
  }

  Future<void> syncFromCloud() async {
    final remote = await remoteDb.fetchDreams();
    for (var entry in remote) {
      await localDb.insertDream(DreamEntriesCompanion.insert(
        id: entry.id,
        title: Value(entry.title),
        text: entry.text,
        originalText: Value(entry.originalText),
        edited: Value(entry.edited),
        createdAt: entry.createdAt,
        lastEditedAt: Value(entry.lastEditedAt),
        moodTag: Value(entry.moodTag),
        syncState: 'synced',
        version: entry.version,
      ));
    }
  }
}
