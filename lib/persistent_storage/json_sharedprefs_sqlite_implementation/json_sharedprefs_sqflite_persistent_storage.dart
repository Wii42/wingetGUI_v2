import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/db/package_db.dart';
import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/json_file_loader.dart';
import 'winget_db_table_wrap.dart';
import 'favicon_storage.dart';
import 'screenshot_bulk_storage.dart';
import 'package:winget_gui/persistent_storage/web_fetcher.dart';

import '../persistent_storage.dart';
import 'settings_storage.dart';

/// A persistent storage implementation that uses shared preferences,
/// json files and sqflite.
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
