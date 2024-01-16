import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:ribs_core/ribs_core.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_screenshot_identifiers.dart';

import '../output_handling/package_infos/package_infos_peek.dart';

class PackageScreenshotsList {
  static const String wingetUIScreenshotDatabaseUrl =
      'https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/screenshot-database-v2.json';
  static final Uri source = Uri.parse(wingetUIScreenshotDatabaseUrl);
  static const String _packageScreenshotsKey = 'packagePictures';
  SharedPreferences? _prefs;
  static final PackageScreenshotsList instance = PackageScreenshotsList._();

  Map<String, PackageScreenshots> screenshotMap = {};
  final Map<String, String> _idToPackageKeyMap = {};

  Map<String, Uri> publisherIcons = {};
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

  Future<String> _getStringFromWeb() async {
    Response request = await get(source);
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
      String data = await _getStringFromWeb();
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

  Future<void> fetchScreenshots() async {
    await ensureInitialized();
    await loadPublisherIcons();
    loadScreenshots();
    await fetchWebScreenshots();
    await loadCustomIcons();
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
      return screenshotMap[packageKey] ?? customIcons[packageKey];
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
        if(screenshots.icon != null || screenshots.backupIcon != null || screenshots.screenshots != null) {
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
    Iterable<String> lines = await loadAsset('custom_icons.csv');
    for (String line in lines) {
      List<String> parts = line.split(',');
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

  Future<void> loadPublisherIcons() async {
    Iterable<String> lines = await loadAsset('publisher_icons.csv');
    for (String line in lines) {
      List<String> parts = line.split(',');
      if (parts.length < 2) {
        continue;
      }
      String publisher = parts[0];
      String iconUrl = parts[1];

      if (iconUrl.trim().isEmpty) {
        continue;
      }
      Uri? url = Uri.tryParse(iconUrl);
      if (url == null) {
        continue;
      }

      publisherIcons[publisher] = url;
    }
  }

  Future<Iterable<String>> loadAsset(String fileName) async {
    String string = await rootBundle.loadString('assets/$fileName');
    Iterable<String> lines = string.split('\n').map<String>((e) => e.trim());
    return lines;
  }
}
