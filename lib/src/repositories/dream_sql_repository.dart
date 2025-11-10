import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

//import 'dream_sql_repository_native.dart'
 //   if (dart.library.html) 'dream_sql_repository_web.dart';

import 'dream_sql_repository_web.dart';


part 'dream_sql_repository.g.dart';

/// ─────────────────────────────────────────────────────────────
/// TABLE DEFINITION
/// ─────────────────────────────────────────────────────────────
@DataClassName('DreamEntryData')
class DreamEntries extends Table {
  TextColumn get id => text()(); // UUID primary key
  TextColumn get title => text().nullable()();
  TextColumn get textContent => text()(); // renamed to avoid conflict with Table.text()
  TextColumn get originalText => text().nullable()(); // pre-edited text
  BoolColumn get edited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastEditedAt => dateTime().nullable()();
  TextColumn get moodTag => text().nullable()();
  TextColumn get syncState =>
      text().withDefault(const Constant('pending'))(); // pending/synced/conflict/error
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ─────────────────────────────────────────────────────────────
/// DATABASE REPOSITORY
/// ─────────────────────────────────────────────────────────────
@DriftDatabase(tables: [DreamEntries])
class DreamSqlRepository extends _$DreamSqlRepository {
  DreamSqlRepository() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Returns all stored dreams.
  Future<List<DreamEntryData>> getAllDreams() => select(dreamEntries).get();

  /// Watches all dreams as a stream (useful for live UIs).
  Stream<List<DreamEntryData>> watchAllDreams() => select(dreamEntries).watch();

  /// Get a single dream by ID.
  Future<DreamEntryData?> getDreamById(String id) =>
      (select(dreamEntries)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Insert a new dream.
  Future<void> insertDream({
    required String text,
    String? title,
    String? moodTag,
    String? id,
  }) async {
    final entry = DreamEntriesCompanion.insert(
      id: id ?? const Uuid().v4(),
      textContent: text,
      title: Value(title),
      moodTag: Value(moodTag),
      createdAt: DateTime.now(),
      edited: const Value(false),
      syncState: const Value('pending'),
      version: const Value(1),
    );
    await into(dreamEntries).insert(entry);
  }

  /// Update a dream's text.
  Future<void> updateDreamText(String id, String newText) async {
    await (update(dreamEntries)..where((tbl) => tbl.id.equals(id))).write(
      DreamEntriesCompanion(
        textContent: Value(newText),
        edited: const Value(true),
        lastEditedAt: Value(DateTime.now()),
        version: const Value(2),
        syncState: const Value('pending'),
      ),
    );
  }

  /// Mark a dream as synced after remote upload.
  Future<void> markSynced(String id) async {
    await (update(dreamEntries)..where((tbl) => tbl.id.equals(id))).write(
      const DreamEntriesCompanion(syncState: Value('synced')),
    );
  }

  /// Update sync state (used for error/conflict handling)
  Future<void> updateSyncState(String id, String state) async {
    await (update(dreamEntries)..where((t) => t.id.equals(id)))
        .write(DreamEntriesCompanion(syncState: Value(state)));
  }

  /// Retrieve dreams by sync state (used for retries)
  Future<List<DreamEntryData>> getDreamsBySyncState(String state) async {
    return (select(dreamEntries)..where((t) => t.syncState.equals(state))).get();
  }

  /// Retry failed syncs.
  Future<void> retryFailedSyncs(
    Future<void> Function(DreamEntryData entry) syncCallback,
  ) async {
    final failed = await getDreamsBySyncState('error');
    for (final dream in failed) {
      try {
        await syncCallback(dream);
        await markSynced(dream.id);
      } catch (e) {
        print('⚠️ Retry failed for ${dream.id}: $e');
      }
    }
  }

  /// Delete a dream by ID.
  Future<void> deleteDream(String id) async {
    await (delete(dreamEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Clear all local dreams.
  Future<void> clearAll() async => delete(dreamEntries).go();
}

/// ─────────────────────────────────────────────────────────────
/// DATABASE CONNECTION INITIALIZER
/// ─────────────────────────────────────────────────────────────
LazyDatabase _openConnection() {
    return openWebConnection();
  }