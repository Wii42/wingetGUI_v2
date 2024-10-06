import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

import 'interface/persistent_storage.dart';
import 'json_file_loader.dart';

mixin JsonFileLoaderMixin on PersistentStorage {
  JsonFileLoader fileLoader = JsonFileLoader();

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
}
