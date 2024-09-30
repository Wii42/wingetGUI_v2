import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';

import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/log_stream.dart';

import 'package:winget_gui/helpers/package_screenshots.dart';

import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/json_file_loader.dart';
import 'package:winget_gui/persistent_storage/web_fetcher.dart';

import 'persistent_storage_interface.dart';

/// A persistent storage implementation that uses shared preferences, json files and sqflite.
class JsonSharedPrefsSqflitePersistentStorage implements PersistentStorage {
  JsonFileLoader fileLoader = JsonFileLoader();
  WebFetcher webFetcher = WebFetcher();

  late SharedPreferences prefs;
  late ScreenshotBulkStorage _packageScreenshots;

  bool _isInitialized = false;
  @override
  // TODO: implement availablePackages
  BulkListStorage<PackageInfosPeek> get availablePackages =>
      throw UnimplementedError();

  @override
  // TODO: implement favicon
  KeyValueStorage<String, Uri> get favicon => throw UnimplementedError();

  @override
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    _packageScreenshots = ScreenshotBulkStorage(prefs, 'packagePictures');
    _isInitialized = true;
  }

  @override
  // TODO: implement installedPackages
  BulkListStorage<PackageInfosPeek> get installedPackages =>
      throw UnimplementedError();

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
  BulkMapStorage<String, PackageScreenshots> get packageScreenshots =>
      _packageScreenshots;

  @override
  // TODO: implement publisherNameByPackageId
  KeyValueStorage<String, String> get publisherNameByPackageId =>
      throw UnimplementedError();

  @override
  // TODO: implement publisherNameByPublisherId
  KeyValueStorage<String, String> get publisherNameByPublisherId =>
      throw UnimplementedError();

  @override
  // TODO: implement updatePackages
  BulkListStorage<PackageInfosPeek> get updatePackages =>
      throw UnimplementedError();

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

class SettingsStorage implements KeyValueSyncStorage<String, String> {
  Logger log = Logger(null, sourceType: SettingsStorage);
  SharedPreferences prefs;
  String keyPrefix;
  List<String> keys = [];

  SettingsStorage(this.prefs, this.keyPrefix);

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
  Map<String, String> loadAllPairs() {
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
}
