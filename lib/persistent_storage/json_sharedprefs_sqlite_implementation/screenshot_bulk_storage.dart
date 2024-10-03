import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

import '../persistent_storage.dart';

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
