import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';

import 'package:winget_gui/helpers/json_publisher.dart';

import 'package:winget_gui/helpers/package_screenshots.dart';

import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/json_file_loader.dart';
import 'package:winget_gui/persistent_storage/web_fetcher.dart';

import 'persistent_storage_interface.dart';

class JsonSharedPrefsSqflitePersistentStorage implements PersistentStorage {
  JsonFileLoader fileLoader = JsonFileLoader();
  WebFetcher webFetcher = WebFetcher();
  @override
  // TODO: implement availablePackages
  BulkListStorage<PackageInfosPeek> get availablePackages =>
      throw UnimplementedError();

  @override
  // TODO: implement favicon
  KeyValueStorage<String, Uri> get favicon => throw UnimplementedError();

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  // TODO: implement installedPackages
  BulkListStorage<PackageInfosPeek> get installedPackages =>
      throw UnimplementedError();

  @override
  // TODO: implement isInitialized
  bool get isInitialized => throw UnimplementedError();

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
  // TODO: implement packageScreenshots
  BulkMapStorage<String, PackageScreenshots> get packageScreenshots =>
      throw UnimplementedError();

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
}
