import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:winget_gui/db/publisher_name_table.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/winget_commands.dart';

import 'db_message.dart';
import 'favicon_table.dart';
import 'package_tables.dart';
import 'winget_table.dart';

class PackageDB {
  static final PackageDB instance = PackageDB._();
  static const String dbName = 'favicon_database.db';
  late final FaviconTable favicons;
  late final PublisherNameTable publisherNamesByPackageId;
  late final PublisherNameTable publisherNamesByPublisherId;
  late final WingetDBTable updates, installed, available;
  List<DBTable> get tables => [
        ...faviconTables,
        ...wingetTables,
      ];
  List<WingetDBTable> get wingetTables => [installed, updates, available];
  List<DBTable> get faviconTables => [
        favicons,
        publisherNamesByPackageId,
        publisherNamesByPublisherId,
      ];
  Database? _database;
  late final Logger log;

  PackageDB._() {
    log = Logger(this);
    favicons = FaviconTable(this);
    publisherNamesByPackageId = PublisherNameTable(
      tableName: 'publisherName',
      idKey: 'packageId',
      parentDB: this,
    );
    publisherNamesByPublisherId = PublisherNameTable(
      tableName: 'publisherNameByPublisherId',
      idKey: 'publisherId',
      parentDB: this,
    );

    installed = getDBTable(winget: Winget.installed);
    updates = getDBTable(
        winget: Winget.updates, creatorFilter: PackageTables.filterUpdates);
    available = getDBTable(winget: Winget.availablePackages);
  }

  Future<void> ensureInitialized() async {
    if (_database != null) {
      return;
    }
    _database = await openDatabase(
      path.join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        for (DBTable table in tables) {
          table.initTable(db);
        }
      },
      version: 1,
    );
    for (DBTable table in faviconTables) {
      await table._setEntriesFromDB();
    }
    for (WingetDBTable table in wingetTables) {
      await table._setEntriesFromDB();
      table.parent.infos = table._entries.values.toList();
      table.parent.status = DBStatus.ready;
    }
  }

  WingetDBTable getDBTable({
    List<PackageInfosPeek> infos = const [],
    List<OneLineInfo> hints = const [],
    PackageFilter? creatorFilter,
    required Winget winget,
  }) {
    WingetTable wingetTable = WingetTable(
      infos,
      hints: hints,
      content: (locale) => locale.wingetTitle(winget.name),
      wingetCommand: winget.fullCommand,
      creatorFilter: creatorFilter,
      parent: PackageTables.instance,
    );
    WingetDBTable table = WingetDBTable(
        parentDB: this, tableName: winget.name, parent: wingetTable);
    wingetTable.internTable = table;
    return table;
  }
}

abstract class DBTable<K extends Object, V extends Object> {
  String get tableName;
  String get idKey;
  (K, V) entryFromMap(Map<String, dynamic> map);
  Map<String, dynamic> entryToMap((K, V) entry);

  Map<K, V> _entries = {};
  final PackageDB parentDB;

  DBTable(this.parentDB);

  initTable(Database db);

  void insert(K id, V value) {
    _entries[id] = value;
    _insertDB((id, value));
    _setEntriesFromDB();
  }

  void delete(K id) {
    _entries.remove(id);
    _deleteInDB(id);
    _setEntriesFromDB();
  }

  V? getEntry(K id) {
    return _entries[id];
  }

  Map<K, V> get entries => UnmodifiableMapView(_entries);

  Future<void> _ensureDBInitialized() {
    if (parentDB._database == null) {
      return parentDB.ensureInitialized();
    }
    return Future.value();
  }

  Future<List<(K, V)>> _getAllEntriesDB() async {
    await _ensureDBInitialized();
    List<Map<String, dynamic>> maps =
        await parentDB._database!.query(tableName);
    return maps.map((e) => entryFromMap(e)).toList();
  }

  Future<void> _deleteInDB(K id) async {
    await _ensureDBInitialized();
    await parentDB._database!.delete(
      tableName,
      where: '$idKey = ?',
      whereArgs: [id],
    );
  }

  Future<void> _insertDB((K, V) entry) async {
    await _ensureDBInitialized();
    await parentDB._database!.insert(
      tableName,
      entryToMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertMultipleDB(Map<K, V> entries) async {
    await _ensureDBInitialized();
    for (var entry in entries.entries) {
      await parentDB._database!.insert(
        tableName,
        entryToMap((entry.key, entry.value)),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<(K, V)?> getEntryDB(K id) async {
    await _ensureDBInitialized();
    List<Map<String, dynamic>> maps = await parentDB._database!.query(
      tableName,
      where: '$idKey = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return null;
    }
    return entryFromMap(maps.first);
  }

  Future<Map<K, V>> _dbToMap() async {
    List<(K, V)> dbEntries = await _getAllEntriesDB();
    return {for (var e in dbEntries) e.$1: e.$2};
  }

  Future<void> _setEntriesFromDB() async {
    _entries = await _dbToMap();
  }

  Future<void> _deleteAllInDB() async {
    await _ensureDBInitialized();
    await parentDB._database!.delete(tableName);
  }

  void deleteAll() {
    _entries.clear();
    _deleteAllInDB();
  }

  void setEntries(Map<K, V> entries) {
    _entries = entries;
    _deleteAllInDB();
    _insertMultipleDB(entries);
  }

  operator []=(K id, V value) => insert(id, value);
  operator [](K id) => getEntry(id);

  String toJson() {
    return jsonEncode(
        entries.entries.map((e) => entryToMap((e.key, e.value))).toList());
  }
}

mixin PackageTableSetListMixin
    on DBTable<(String, VersionOrString, String), PackageInfosPeek> {
  void setList(Iterable<PackageInfosPeek> list, {bool saveToDB = true}) {
    _entries =
        Map<(String, VersionOrString, String), PackageInfosPeek>.fromEntries(
            list.map((PackageInfosPeek e) => MapEntry(
                (e.id!.value.string, e.version!.value, e.name?.value ?? ''),
                e)));
    if (saveToDB) {
      _deleteAllInDB();
      _insertMultipleDB(_entries);
    }
  }
}
