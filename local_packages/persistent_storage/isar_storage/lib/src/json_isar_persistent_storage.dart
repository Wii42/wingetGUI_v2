import 'dart:io';

import 'package:isar/isar.dart';
import 'package:json_file_loader/json_file_loader_mixin.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_storage_interface/interface.dart';
import 'package:winget_core/winget_core.dart';

import 'isar_bulk_list_storage.dart';
import 'isar_key_value_sync_storage.dart';
import 'isar_models/bulk_storage.dart';
import 'isar_models/favicon.dart';
import 'isar_models/publisher_name_by_package_id.dart';
import 'isar_models/publisher_name_by_publisher_id.dart';
import 'isar_models/setting.dart';

/// A persistent storage implementation that uses JSO files and the Isar database.
class JsonIsarPersistentStorage extends PersistentStorage
    with JsonFileLoaderMixin {
  late final Directory isarPath;

  late final Isar _isar;
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
  late final PackageInfosPeekBulkListStorage installedPackages;

  @override
  bool get isInitialized => _isInitialized;

  @override
  late final BulkMapStorage<String, PackageScreenshots> packageScreenshots;

  @override
  late final PublisherNameByPackageIdStorage publisherNameByPackageId;

  @override
  late final PublisherNameByPublisherIdStorage publisherNameByPublisherId;

  @override
  late final SettingsStorage settings;

  @override
  late final PackageInfosPeekBulkListStorage updatePackages;

  @override
  Future<void> initialize() async {
    if (isInitialized) {
      return;
    }
    Directory applicationsDocuments = await getApplicationDocumentsDirectory();
    String isarDir = join(applicationsDocuments.path, '.wingetGUI_Isar');
    isarPath = await Directory(isarDir).create(recursive: false);
    //print(isarPath.path);
    _isar = await Isar.open(
      [
        IsarBulkStorageSchema,
        FaviconSchema,
        PublisherNameByPackageIdSchema,
        PublisherNameByPublisherIdSchema,
        SettingSchema,
      ],
      directory: isarPath.path,
      name: 'wingetGUI',
    );
    _isar.settings;
    settings =
        SettingsStorage(_isar.settings, _isar, tableName: settingsTableName);

    favicon =
        FaviconStorage(_isar.favicons, _isar, tableName: faviconTableName);

    publisherNameByPackageId = PublisherNameByPackageIdStorage(
        _isar.publisherNameByPackageId, _isar,
        tableName: publisherNameByPackageIdTableName);

    publisherNameByPublisherId = PublisherNameByPublisherIdStorage(
        _isar.publisherNameByPublisherId, _isar,
        tableName: publisherNameByPublisherIdTableName);
    availablePackages = PackageInfosPeekBulkListStorage(
        _isar.bulkStorage, _isar,
        listName: 'availablePackages');
    installedPackages = PackageInfosPeekBulkListStorage(
        _isar.bulkStorage, _isar,
        listName: 'installedPackages');
    updatePackages = PackageInfosPeekBulkListStorage(_isar.bulkStorage, _isar,
        listName: 'updatePackages');
    packageScreenshots = PackageScreenshotsBulkMapStorage(
        _isar.bulkStorage, _isar,
        listName: 'packageScreenshots');
    Future.wait([
      settings.loadCache(),
      favicon.loadCache(),
      publisherNameByPackageId.loadCache(),
      publisherNameByPublisherId.loadCache(),
    ]);
    _isInitialized = true;
  }
}
