import 'package:persistent_storage_interface/interface.dart';
import 'package:winget_core/winget_core.dart';

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
