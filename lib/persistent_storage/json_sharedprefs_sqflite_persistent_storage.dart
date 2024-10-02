import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/db/package_db.dart';
import 'package:winget_gui/db/winget_db_table.dart';
import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/json_file_loader.dart';
import 'package:winget_gui/persistent_storage/web_fetcher.dart';

import 'persistent_storage_interface.dart';

/// A persistent storage implementation that uses shared preferences, json files and sqflite.
class JsonSharedPrefsSqflitePersistentStorage implements PersistentStorage {
  JsonFileLoader fileLoader = JsonFileLoader();
  WebFetcher webFetcher = WebFetcher();

  late SharedPreferences prefs;
  PackageDB packageDB = PackageDB(dbName: 'favicon_database.db');

  bool _isInitialized = false;
  @override
  late BulkListStorage<PackageInfosPeek> availablePackages;

  @override
  late final FaviconsStorage<Uri> favicon;

  @override
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    packageScreenshots = ScreenshotBulkStorage(prefs, 'packagePictures');
    await packageDB.ensureInitialized();
    favicon = FaviconsStorage(packageDB.favicons, tableName: 'Favicons');
    publisherNameByPackageId = FaviconsStorage(
        packageDB.publisherNamesByPackageId,
        tableName: 'Publisher name by package id');
    publisherNameByPublisherId = FaviconsStorage(
        packageDB.publisherNamesByPublisherId,
        tableName: 'Publisher name by publisher id');
    installedPackages = WingetDBTableWrap(packageDB.installed);
    updatePackages = WingetDBTableWrap(packageDB.updates);
    availablePackages = WingetDBTableWrap(packageDB.available);
    _isInitialized = true;
    await packageDB.finishInitializing();
  }

  @override
  late final BulkListStorage<PackageInfosPeek> installedPackages;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<List<String>> loadBannedIcons() => fileLoader.loadBannedIconsTxt();

  @override
  Future<Map<String, CustomIconKey>> loadCustomIconKeys() =>
      fileLoader.loadCustomIconKeys();

  @override
  Future<Map<String, PackageScreenshots>> loadCustomPackageScreenshots() =>
      fileLoader.loadCustomPackageScreenshots();

  @override
  Future<Map<String, JsonPublisher>> loadCustomPublisherData() =>
      fileLoader.loadCustomPublisherData();

  @override
  late final BulkMapStorage<String, PackageScreenshots> packageScreenshots;

  @override
  late final FaviconsStorage<String> publisherNameByPackageId;

  @override
  late final FaviconsStorage<String> publisherNameByPublisherId;

  @override
  late final BulkListStorage<PackageInfosPeek> updatePackages;

  @override
  SettingsStorage get settings => SettingsStorage(prefs, 'settings');
}

class ScreenshotBulkStorage
    implements BulkMapStorage<String, PackageScreenshots> {
  Logger log = Logger(null, sourceType: ScreenshotBulkStorage);
  SharedPreferences prefs;
  String prefsKey;

  ScreenshotBulkStorage(this.prefs, this.prefsKey);

  @override
  Future<void> deleteAll() {
    prefs.remove(prefsKey);
    return Future.value();
  }

  @override
  Future<Map<String, PackageScreenshots>> loadAll() {
    final json = prefs.getString(prefsKey);
    if (json == null) {
      log.warning('No screenshots found in shared prefs');
      return Future.value({});
    }
    return Future.value(PackageScreenshots.mapFromJson(jsonDecode(json)));
  }

  @override
  Future<void> saveAll(Map<String, PackageScreenshots> map) {
    String json = jsonEncode(PackageScreenshots.mapToJson(map));
    prefs.setString(prefsKey, json);
    return Future.value();
  }
}

class SettingsStorage extends KeyValueSyncStorage<String, String> {
  Logger log = Logger(null, sourceType: SettingsStorage);
  SharedPreferences prefs;
  String keyPrefix;
  List<String> keys = [];

  SettingsStorage(this.prefs, this.keyPrefix, {this.tableName = 'Settings'});

  @override
  void addEntry(String key, value) {
    prefs.setString(_prefKey(key), value);
    keys.add(key);
  }

  @override
  void deleteAllEntries() {
    for (String key in keys) {
      prefs.remove(_prefKey(key));
    }
    keys.clear();
  }

  @override
  void deleteEntry(String key) {
    prefs.remove(_prefKey(key));
    keys.remove(key);
  }

  @override
  String? getEntry(String key) {
    return prefs.getString(_prefKey(key));
  }

  String _prefKey(String key) => '$keyPrefix:$key';

  @override
  Map<String, String> get entries {
    Map<String, String> map = {};
    for (String key in keys) {
      map[key] = prefs.getString(_prefKey(key))!;
    }
    return map;
  }

  @override
  void saveEntries(Map<String, String> entries) {
    for (MapEntry<String, String> entry in entries.entries) {
      prefs.setString(_prefKey(entry.key), entry.value);
      keys.add(entry.key);
    }
  }

  @override
  String tableName;
}

/// Abstraction to wrap DB table with two columns: key and value.
///
/// The key is a String
/// [V] is the type of the value.
class FaviconsStorage<V extends Object> extends KeyValueSyncStorage<String, V> {
  final DBTable<String, V> _table;

  FaviconsStorage(this._table, {this.tableName = 'Favicon'});
  @override
  void addEntry(String key, V value) => _table.insert(key, value);

  @override
  void deleteAllEntries() => _table.deleteAll();

  @override
  void deleteEntry(String key) => _table.delete(key);

  @override
  Map<String, V> get entries => _table.entries;

  @override
  V? getEntry(String key) => _table.getEntry(key);

  @override
  void saveEntries(Map<String, V> entries) => _table.addEntries(entries);

  @override
  String tableName;
}

class WingetDBTableWrap implements BulkListStorage<PackageInfosPeek> {
  final WingetDBTable _table;

  WingetDBTableWrap(this._table);

  @override
  Future<void> deleteAll() {
    _table.deleteAll();
    return Future.value();
  }

  @override
  Future<List<PackageInfosPeek>> loadAll() async {
    Map<Object, PackageInfosPeek> entries = await _table.loadEntriesFromDB();
    return entries.values.toList();
  }

  @override
  Future<void> saveAll(List<PackageInfosPeek> list) {
    Map<(String, VersionOrString, String), PackageInfosPeek> map = {};
    for (PackageInfosPeek info in list) {
      map[(
        info.id?.value.toString() ?? '',
        info.version?.value ?? VersionOrString.stringVersion(''),
        info.name?.value ?? ''
      )] = info;
    }
    _table.addEntries(map);
    return Future.value();
  }
}
