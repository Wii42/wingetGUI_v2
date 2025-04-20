import 'dart:convert';
import 'dart:developer';

import 'package:persistent_storage_interface/interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_core/winget_core.dart';

class ScreenshotBulkStorage
    implements BulkMapStorage<String, PackageScreenshots> {
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
      log('No screenshots found in shared prefs');
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
