import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'dream_sql_repository.g.dart';

// ─────────────────────────────────────────────────────────────
// TABLE DEFINITION
// ─────────────────────────────────────────────────────────────
@DataClassName('DreamEntryData')
class DreamEntries extends Table {
  TextColumn get id => text()(); // UUID primary key
  TextColumn get title => text().nullable()();
  TextColumn get text => text()(); // dream content
  TextColumn get originalText => text().nullable()(); // pre-edited text
  BoolColumn get edited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastEditedAt => dateTime().nullable()();
  TextColumn get moodTag => text().nullable()();
  TextColumn get syncState =>
      text().withDefault(const Constant('pending'))(); // pending/synced/conflict
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────
// DATABASE REPOSITORY
// ─────────────────────────────────────────────────────────────
@DriftDatabase(tables: [DreamEntries])
class DreamSqlRepository extends _$DreamSqlRepository {
  DreamSqlRepository() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ─────────────────────────────────────────────────────────────
  // CRUD + SYNC HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Returns all stored dreams.
  Future<List<DreamEntryData>> getAllDreams() async {
    return await select(dreamEntries).get();
  }

  /// Watches all dreams as a stream (useful for live UIs).
  Stream<List<DreamEntryData>> watchAllDreams() {
    return select(dreamEntries).watch();
  }

  /// Get a single dream by ID.
  Future<DreamEntryData?> getDreamById(String id) async {
    return await (select(dreamEntries)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert a new dream.
  Future<void> insertDream({
    required String text,
    String? title,
    String? moodTag,
  }) async {
    final id = const Uuid().v4();
    final entry = DreamEntriesCompanion.insert(
      id: id,
      text: text,
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
        text: Value(newText),
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

  /// Delete a dream by ID.
  Future<void> deleteDream(String id) async {
    await (delete(dreamEntries)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Clear all local dreams.
  Future<void> clearAll() async {
    await delete(dreamEntries).go();
  }
}

// ─────────────────────────────────────────────────────────────
// DATABASE CONNECTION INITIALIZER
// ─────────────────────────────────────────────────────────────
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'dreams.sqlite'));
    return NativeDatabase(file);
  });
}
