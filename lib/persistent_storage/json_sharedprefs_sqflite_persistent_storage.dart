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
