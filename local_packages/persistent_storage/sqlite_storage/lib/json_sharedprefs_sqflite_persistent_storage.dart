import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:winget_core/winget_core.dart';
import 'package:persistent_storage_interface/interface.dart';
import 'package:json_file_loader/json_file_loader_mixin.dart';
import 'favicon_storage.dart';
import 'screenshot_bulk_storage.dart';
import 'settings_storage.dart';
import 'sqflite_db/package_db.dart';
import 'winget_db_table_wrap.dart';

/// A persistent storage implementation that uses shared preferences,
/// json files and sqflite.
class JsonSharedPrefsSqflitePersistentStorage extends PersistentStorage
    with JsonFileLoaderMixin {
  late SharedPreferences prefs;
  PackageDB packageDB = PackageDB(dbName: 'favicon_database.db');
  bool _isInitialized = false;

  @override
  late BulkListStorage<PackageInfosPeek> availablePackages;

  @override
  late final FaviconsStorage<Uri> favicon;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
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
    await packageDB.loadFaviconTables();
    _isInitialized = true;
  }

  @override
  late final BulkListStorage<PackageInfosPeek> installedPackages;

  @override
  bool get isInitialized => _isInitialized;

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
