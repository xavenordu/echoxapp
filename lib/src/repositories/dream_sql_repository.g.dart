// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_sql_repository.dart';

// ignore_for_file: type=lint
class $DreamEntriesTable extends DreamEntries
    with TableInfo<$DreamEntriesTable, DreamEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DreamEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originalTextMeta =
      const VerificationMeta('originalText');
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
      'original_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
      'edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("edited" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastEditedAtMeta =
      const VerificationMeta('lastEditedAt');
  @override
  late final GeneratedColumn<DateTime> lastEditedAt = GeneratedColumn<DateTime>(
      'last_edited_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _moodTagMeta =
      const VerificationMeta('moodTag');
  @override
  late final GeneratedColumn<String> moodTag = GeneratedColumn<String>(
      'mood_tag', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        textContent,
        originalText,
        edited,
        createdAt,
        lastEditedAt,
        moodTag,
        syncState,
        version
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dream_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DreamEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    } else if (isInserting) {
      context.missing(_textContentMeta);
    }
    if (data.containsKey('original_text')) {
      context.handle(
          _originalTextMeta,
          originalText.isAcceptableOrUnknown(
              data['original_text']!, _originalTextMeta));
    }
    if (data.containsKey('edited')) {
      context.handle(_editedMeta,
          edited.isAcceptableOrUnknown(data['edited']!, _editedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_edited_at')) {
      context.handle(
          _lastEditedAtMeta,
          lastEditedAt.isAcceptableOrUnknown(
              data['last_edited_at']!, _lastEditedAtMeta));
    }
    if (data.containsKey('mood_tag')) {
      context.handle(_moodTagMeta,
          moodTag.isAcceptableOrUnknown(data['mood_tag']!, _moodTagMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DreamEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DreamEntryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content'])!,
      originalText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_text']),
      edited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}edited'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastEditedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_edited_at']),
      moodTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mood_tag']),
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $DreamEntriesTable createAlias(String alias) {
    return $DreamEntriesTable(attachedDatabase, alias);
  }
}

class DreamEntryData extends DataClass implements Insertable<DreamEntryData> {
  final String id;
  final String? title;
  final String textContent;
  final String? originalText;
  final bool edited;
  final DateTime createdAt;
  final DateTime? lastEditedAt;
  final String? moodTag;
  final String syncState;
  final int version;
  const DreamEntryData(
      {required this.id,
      this.title,
      required this.textContent,
      this.originalText,
      required this.edited,
      required this.createdAt,
      this.lastEditedAt,
      this.moodTag,
      required this.syncState,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['text_content'] = Variable<String>(textContent);
    if (!nullToAbsent || originalText != null) {
      map['original_text'] = Variable<String>(originalText);
    }
    map['edited'] = Variable<bool>(edited);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastEditedAt != null) {
      map['last_edited_at'] = Variable<DateTime>(lastEditedAt);
    }
    if (!nullToAbsent || moodTag != null) {
      map['mood_tag'] = Variable<String>(moodTag);
    }
    map['sync_state'] = Variable<String>(syncState);
    map['version'] = Variable<int>(version);
    return map;
  }

  DreamEntriesCompanion toCompanion(bool nullToAbsent) {
    return DreamEntriesCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      textContent: Value(textContent),
      originalText: originalText == null && nullToAbsent
          ? const Value.absent()
          : Value(originalText),
      edited: Value(edited),
      createdAt: Value(createdAt),
      lastEditedAt: lastEditedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEditedAt),
      moodTag: moodTag == null && nullToAbsent
          ? const Value.absent()
          : Value(moodTag),
      syncState: Value(syncState),
      version: Value(version),
    );
  }

  factory DreamEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DreamEntryData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      textContent: serializer.fromJson<String>(json['textContent']),
      originalText: serializer.fromJson<String?>(json['originalText']),
      edited: serializer.fromJson<bool>(json['edited']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastEditedAt: serializer.fromJson<DateTime?>(json['lastEditedAt']),
      moodTag: serializer.fromJson<String?>(json['moodTag']),
      syncState: serializer.fromJson<String>(json['syncState']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'textContent': serializer.toJson<String>(textContent),
      'originalText': serializer.toJson<String?>(originalText),
      'edited': serializer.toJson<bool>(edited),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastEditedAt': serializer.toJson<DateTime?>(lastEditedAt),
      'moodTag': serializer.toJson<String?>(moodTag),
      'syncState': serializer.toJson<String>(syncState),
      'version': serializer.toJson<int>(version),
    };
  }

  DreamEntryData copyWith(
          {String? id,
          Value<String?> title = const Value.absent(),
          String? textContent,
          Value<String?> originalText = const Value.absent(),
          bool? edited,
          DateTime? createdAt,
          Value<DateTime?> lastEditedAt = const Value.absent(),
          Value<String?> moodTag = const Value.absent(),
          String? syncState,
          int? version}) =>
      DreamEntryData(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        textContent: textContent ?? this.textContent,
        originalText:
            originalText.present ? originalText.value : this.originalText,
        edited: edited ?? this.edited,
        createdAt: createdAt ?? this.createdAt,
        lastEditedAt:
            lastEditedAt.present ? lastEditedAt.value : this.lastEditedAt,
        moodTag: moodTag.present ? moodTag.value : this.moodTag,
        syncState: syncState ?? this.syncState,
        version: version ?? this.version,
      );
  DreamEntryData copyWithCompanion(DreamEntriesCompanion data) {
    return DreamEntryData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      edited: data.edited.present ? data.edited.value : this.edited,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastEditedAt: data.lastEditedAt.present
          ? data.lastEditedAt.value
          : this.lastEditedAt,
      moodTag: data.moodTag.present ? data.moodTag.value : this.moodTag,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DreamEntryData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('originalText: $originalText, ')
          ..write('edited: $edited, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastEditedAt: $lastEditedAt, ')
          ..write('moodTag: $moodTag, ')
          ..write('syncState: $syncState, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, textContent, originalText, edited,
      createdAt, lastEditedAt, moodTag, syncState, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DreamEntryData &&
          other.id == this.id &&
          other.title == this.title &&
          other.textContent == this.textContent &&
          other.originalText == this.originalText &&
          other.edited == this.edited &&
          other.createdAt == this.createdAt &&
          other.lastEditedAt == this.lastEditedAt &&
          other.moodTag == this.moodTag &&
          other.syncState == this.syncState &&
          other.version == this.version);
}

class DreamEntriesCompanion extends UpdateCompanion<DreamEntryData> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String> textContent;
  final Value<String?> originalText;
  final Value<bool> edited;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastEditedAt;
  final Value<String?> moodTag;
  final Value<String> syncState;
  final Value<int> version;
  final Value<int> rowid;
  const DreamEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.textContent = const Value.absent(),
    this.originalText = const Value.absent(),
    this.edited = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastEditedAt = const Value.absent(),
    this.moodTag = const Value.absent(),
    this.syncState = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DreamEntriesCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String textContent,
    this.originalText = const Value.absent(),
    this.edited = const Value.absent(),
    required DateTime createdAt,
    this.lastEditedAt = const Value.absent(),
    this.moodTag = const Value.absent(),
    this.syncState = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        textContent = Value(textContent),
        createdAt = Value(createdAt);
  static Insertable<DreamEntryData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? textContent,
    Expression<String>? originalText,
    Expression<bool>? edited,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastEditedAt,
    Expression<String>? moodTag,
    Expression<String>? syncState,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (textContent != null) 'text_content': textContent,
      if (originalText != null) 'original_text': originalText,
      if (edited != null) 'edited': edited,
      if (createdAt != null) 'created_at': createdAt,
      if (lastEditedAt != null) 'last_edited_at': lastEditedAt,
      if (moodTag != null) 'mood_tag': moodTag,
      if (syncState != null) 'sync_state': syncState,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DreamEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? title,
      Value<String>? textContent,
      Value<String?>? originalText,
      Value<bool>? edited,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastEditedAt,
      Value<String?>? moodTag,
      Value<String>? syncState,
      Value<int>? version,
      Value<int>? rowid}) {
    return DreamEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      textContent: textContent ?? this.textContent,
      originalText: originalText ?? this.originalText,
      edited: edited ?? this.edited,
      createdAt: createdAt ?? this.createdAt,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      moodTag: moodTag ?? this.moodTag,
      syncState: syncState ?? this.syncState,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastEditedAt.present) {
      map['last_edited_at'] = Variable<DateTime>(lastEditedAt.value);
    }
    if (moodTag.present) {
      map['mood_tag'] = Variable<String>(moodTag.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DreamEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('textContent: $textContent, ')
          ..write('originalText: $originalText, ')
          ..write('edited: $edited, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastEditedAt: $lastEditedAt, ')
          ..write('moodTag: $moodTag, ')
          ..write('syncState: $syncState, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DreamSqlRepository extends GeneratedDatabase {
  _$DreamSqlRepository(QueryExecutor e) : super(e);
  $DreamSqlRepositoryManager get managers => $DreamSqlRepositoryManager(this);
  late final $DreamEntriesTable dreamEntries = $DreamEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dreamEntries];
}

typedef $$DreamEntriesTableCreateCompanionBuilder = DreamEntriesCompanion
    Function({
  required String id,
  Value<String?> title,
  required String textContent,
  Value<String?> originalText,
  Value<bool> edited,
  required DateTime createdAt,
  Value<DateTime?> lastEditedAt,
  Value<String?> moodTag,
  Value<String> syncState,
  Value<int> version,
  Value<int> rowid,
});
typedef $$DreamEntriesTableUpdateCompanionBuilder = DreamEntriesCompanion
    Function({
  Value<String> id,
  Value<String?> title,
  Value<String> textContent,
  Value<String?> originalText,
  Value<bool> edited,
  Value<DateTime> createdAt,
  Value<DateTime?> lastEditedAt,
  Value<String?> moodTag,
  Value<String> syncState,
  Value<int> version,
  Value<int> rowid,
});

class $$DreamEntriesTableFilterComposer
    extends Composer<_$DreamSqlRepository, $DreamEntriesTable> {
  $$DreamEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get edited => $composableBuilder(
      column: $table.edited, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastEditedAt => $composableBuilder(
      column: $table.lastEditedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moodTag => $composableBuilder(
      column: $table.moodTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));
}

class $$DreamEntriesTableOrderingComposer
    extends Composer<_$DreamSqlRepository, $DreamEntriesTable> {
  $$DreamEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalText => $composableBuilder(
      column: $table.originalText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get edited => $composableBuilder(
      column: $table.edited, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastEditedAt => $composableBuilder(
      column: $table.lastEditedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moodTag => $composableBuilder(
      column: $table.moodTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));
}

class $$DreamEntriesTableAnnotationComposer
    extends Composer<_$DreamSqlRepository, $DreamEntriesTable> {
  $$DreamEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
      column: $table.originalText, builder: (column) => column);

  GeneratedColumn<bool> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastEditedAt => $composableBuilder(
      column: $table.lastEditedAt, builder: (column) => column);

  GeneratedColumn<String> get moodTag =>
      $composableBuilder(column: $table.moodTag, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$DreamEntriesTableTableManager extends RootTableManager<
    _$DreamSqlRepository,
    $DreamEntriesTable,
    DreamEntryData,
    $$DreamEntriesTableFilterComposer,
    $$DreamEntriesTableOrderingComposer,
    $$DreamEntriesTableAnnotationComposer,
    $$DreamEntriesTableCreateCompanionBuilder,
    $$DreamEntriesTableUpdateCompanionBuilder,
    (
      DreamEntryData,
      BaseReferences<_$DreamSqlRepository, $DreamEntriesTable, DreamEntryData>
    ),
    DreamEntryData,
    PrefetchHooks Function()> {
  $$DreamEntriesTableTableManager(
      _$DreamSqlRepository db, $DreamEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DreamEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DreamEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DreamEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> textContent = const Value.absent(),
            Value<String?> originalText = const Value.absent(),
            Value<bool> edited = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastEditedAt = const Value.absent(),
            Value<String?> moodTag = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DreamEntriesCompanion(
            id: id,
            title: title,
            textContent: textContent,
            originalText: originalText,
            edited: edited,
            createdAt: createdAt,
            lastEditedAt: lastEditedAt,
            moodTag: moodTag,
            syncState: syncState,
            version: version,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> title = const Value.absent(),
            required String textContent,
            Value<String?> originalText = const Value.absent(),
            Value<bool> edited = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastEditedAt = const Value.absent(),
            Value<String?> moodTag = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DreamEntriesCompanion.insert(
            id: id,
            title: title,
            textContent: textContent,
            originalText: originalText,
            edited: edited,
            createdAt: createdAt,
            lastEditedAt: lastEditedAt,
            moodTag: moodTag,
            syncState: syncState,
            version: version,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DreamEntriesTableProcessedTableManager = ProcessedTableManager<
    _$DreamSqlRepository,
    $DreamEntriesTable,
    DreamEntryData,
    $$DreamEntriesTableFilterComposer,
    $$DreamEntriesTableOrderingComposer,
    $$DreamEntriesTableAnnotationComposer,
    $$DreamEntriesTableCreateCompanionBuilder,
    $$DreamEntriesTableUpdateCompanionBuilder,
    (
      DreamEntryData,
      BaseReferences<_$DreamSqlRepository, $DreamEntriesTable, DreamEntryData>
    ),
    DreamEntryData,
    PrefetchHooks Function()>;

class $DreamSqlRepositoryManager {
  final _$DreamSqlRepository _db;
  $DreamSqlRepositoryManager(this._db);
  $$DreamEntriesTableTableManager get dreamEntries =>
      $$DreamEntriesTableTableManager(_db, _db.dreamEntries);
}
