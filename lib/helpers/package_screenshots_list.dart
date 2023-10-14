import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart';
import 'package:ribs_core/ribs_core.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';

class PackageScreenshotsList {
  static const String _packageScreenshotsKey = 'packagePictures';
  late final Uri source;
  SharedPreferences? _prefs;
  static final PackageScreenshotsList instance = PackageScreenshotsList._();

  List<PackageScreenshots> screenshotList = [];

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
    JsonObject? object = json.asObject.toNullable();
    if (object == null) {
      print('Json is not an object');
      return;
    }
    if (!object.contains("icons_and_screenshots")) {
      print('json does not contain icons_and_screenshots');
      return;
    }
    JsonObject? packageScreenshotsMap =
        object.applyUnsafe("icons_and_screenshots").asObject.toNullable();
    if (packageScreenshotsMap == null) {
      print('"icons_and_screenshots" not an object');
      return;
    }

    screenshotList = packageScreenshotsMap.keys
        .map<PackageScreenshots?>((packageName) {
          JsonObject? packageObject = packageScreenshotsMap
              .applyUnsafe(packageName)
              .asObject
              .toNullable();
          if (packageObject == null) {
            print('$packageName is not an object');
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
      print('stored data fetched');
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchWebScreenshots() async {
    try {
      String data = await _getStringFromWeb();
      screenshotsFromJson(data);
      print('web data fetched');
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchScreenshots() async {
    await ensureInitialized();
    loadScreenshots();
    await fetchWebScreenshots();
  }

  PackageScreenshots? getPackage(PackageInfos packageInfos) {
    if (screenshotList.isEmpty) {
      return null;
    }
    print(
        'searching for screenshot with ${packageInfos.nameWithoutVersion}, ${packageInfos.nameWithoutPublisherIDAndVersion}, ${packageInfos.idWithHyphen}, ${packageInfos.id?.value}');
    List<bool Function(PackageScreenshots)> conditions = [
      (element) => element.packageKey == packageInfos.nameWithoutVersion,
      (element) =>
          element.packageKey == packageInfos.nameWithoutPublisherIDAndVersion,
      (element) => element.packageKey == packageInfos.idWithHyphen,
    (element) => element.packageKey == packageInfos.idWithoutPublisherID,
      (element) => element.packageKey == packageInfos.id?.value,
    ];
    for (bool Function(PackageScreenshots) condition in conditions) {
      if (screenshotList.any(condition)) {
        return screenshotList.firstWhere(condition);
      }
    }
    print('no screenshot found for ${packageInfos.name?.value}');
    return null;
  }
}
