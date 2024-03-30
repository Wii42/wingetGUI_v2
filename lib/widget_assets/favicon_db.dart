import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/log_stream.dart';

class FaviconDB {
  static final FaviconDB instance = FaviconDB._();
  static const String dbName = 'favicon_database.db';
  late final FaviconTable favicons;
  late final PublisherNameTable publisherNamesByPackageId;
  late final PublisherNameTable publisherNamesByPublisherId;
  List<DBTable> get tables =>
      [favicons, publisherNamesByPackageId, publisherNamesByPublisherId];
  Database? _database;
  late final Logger log;

  FaviconDB._() {
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
    for (DBTable table in tables) {
      table._setEntriesFromDB();
    }
    log.info('init publisherNamesByPackageIdDB',
        message: (await publisherNamesByPackageId._dbToMap()).toString());
    log.info('init publisherNamesByPublisherIdDB',
        message: (await publisherNamesByPublisherId._dbToMap()).toString());
  }
}

abstract class DBTable<K extends Object, V extends Object> {
  String get tableName;
  String get idKey;
  (K, V) fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap((K, V) entry);

  Map<K, V> _entries = {};
  final FaviconDB parentDB;

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
    return maps.map((e) => fromMap(e)).toList();
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
      toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    return fromMap(maps.first);
  }

  Future<Map<K, V>> _dbToMap() async {
    List<(K, V)> dbEntries = await _getAllEntriesDB();
    return {for (var e in dbEntries) e.$1: e.$2};
  }

  _setEntriesFromDB() async {
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

  operator []=(K id, V value) => insert(id, value);
  operator [](K id) => getEntry(id);
}

class FaviconTable extends DBTable<String, Uri> {
  @override
  final String tableName = 'favicon';
  @override
  final String idKey = 'packageId';
  final urlKey = 'url';

  FaviconTable(super.parentDB);

  @override
  void initTable(Database db) {
    db.execute(
      '''CREATE TABLE $tableName(
          $idKey TEXT PRIMARY KEY,
          $urlKey TEXT
          )''',
    );
  }

  @override
  (String, Uri) fromMap(Map<String, dynamic> map) {
    return (map[idKey], Uri.parse(map[urlKey]));
  }

  @override
  Map<String, dynamic> toMap((String, Uri) entry) {
    return {
      idKey: entry.$1,
      urlKey: entry.$2.toString(),
    };
  }
}

class PublisherNameTable extends DBTable<String, String> {
  @override
  final String tableName;
  @override
  final String idKey;
  final publisherNameKey = 'publisherName';

  PublisherNameTable(
      {required this.tableName,
      required this.idKey,
      required FaviconDB parentDB})
      : super(parentDB);

  @override
  void initTable(Database db) {
    db.execute(
      '''CREATE TABLE $tableName(
          $idKey TEXT PRIMARY KEY,
          $publisherNameKey TEXT
          )''',
    );
  }

  @override
  (String, String) fromMap(Map<String, dynamic> map) {
    return (map[idKey], map[publisherNameKey]);
  }

  @override
  Map<String, dynamic> toMap((String, String) entry) {
    return {
      idKey: entry.$1,
      publisherNameKey: entry.$2,
    };
  }
}
