import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FaviconDB {
  static final FaviconDB instance = FaviconDB._();
  static const String faviconsTable = 'favicon';
  String get dbName => '${faviconsTable}_database.db';
  List<FaviconDBEntry> _entries = [];
  Database? _database;
  FaviconDB._();

  Future<void> ensureInitialized() async {
    if (_database != null) {
      return;
    }
    _database = await openDatabase(
      path.join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $faviconsTable(${FaviconDBEntry.idKey} TEXT PRIMARY KEY, ${FaviconDBEntry.urlKey} TEXT)',
        );
      },
      version: 1,
    );
    _entries = await _getAllEntriesDB();
  }

  void insert(FaviconDBEntry entry) {
    _entries.add(entry);
    _insertDB(entry);
  }

  Future<void> _insertDB(FaviconDBEntry entry) async {
    if (_database == null) {
      await ensureInitialized();
    }
    await _database!.insert(
      faviconsTable,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _entries = await _getAllEntriesDB();
  }

  FaviconDBEntry? getEntry(String packageId) {
    return _entries
        .firstWhereOrNull((element) => element.packageId == packageId);
  }

  Future<FaviconDBEntry?> _getEntryDB(String packageId) async {
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

  List<FaviconDBEntry> get entries => UnmodifiableListView(_entries);

  Future<List<FaviconDBEntry>> _getAllEntriesDB() async {
    if (_database == null) {
      await ensureInitialized();
    }
    List<Map<String, dynamic>> maps = await _database!.query(faviconsTable);
    return maps.map((e) => FaviconDBEntry.fromMap(e)).toList();
  }

  void delete(String packageId) {
    _entries.removeWhere((element) => element.packageId == packageId);
    _deleteInDB(packageId);
  }

  Future<void> _deleteInDB(String packageId) async {
    if (_database == null) {
      await ensureInitialized();
    }
    await _database!.delete(
      faviconsTable,
      where: '${FaviconDBEntry.idKey} = ?',
      whereArgs: [packageId],
    );
  }
}

class FaviconDBEntry {
  static const idKey = 'packageId';
  static const urlKey = 'url';
  final String packageId;
  final Uri url;

  FaviconDBEntry({required this.packageId, required this.url});

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