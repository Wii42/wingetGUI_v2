import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:isar_key_value/isar_key_value.dart';

import '../json_file_loader_mixin.dart';
import '../persistent_storage.dart';
import 'isar_bulk_list_storage.dart';
import 'isar_key_value_sync_storage.dart';

/// A persistent storage implementation that uses JSO files and the Isar database.
class JsonIsarPersistentStorage extends PersistentStorage
    with JsonFileLoaderMixin {
  late final Directory _path;
  late final IsarKeyValue _settingsIsar;
  late final IsarKeyValue _faviconIsar;
  late final IsarKeyValue _publisherNameByPackageIdIsar;
  late final IsarKeyValue _publisherNameByPublisherIdIsar;
  late final IsarKeyValue _bulkListIsar;
  final String settingsTableName = 'settings';
  final String faviconTableName = 'favicon';
  final String publisherNameByPackageIdTableName = 'publisherNameByPackageId';
  final String publisherNameByPublisherIdTableName =
      'publisherNameByPublisherId';

  bool _isInitialized = false;
  @override
  late final PackageInfosPeekBulkListStorage availablePackages;

  @override
  late final FaviconStorage favicon;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }
    Directory applicationsDocuments = await getApplicationDocumentsDirectory();
    String isarDir = join(applicationsDocuments.path, '.wingetGUI_Isar');
    _path = await Directory(isarDir).create(recursive: false);
    print(_path.path);
    _settingsIsar =
        IsarKeyValue(name: settingsTableName, directory: _path.path);
    await _settingsIsar.ensureInitialized();
    settings = IsarKeyValueSyncStorage<String>(_settingsIsar,
        tableName: settingsTableName);

    _faviconIsar = IsarKeyValue(name: faviconTableName, directory: _path.path);
    await _faviconIsar.ensureInitialized();
    favicon = FaviconStorage(_faviconIsar, tableName: faviconTableName);

    _publisherNameByPackageIdIsar = IsarKeyValue(
        name: publisherNameByPackageIdTableName, directory: _path.path);
    await _publisherNameByPackageIdIsar.ensureInitialized();
    publisherNameByPackageId = IsarKeyValueSyncStorage<String>(
        _publisherNameByPackageIdIsar,
        tableName: publisherNameByPackageIdTableName);

    _publisherNameByPublisherIdIsar = IsarKeyValue(
        name: publisherNameByPublisherIdTableName, directory: _path.path);
    await _publisherNameByPublisherIdIsar.ensureInitialized();
    publisherNameByPublisherId = IsarKeyValueSyncStorage<String>(
        _publisherNameByPublisherIdIsar,
        tableName: publisherNameByPublisherIdTableName);
    _bulkListIsar =
        IsarKeyValue(name: 'bulkListStorage', directory: _path.path);
    await _bulkListIsar.ensureInitialized();
    availablePackages = PackageInfosPeekBulkListStorage(_bulkListIsar,
        listName: 'availablePackages');
    installedPackages = PackageInfosPeekBulkListStorage(_bulkListIsar,
        listName: 'installedPackages');
    updatePackages = PackageInfosPeekBulkListStorage(_bulkListIsar,
        listName: 'updatePackages');
    packageScreenshots = PackageScreenshotsBulkMapStorage(_bulkListIsar,
        mapName: 'packageScreenshots');
    _isInitialized = true;
  }

  @override
  late final PackageInfosPeekBulkListStorage installedPackages;

  @override
  bool get isInitialized => _isInitialized;

  @override
  late final BulkMapStorage<String, PackageScreenshots> packageScreenshots;

  @override
  late final IsarKeyValueSyncStorage<String> publisherNameByPackageId;

  @override
  late final IsarKeyValueSyncStorage<String> publisherNameByPublisherId;

  @override
  late final IsarKeyValueSyncStorage<String> settings;

  @override
  late final PackageInfosPeekBulkListStorage updatePackages;
}

class FaviconStorage extends KeyValueSyncStorage<String, Uri> {
  late final IsarKeyValueSyncStorage<String> _storage;

  FaviconStorage(IsarKeyValue persistent, {required String tableName}) {
    _storage = IsarKeyValueSyncStorage(persistent, tableName: tableName);
  }
  @override
  void addEntry(String key, Uri value) {
    _storage.addEntry(key, value.toString());
  }

  @override
  void deleteAllEntries() {
    _storage.deleteAllEntries();
  }

  @override
  void deleteEntry(String key) {
    _storage.deleteEntry(key);
  }

  @override
  Map<String, Uri> get entries =>
      _storage.entries.map((key, value) => MapEntry(key, Uri.parse(value)));

  @override
  Uri? getEntry(String key) {
    var value = _storage.getEntry(key);
    if (value == null) {
      return null;
    }
    return Uri.parse(value);
  }

  @override
  void saveEntries(Map<String, Uri> entries) {
    _storage.saveEntries(
        entries.map((key, value) => MapEntry(key, value.toString())));
  }

  @override
  String get tableName => _storage.tableName;
}
