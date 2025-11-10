import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart' as wasm;

/// Opens a web-compatible database connection using IndexedDB
LazyDatabase openWebConnection() {
  return LazyDatabase(() async {
    final sqlite3 = await wasm.WasmSqlite3.loadFromUrl(
      Uri.parse('${Uri.base.origin}/sqlite3.wasm'),
    );

    return WasmDatabase(
      sqlite3: sqlite3,
      path: 'dreams.sqlite', // persistent in-browser database
    );
  });
}
