import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/helpers/publisher.dart';
import 'package:winget_gui/helpers/screenshots_list_load_helper.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_screenshot_identifiers.dart';

import '../output_handling/package_infos/package_infos_peek.dart';

class PackageScreenshotsList with ScreenshotsListLoadHelper {
  static const String wingetUIScreenshotDatabaseUrl =
      'https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/screenshot-database-v2.json';
  static const String wingetUIInvalidScreenshotsUrl =
      "https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/invalid_urls.txt";
  static final Uri screenshotsSource = Uri.parse(wingetUIScreenshotDatabaseUrl);
  static final Uri invalidScreenshotsSource =
      Uri.parse(wingetUIInvalidScreenshotsUrl);
  static const String _packageScreenshotsKey = 'packagePictures';
  late final Logger log;

  SharedPreferences? _prefs;
  static final PackageScreenshotsList instance = PackageScreenshotsList._();
  Map<String, PackageScreenshots> screenshotMap = {};
  List<Uri> invalidScreenshotUrls = [];
  final Map<String, String> _idToPackageKeyMap = {};
  Map<String, Publisher> publisherIcons = {};
  Map<String, PackageScreenshots> customScreenshots = {};

  PackageScreenshotsList._() {
    log = Logger(this);
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

  void screenshotsFromWingetUIJson(String data) {
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
    for (PackageScreenshots screenshots in screenshotMap.values) {
      if (invalidScreenshotUrls.contains(screenshots.icon)) {
        screenshots.icon = null;
      }
      if (screenshots.screenshots != null) {
        screenshots.screenshots!
            .removeWhere((element) => invalidScreenshotUrls.contains(element));
      }
    }

    if (_prefs != null && _prefs!.getString(_packageScreenshotsKey) != data) {
      _prefs!.setString(_packageScreenshotsKey, data);
    }
  }

  void loadScreenshots() {
    try {
      String data = _getStringFromSharedPreferences();
      screenshotsFromWingetUIJson(data);
      log.info('stored data fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<void> fetchWebScreenshots() async {
    try {
      String data = await getStringFromWeb(screenshotsSource);
      screenshotsFromWingetUIJson(data);
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

  Future<void> fetchScreenshots() async {
    await ensureInitialized();
    await fetchWebInvalidScreenshots();
    await Future.wait([
      //loadPublisherIcons(),
      loadPublisherJson(),
      fetchWebScreenshots(),
      loadCustomPackageScreenshots(),
    ]);
    if (screenshotMap.isEmpty) {
      loadScreenshots();
    }
  }

  PackageScreenshots? getPackage(PackageInfos packageInfos) {
    if (screenshotMap.isEmpty && customScreenshots.isEmpty) {
      return null;
    }

    String? packageKey = _idToPackageKeyMap[packageInfos.id?.value];
    if (packageKey != null) {
      log.info(
          'found packageKey $packageKey for ${packageInfos.id?.value} in idToPackageKeyMap');

      return screenshotMap[packageKey] ??
          customScreenshots[packageKey] ??
          customScreenshots[packageInfos.idFirstTwoParts];
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
        if (screenshots.icon != null || screenshots.screenshots != null) {
          return screenshots;
        }
        if (screenshots.backup != null) {
          return screenshots.backup;
        }
      }
    }
    if (packageInfos.id != null) {
      String id = packageInfos.id!.value;
      PackageScreenshots? screenshots = customScreenshots[id];
      if (screenshots != null) {
        _idToPackageKeyMap[id] = id;
      }
      return screenshots;
    }
    return null;
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
        _idToPackageKeyMap[packageId] = packageId;
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
    publisherIcons = Publisher.parseJsonMap(data);
  }

  Future<String> loadAsset(String fileName) async {
    return rootBundle.loadString('assets/$fileName');
  }

  Future<Iterable<String>> loadLinesOfAsset(String fileName) async {
    String string = await loadAsset(fileName);
    Iterable<String> lines = string.split('\n').map<String>((e) => e.trim());
    return lines;
  }

  Future<void> reloadPublisher() async {
    publisherIcons.clear();
    await loadPublisherJson();
  }

  Future<void> reloadCustomScreenshots() async {
    customScreenshots.clear();
    await loadCustomPackageScreenshots();
  }
}

extension PublisherUsingDefaultSource on Publisher {
  String? get nameUsingDefaultSource =>
      nameUsingSource(PackageScreenshotsList.instance.publisherIcons);
  Uri? get iconUsingDefaultSource =>
      iconUsingSource(PackageScreenshotsList.instance.publisherIcons);
}
