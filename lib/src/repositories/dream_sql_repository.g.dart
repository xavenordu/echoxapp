// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_sql_repository.dart';

// ignore_for_file: type=lint
abstract class _$DreamSqlRepository extends GeneratedDatabase {
  _$DreamSqlRepository(QueryExecutor e) : super(e);
  $DreamSqlRepositoryManager get managers => $DreamSqlRepositoryManager(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
}

class $DreamSqlRepositoryManager {
  final _$DreamSqlRepository _db;
  $DreamSqlRepositoryManager(this._db);
}
