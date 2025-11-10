import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:echoxapp/src/models/dream_entry.dart';
import 'package:echoxapp/src/repositories/dream_sql_repository.dart';
import 'package:echoxapp/src/repositories/dream_firestore_repository.dart';

/// Unified repository that coordinates between
/// local Drift DB and remote Firestore storage.
class DreamRepository {
  final DreamSqlRepository localDb;
  final DreamFirestoreRepository remoteDb;

  DreamRepository({
    required this.localDb,
    required this.remoteDb,
  });

  final _uuid = const Uuid();

  /// Fetch all dreams stored locally.
  Future<List<DreamEntry>> fetchLocalDreams() async {
    final entries = await localDb.getAllDreams();
    return entries.map(_mapLocalToModel).toList();
  }

  /// Watch for real-time local DB updates.
  Stream<List<DreamEntry>> watchLocalDreams() {
    return localDb.watchAllDreams().map(
          (rows) => rows.map(_mapLocalToModel).toList(),
        );
  }

  /// Add a new dream (offline-first).
  Future<void> addDream(String text, {String? title, String? moodTag}) async {
    final entry = DreamEntry(
      id: _uuid.v4(),
      title: title,
      text: text,
      moodTag: moodTag,
      syncState: 'pending',
      createdAt: DateTime.now(),
    );

    // 1️⃣ Always insert locally first (offline-first)
    await localDb.insertDream(
      id: entry.id, // ✅ pass through the same UUID
      text: entry.text,
      title: entry.title,
      moodTag: entry.moodTag,
    );

    // 2️⃣ Try to sync with Firestore
    try {
      await remoteDb.addOrUpdateDream(entry);
      await localDb.markSynced(entry.id); // only mark synced if Firestore succeeded
    } catch (e, stack) {
      // 3️⃣ On failure, mark entry as 'error' for retry later
      print('⚠️ Failed to sync dream ${entry.id}: $e');
      print(stack);
      await localDb.updateSyncState(entry.id, 'error');
    }
  }

  /// Synchronize local DB with Firestore content.
  /// Inserts only new remote entries (avoids duplicates).
  Future<void> syncFromCloud() async {
    final remoteDreams = await remoteDb.fetchDreams();
    for (var entry in remoteDreams) {
      final existing = await localDb.getDreamById(entry.id);
      if (existing == null) {
        await localDb.insertDream(
          id: entry.id,
          text: entry.text,
          title: entry.title,
          moodTag: entry.moodTag,
        );
      } else {
        // Optionally update local version if remote is newer
      }
    }
  }

  /// ✅ Retry all previously failed syncs (e.g., after reconnect)
  Future<void> retryFailedSyncs() async {
    await localDb.retryFailedSyncs((entry) async {
      final model = _mapLocalToModel(entry);
      await remoteDb.addOrUpdateDream(model);
    });
  }

  /// Internal mapper: Drift row → app model.
  DreamEntry _mapLocalToModel(DreamEntryData e) {
    return DreamEntry(
      id: e.id,
      title: e.title ?? '',
      text: e.textContent,
      originalText: e.originalText ?? '',
      edited: e.edited,
      createdAt: e.createdAt,
      lastEditedAt: e.lastEditedAt,
      moodTag: e.moodTag ?? '',
      syncState: e.syncState,
      version: e.version,
    );
  }
}
