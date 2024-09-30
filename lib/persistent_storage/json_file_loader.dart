import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/persistent_storage/json_web_core.dart';

class JsonFileLoader {
  Logger log = Logger(null, sourceType: JsonFileLoader);

  Future<List<String>> loadBannedIconsTxt() async {
    Iterable<String> list = await loadLinesOfAsset('banned_icons.txt');
    return list.toList();
  }

  Future<Map<String, CustomIconKey>> loadCustomIconKeys() async {
    String data = await loadAsset('custom_icon_keys.json');
    if (data.isEmpty) {
      return {};
    }
    Map<String, dynamic> object = jsonDecode(data);
    return object
        .map((key, value) => MapEntry(key, CustomIconKey.fromJson(value, key)));
  }

  Future<Map<String, PackageScreenshots>> loadCustomPackageScreenshots() async {
    String data = await loadAsset('custom_package_screenshots.json');
    if (data.isEmpty) {
      log.warning('No custom package screenshots found');
      return {};
    }
    Json json = Json.parse(data).getOrElse(
      () {
        throw Exception('Error parsing JSON');
      },
    );
    JsonObject? object = json.asObject().toNullable();
    if (object == null) {
      log.error('Json is not an object');
      return {};
    }
    return JsonWebCore().parseScreenshotsMap(object);
  }

  Future<Map<String, JsonPublisher>> loadCustomPublisherData() async {
    String data = await loadAsset('publisher.json');
    if (data.isEmpty) {
      log.warning('No custom publisher data found');
      return {};
    }
    return JsonPublisher.parseJsonMap(data);
  }

  Future<Iterable<String>> loadLinesOfAsset(String fileName) async {
    String string = await loadAsset(fileName);
    Iterable<String> lines = string.split('\n').map<String>((e) => e.trim());
    return lines;
  }

  Future<String> loadAsset(String fileName) async {
    return rootBundle.loadString('assets/$fileName');
  }
}
