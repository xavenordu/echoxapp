// lib/src/repositories/reflection_repository.dart
import 'package:hive/hive.dart';

/// A small, Hive-backed repository for quick reflection persistence.
/// Stores plain maps under box 'reflections'. Each value is a Map<String, dynamic>:
/// {
///   'id': <string>,
///   'question': <string>,
///   'answer': <string|null>,
///   'emotion': <string|null>,
///   'createdAt': <iso8601 string>
/// }
class ReflectionRepository {
  final String boxName;

  ReflectionRepository({this.boxName = 'reflections'});

  Future<void> ensureBoxOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  Future<void> saveReflection(Map<String, dynamic> payload) async {
    await ensureBoxOpen();
    final box = Hive.box(boxName);
    final id = payload['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    await box.put(id, payload);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    await ensureBoxOpen();
    final box = Hive.box(boxName);
    final raw = box.get(id);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw);
  }

  Future<List<Map<String, dynamic>>> fetchRecent({int limit = 50}) async {
    await ensureBoxOpen();
    final box = Hive.box(boxName);
    final values = box.values.cast<Map>().toList().reversed; // newest first
    final items = values.map((v) => Map<String, dynamic>.from(v as Map)).take(limit).toList();
    return items;
  }

  Future<void> deleteReflection(String id) async {
    await ensureBoxOpen();
    final box = Hive.box(boxName);
    await box.delete(id);
  }

  Future<void> clearAll() async {
    await ensureBoxOpen();
    final box = Hive.box(boxName);
    await box.clear();
  }
}
