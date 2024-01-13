import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/package_infos/package_screenshot_identifiers.dart';

class PackageScreenshotsList {
  static const String _packageScreenshotsKey = 'packagePictures';
  late final Uri source;
  SharedPreferences? _prefs;
  static final PackageScreenshotsList instance = PackageScreenshotsList._();

  List<PackageScreenshots> screenshotList = [];
  Map<String, PackageScreenshots>? _keyMap;
  final Map<String, String> _idToPackageKeyMap = {};

  Map<String, Uri> publisherIcons = {};

  PackageScreenshotsList._() {
    source = Uri.parse(
        'https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/screenshot-database-v2.json');
  }

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

    screenshotList = packageScreenshotsMap.keys
        .map<PackageScreenshots?>((packageName) {
          JsonObject? packageObject = packageScreenshotsMap
              .getUnsafe(packageName)
              .asObject()
              .toNullable();
          if (packageObject == null) {
            if (kDebugMode) {
              print('$packageName is not an object');
            }
            return null;
          }
          return PackageScreenshots.fromJson(packageName, packageObject);
        })
        .toList()
        .nonNulls
        .toList();

    if (_prefs != null && _prefs!.getString(_packageScreenshotsKey) != data) {
      _prefs!.setString(_packageScreenshotsKey, data);
    }
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
    loadScreenshots();
    await fetchWebScreenshots();
    await loadCustomIcons();
  }

  PackageScreenshots? getPackage(PackageInfos packageInfos) {
    if (screenshotList.isEmpty) {
      return null;
    }

    String? packageKey = _idToPackageKeyMap[packageInfos.id?.value];
    if (packageKey != null) {
      if (kDebugMode) {
        print(
            'found packageKey $packageKey for ${packageInfos.id?.value} in idToPackageKeyMap');
      }
      return keyMap[packageKey];
    }

    return _guessPackageKey(packageInfos);
  }

  PackageScreenshots? _guessPackageKey(PackageInfos packageInfos) {
    List<String?> possibleKeys = [
      packageInfos.id?.value,
      packageInfos.nameWithoutVersion,
      packageInfos.nameWithoutPublisherIDAndVersion,
      packageInfos.idWithHyphen,
      packageInfos.idWithoutPublisherID,
      packageInfos.idWithoutPublisherIDAndHyphen,
      if(packageInfos.idWithoutPublisherIDAndHyphen != null && packageInfos.idWithoutPublisherIDAndHyphen!.endsWith('-eap'))
        ...['${packageInfos.idWithoutPublisherIDAndHyphen!.substring(0, packageInfos.idWithoutPublisherIDAndHyphen!.length - 4)}-earlyaccess','${packageInfos.idWithoutPublisherIDAndHyphen!.substring(0, packageInfos.idWithoutPublisherIDAndHyphen!.length - 4)}-earlypreview',],
    ];
    //print('Looking for ${possibleKeys.join(', ')}');

    for (String possibleKey in possibleKeys.nonNulls) {
      PackageScreenshots? screenshots = keyMap[possibleKey];
      if (screenshots != null) {
        if (packageInfos.id != null) {
          _idToPackageKeyMap[packageInfos.id!.value] = possibleKey;
        }
        return screenshots;
      }
    }
    return null;
  }

  Map<String, PackageScreenshots> get keyMap {
    if (_keyMap == null) {
      _updateKeyMap();
    }
    return _keyMap!;
  }

  void _updateKeyMap() {
    _keyMap = {};
    for (PackageScreenshots screenshots in screenshotList) {
      if (_keyMap!.containsKey(screenshots.packageKey)) {
        throw Exception(
            'Duplicate package key: ${screenshots.packageKey} in PackageScreenshotsList.keyMap');
      }
      _keyMap![screenshots.packageKey] = screenshots;
    }
  }

  Future<void> loadCustomIcons() async {
    File customIconsFile = File('custom_icons.csv');
    List<String> lines = await customIconsFile.readAsLines();
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
        PackageScreenshots packageIcon =
            PackageScreenshots(packageKey: packageKey, icon: url);
        screenshotList.add(packageIcon);
        _keyMap![packageKey] = packageIcon;
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
    File customIconsFile = File('publisher_icons.csv');
    List<String> lines = await customIconsFile.readAsLines();
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
}
