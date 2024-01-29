import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:ribs_core/ribs_core.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/helpers/publisher.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_screenshot_identifiers.dart';

import '../output_handling/package_infos/package_infos_peek.dart';

class PackageScreenshotsList {
  static const String wingetUIScreenshotDatabaseUrl =
      'https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/screenshot-database-v2.json';
  static const String wingetUIInvalidScreenshotsUrl =
      "https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/invalid_urls.txt";
  static final Uri screenshotsSource = Uri.parse(wingetUIScreenshotDatabaseUrl);
  static final Uri invalidScreenshotsSource =
      Uri.parse(wingetUIInvalidScreenshotsUrl);
  static const String _packageScreenshotsKey = 'packagePictures';
  SharedPreferences? _prefs;
  static final PackageScreenshotsList instance = PackageScreenshotsList._();

  Map<String, PackageScreenshots> screenshotMap = {};
  List<Uri> invalidScreenshotUrls = [];
  final Map<String, String> _idToPackageKeyMap = {};

  Map<String, Publisher> publisherIcons = {};
  Map<String, PackageScreenshots> customIcons = {};

  PackageScreenshotsList._();

  Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @visibleForTesting
  void setMockSharedPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  String _getStringFromSharedPreferences() =>
      _prefs!.getString(_packageScreenshotsKey) ?? '';

  Future<String> _getStringFromWeb(Uri url) async {
    Response request = await get(url);
    return request.body;
  }

  void screenshotsFromJson(String data) {
    Json json = Json.parse(data).getOrElse(
      () {
        throw Exception('Error parsing JSON');
      },
    );
    JsonObject? object = json.asObject().toNullable();
    if (object == null) {
      if (kDebugMode) {
        print('Json is not an object');
      }
      return;
    }
    if (!object.contains("icons_and_screenshots")) {
      if (kDebugMode) {
        print('json does not contain icons_and_screenshots');
      }
      return;
    }
    JsonObject? packageScreenshotsMap =
        object.getUnsafe("icons_and_screenshots").asObject().toNullable();
    if (packageScreenshotsMap == null) {
      if (kDebugMode) {
        print('"icons_and_screenshots" not an object');
      }
      return;
    }
    IList<String> screenshotKeys = packageScreenshotsMap.keys;
    List<MapEntry<String, PackageScreenshots>?> screenshotEntriesList =
        screenshotKeys
            .map<MapEntry<String, PackageScreenshots>?>((packageName) =>
                getEntryFromJson<MapEntry<String, PackageScreenshots>>(
                    packageName: packageName,
                    packageScreenshotsMap: packageScreenshotsMap,
                    fromJson: PackageScreenshots.getEntryFromJson))
            .toList();

    screenshotMap = Map<String, PackageScreenshots>.fromEntries(
        screenshotEntriesList.nonNulls);

    if (_prefs != null && _prefs!.getString(_packageScreenshotsKey) != data) {
      _prefs!.setString(_packageScreenshotsKey, data);
    }
  }

  T? getEntryFromJson<T>(
      {required String packageName,
      required JsonObject packageScreenshotsMap,
      required T Function(String packageName, JsonObject packageObject)
          fromJson}) {
    JsonObject? packageObject =
        packageScreenshotsMap.getUnsafe(packageName).asObject().toNullable();
    if (packageObject == null) {
      if (kDebugMode) {
        print('$packageName is not an object');
      }
      return null;
    }
    return fromJson(packageName, packageObject);
  }

  void loadScreenshots() {
    try {
      String data = _getStringFromSharedPreferences();
      screenshotsFromJson(data);
      if (kDebugMode) {
        print('stored data fetched');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> fetchWebScreenshots() async {
    try {
      String data = await _getStringFromWeb(screenshotsSource);
      screenshotsFromJson(data);
      if (kDebugMode) {
        print('web data fetched');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> fetchWebInvalidScreenshots() async {
    try {
      String data = await _getStringFromWeb(invalidScreenshotsSource);
      List<String> lines = data.split('\n');
      invalidScreenshotUrls = lines
          .map<Uri?>((e) => Uri.tryParse(e.trim()))
          .where((element) => element != null)
          .cast<Uri>()
          .toList();
      if (kDebugMode) {
        print('web data fetched');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> fetchScreenshots() async {
    await ensureInitialized();
    await fetchWebInvalidScreenshots();
    await Future.wait([
      //loadPublisherIcons(),
      loadPublisherJson(),
      fetchWebScreenshots(),
      loadCustomIcons(),
    ]);
    if (screenshotMap.isEmpty) {
      loadScreenshots();
    }
  }

  PackageScreenshots? getPackage(PackageInfos packageInfos) {
    if (screenshotMap.isEmpty && customIcons.isEmpty) {
      return null;
    }

    String? packageKey = _idToPackageKeyMap[packageInfos.id?.value];
    if (packageKey != null) {
      if (kDebugMode) {
        print(
            'found packageKey $packageKey for ${packageInfos.id?.value} in idToPackageKeyMap');
      }
      return screenshotMap[packageKey] ??
          customIcons[packageKey] ??
          customIcons[packageInfos.idFirstTwoParts];
    }

    return _guessPackageKey(packageInfos);
  }

  PackageScreenshots? _guessPackageKey(PackageInfos packageInfos) {
    for (String possibleKey in packageInfos.possibleScreenshotKeys) {
      PackageScreenshots? screenshots = screenshotMap[possibleKey];
      if (screenshots != null) {
        if (packageInfos.id != null) {
          _idToPackageKeyMap[packageInfos.id!.value] = possibleKey;
        }
        if (screenshots.icon != null ||
            screenshots.backupIcon != null ||
            screenshots.screenshots != null) {
          return screenshots;
        }
      }
    }
    if (packageInfos.id != null) {
      String id = packageInfos.id!.value;
      PackageScreenshots? screenshots = customIcons[id];
      if (screenshots != null) {
        _idToPackageKeyMap[id] = id;
      }
      return screenshots;
    }
    return null;
  }

  Future<void> loadCustomIcons() async {
    Iterable<String> lines = await loadLinesOfAsset('custom_icons.csv');
    for (String line in lines) {
      List<String> parts = _parseCsvLine(line);
      if (parts.length < 2) {
        continue;
      }
      String packageKey = parts[0];
      String iconUrl = parts[1];

      if (iconUrl.trim().isEmpty) {
        continue;
      }
      Uri? url = Uri.tryParse(iconUrl);
      if (url == null) {
        continue;
      }
      PackageScreenshots? found =
          getPackage(PackageInfosPeek.onlyId(packageKey));
      if (found == null) {
        customIcons[packageKey] =
            PackageScreenshots(packageKey: packageKey, icon: url);
        _idToPackageKeyMap[packageKey] = packageKey;
      } else {
        if (found.icon != null && found.icon.toString().trim().isNotEmpty) {
          found.backupIcon ??= found.icon;
        }
        found.icon = url;
      }
    }
  }

  Future<void> loadPublisherJson() async {
    String data = await loadAsset('publisher.json');
    if (data.isEmpty) {
      return;
    }
    publisherIcons = Publisher.parseJsonMap(data);
  }

  List<String> _parseCsvLine(String line) {
    return line.split(',');
  }

  bool _isHeaderCorrect(List<String> header, List<String> expected) {
    if (header.length != expected.length) {
      return false;
    }
    for (int i = 0; i < header.length; i++) {
      if (header[i] != expected[i]) {
        return false;
      }
    }
    return true;
  }

  Future<String> loadAsset(String fileName) async {
    return rootBundle.loadString('assets/$fileName');
  }

  Future<Iterable<String>> loadLinesOfAsset(String fileName) async {
    String string = await loadAsset(fileName);
    Iterable<String> lines = string.split('\n').map<String>((e) => e.trim());
    return lines;
  }

  Future<void> reloadPublisherIcons() async {
    publisherIcons.clear();
    await loadPublisherJson();
  }

  Future<void> reloadCustomIcons() async {
    customIcons.clear();
    await loadCustomIcons();
  }
}
