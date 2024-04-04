import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ribs_json/ribs_json.dart';

import '../../output_handling/package_infos/package_infos_peek.dart';
import '../json_publisher.dart';
import '../package_screenshots.dart';
import '../package_screenshots_list.dart';

extension ScreenshotsListLoader on PackageScreenshotsList {
  static const String wingetUIScreenshotDatabaseUrl =
      'https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/screenshot-database-v2.json';
  static const String wingetUIInvalidScreenshotsUrl =
      "https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/invalid_urls.txt";
  static final Uri screenshotsSource = Uri.parse(wingetUIScreenshotDatabaseUrl);
  static final Uri invalidScreenshotsSource =
      Uri.parse(wingetUIInvalidScreenshotsUrl);
  static const String _packageScreenshotsKey = 'packagePictures';

  String _getStringFromSharedPreferences() =>
      prefs!.getString(_packageScreenshotsKey) ?? '';

  Future<void> screenshotsFromWingetUIJson(String data) async {
    Json json = Json.parse(data).getOrElse(
      () {
        throw Exception('Error parsing JSON');
      },
    );
    JsonObject? object = json.asObject().toNullable();
    if (object == null) {
      log.error('Json is not an object');
      return;
    }
    if (!object.contains("icons_and_screenshots")) {
      log.error('json does not contain icons_and_screenshots');
      return;
    }
    JsonObject? packageScreenshotsMap =
        object.getUnsafe("icons_and_screenshots").asObject().toNullable();
    if (packageScreenshotsMap == null) {
      log.error('"icons_and_screenshots" not an object');
      return;
    }
    screenshotMap = parseScreenshotsMap(packageScreenshotsMap);

    await _removeBannedIconsFromScreenshotMap();
    _removeInvalidUrlsFromScreenshotMap();
    await _changeToCustomKeysInScreenshotMap();
    _removeEmptyScreenshotsFromScreenshotsMap();

    if (prefs != null && prefs!.getString(_packageScreenshotsKey) != data) {
      prefs!.setString(_packageScreenshotsKey, data);
    }
  }

  Future<void> _changeToCustomKeysInScreenshotMap() async {
    Map<String, CustomIconKey> customIconKeys = await loadCustomIconKeys();
    for (String oldKey in customIconKeys.keys) {
      CustomIconKey customKeys = customIconKeys[oldKey]!;
      log.info(customKeys.toString());
      String? newKey = customKeys.newKey;
      if (screenshotMap.containsKey(oldKey)) {
        PackageScreenshots screenshots = screenshotMap[oldKey]!;
        if (newKey != null) {
          screenshotMap[newKey] = screenshots.copyWith(packageKey: newKey);
          screenshotMap.remove(oldKey);
        }
        if (customKeys.otherKeys.isNotEmpty) {
          for (String otherKey in customKeys.otherKeys) {
            screenshotMap[otherKey] =
                screenshots.copyWith(packageKey: otherKey);
          }
        }
      }
    }
  }

  Future<void> _removeBannedIconsFromScreenshotMap() async {
    List<String> bannedKeys = await loadBannedIcons();
    for (String key in bannedKeys) {
      screenshotMap.remove(key);
    }
  }

  void _removeInvalidUrlsFromScreenshotMap() {
    for (PackageScreenshots screenshots in screenshotMap.values) {
      if (invalidScreenshotUrls.contains(screenshots.icon)) {
        screenshots.icon = null;
      }
      if (screenshots.screenshots != null) {
        screenshots.screenshots!
            .removeWhere((element) => invalidScreenshotUrls.contains(element));
      }
    }
  }

  Future<void> loadScreenshots() async {
    try {
      String data = _getStringFromSharedPreferences();
      await screenshotsFromWingetUIJson(data);
      log.info('stored data fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<void> fetchWebScreenshots() async {
    try {
      String data = await getStringFromWeb(screenshotsSource);
      await screenshotsFromWingetUIJson(data);
      log.info('web data fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<void> fetchWebInvalidScreenshots() async {
    try {
      String data = await getStringFromWeb(invalidScreenshotsSource);
      List<String> lines = data.split('\n');
      invalidScreenshotUrls = lines
          .map<Uri?>((e) => Uri.tryParse(e.trim()))
          .where((element) => element != null)
          .cast<Uri>()
          .toList();
      log.info('invalid icons fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<List<String>> loadBannedIcons() async {
    Iterable<String> list = await loadLinesOfAsset('banned_icons.txt');
    return list.toList();
  }

  Future<void> loadCustomPackageScreenshots() async {
    String data = await loadAsset('custom_package_screenshots.json');
    if (data.isEmpty) {
      return;
    }
    Json json = Json.parse(data).getOrElse(
      () {
        throw Exception('Error parsing JSON');
      },
    );
    JsonObject? object = json.asObject().toNullable();
    if (object == null) {
      log.error('Json is not an object');
      return;
    }
    customScreenshots = parseScreenshotsMap(object);
    for (String packageId in customScreenshots.keys) {
      PackageScreenshots? found =
          getPackage(PackageInfosPeek.onlyId(packageId));
      if (found == null) {
        if (!packageId.endsWith('.*')) {
          idToPackageKeyMap[packageId] = packageId;
        }
      } else {
        found.backup ??= customScreenshots[packageId];
      }
    }
  }

  Future<void> loadPublisherJson() async {
    String data = await loadAsset('publisher.json');
    if (data.isEmpty) {
      return;
    }
    publisherIcons = JsonPublisher.parseJsonMap(data);
  }

  Future<String> loadAsset(String fileName) async {
    return rootBundle.loadString('assets/$fileName');
  }

  Future<Iterable<String>> loadLinesOfAsset(String fileName) async {
    String string = await loadAsset(fileName);
    Iterable<String> lines = string.split('\n').map<String>((e) => e.trim());
    return lines;
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

  void _removeEmptyScreenshotsFromScreenshotsMap() {
    screenshotMap.removeWhere(
      (key, value) {
        return (value.icon == null &&
            (value.screenshots == null || value.screenshots!.isEmpty) &&
            value.backup == null);
      },
    );
  }
}

class CustomIconKey {
  final String oldKey;
  final String? newKey;
  final List<String> otherKeys;

  CustomIconKey({required this.oldKey, this.newKey, this.otherKeys = const []});

  factory CustomIconKey.fromJson(Map<String, dynamic> json, String key) {
    List<dynamic> otherKeys = json['other_keys'] ?? const [];
    return CustomIconKey(
      oldKey: key,
      newKey: json['new_key'],
      otherKeys: otherKeys.cast<String>(),
    );
  }

  @override
  String toString() {
    return 'CustomIconKey{oldKey: $oldKey, newKey: $newKey, otherKeys: $otherKeys}';
  }
}
