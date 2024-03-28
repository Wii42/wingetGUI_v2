import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/log_stream.dart';

class FaviconDB {
  static final FaviconDB instance = FaviconDB._();
  static const String faviconsTable = 'favicon';
  static const publisherNameTable = 'publisherName';
  String get dbName => '${faviconsTable}_database.db';
  Map<String, Uri> _favicons = {};
  Map<String, String> _publisherNames = {};
  Database? _database;
  late final Logger log;
  FaviconDB._() {
    log = Logger(this);
  }

  Future<void> ensureInitialized() async {
    if (_database != null) {
      return;
    }
    _database = await openDatabase(
      path.join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        db.execute(
          '''CREATE TABLE $faviconsTable(
          ${FaviconDBEntry.idKey} TEXT PRIMARY KEY,
          ${FaviconDBEntry.urlKey} TEXT
          )''',
        );
        db.execute(
          '''CREATE TABLE $publisherNameTable(
          ${PublisherDBEntry.idKey} TEXT PRIMARY KEY,
          ${PublisherDBEntry.publisherNameKey} TEXT
          )''',
        );
      },
      version: 1,
    );
    _favicons = await _dbToMapFavicons();
    _publisherNames = await _dbToMapPublisherNames();
    log.info('init publisherNamesDB',
        message: (await _dbToMapPublisherNames()).toString());
  }

  Future<Map<String, Uri>> _dbToMapFavicons() async {
    List<FaviconDBEntry> dbEntries = await _getAllFaviconsDB();
    return {for (var e in dbEntries) e.packageId: e.url};
  }

  Future<Map<String, String>> _dbToMapPublisherNames() async {
    List<PublisherDBEntry> dbEntries = await _getAllPublisherNamesDB();
    return {for (var e in dbEntries) e.packageId: e.publisherName};
  }

  void insertFavicon(FaviconDBEntry entry) {
    _favicons[entry.packageId] = entry.url;
    _insertDB(entry, faviconsTable);
  }

  void insertPublisherName(PublisherDBEntry entry) {
    _publisherNames[entry.packageId] = entry.publisherName;
    _insertDB(entry, publisherNameTable);
    _dbToMapPublisherNames();
  }

  Future<void> _insertDB(DBEntry entry, String tableName) async {
    if (_database == null) {
      await ensureInitialized();
    }
    await _database!.insert(
      tableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    switch (tableName) {
      case faviconsTable:
        _favicons = await _dbToMapFavicons();
        break;
      case publisherNameTable:
        _publisherNames = await _dbToMapPublisherNames();
        break;
    }
  }

  Uri? getFavicon(String packageId) {
    return _favicons[packageId];
  }

  String? getPublisherName(String? packageId) {
    return _publisherNames[packageId];
  }

  Future<FaviconDBEntry?> _getFaviconEntryDB(String packageId) async {
    if (_database == null) {
      await ensureInitialized();
    }
    List<Map<String, dynamic>> maps = await _database!.query(
      faviconsTable,
      where: '${FaviconDBEntry.idKey} = ?',
      whereArgs: [packageId],
    );
    if (maps.isEmpty) {
      return null;
    }
    return FaviconDBEntry.fromMap(maps.first);
  }

  Map<String, Uri> get favicons => UnmodifiableMapView(_favicons);
  Map<String, String> get publisherNames =>
      UnmodifiableMapView(_publisherNames);

  Future<List<FaviconDBEntry>> _getAllFaviconsDB() async {
    if (_database == null) {
      await ensureInitialized();
    }
    List<Map<String, dynamic>> maps = await _database!.query(faviconsTable);
    return maps.map((e) => FaviconDBEntry.fromMap(e)).toList();
  }

  Future<List<PublisherDBEntry>> _getAllPublisherNamesDB() async {
    if (_database == null) {
      await ensureInitialized();
    }
    List<Map<String, dynamic>> maps =
        await _database!.query(publisherNameTable);
    return maps.map((e) => PublisherDBEntry.fromMap(e)).toList();
  }

  void deleteFavicon(String packageId) {
    _favicons.remove(packageId);
    _deleteInDB(packageId, faviconsTable);
  }

  void deletePublisherName(String packageId) {
    _publisherNames.remove(packageId);
    _deleteInDB(packageId, publisherNameTable);
  }

  Future<void> _deleteInDB(String packageId, String table) async {
    if (_database == null) {
      await ensureInitialized();
    }
    await _database!.delete(
      table,
      where: '${FaviconDBEntry.idKey} = ?',
      whereArgs: [packageId],
    );
  }
}

abstract class DBEntry {
  Map<String, dynamic> toMap();
}

class FaviconDBEntry extends DBEntry {
  static const idKey = 'packageId';
  static const urlKey = 'url';
  final String packageId;
  final Uri url;

  FaviconDBEntry({required this.packageId, required this.url});

  @override
  Map<String, dynamic> toMap() {
    return {
      idKey: packageId,
      urlKey: url.toString(),
    };
  }

  factory FaviconDBEntry.fromMap(Map<String, dynamic> map) {
    return FaviconDBEntry(
      packageId: map[idKey],
      url: Uri.parse(map[urlKey]),
    );
  }

  @override
  String toString() {
    return 'FaviconDBEntry{packageId: $packageId, url: $url}';
  }
}

class PublisherDBEntry extends DBEntry {
  static const idKey = 'packageId';
  static const publisherNameKey = 'publisherName';
  final String packageId;
  final String publisherName;

  PublisherDBEntry({required this.packageId, required this.publisherName});

  @override
  Map<String, dynamic> toMap() {
    return {
      idKey: packageId,
      publisherNameKey: publisherName,
    };
  }

  factory PublisherDBEntry.fromMap(Map<String, dynamic> map) {
    return PublisherDBEntry(
      packageId: map[idKey],
      publisherName: map[publisherNameKey],
    );
  }

  @override
  String toString() {
    return 'PublisherDBEntry{packageId: $packageId, publisherName: $publisherName}';
  }
}
