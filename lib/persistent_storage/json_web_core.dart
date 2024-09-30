import 'package:http/http.dart';
import 'package:ribs_core/ribs_core.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

/// Helper class for parsing PackageScreenshots and getting string from web.
///
/// Intentionally not using any Flutter dependencies, so it can be used in Dart scripts.
class JsonWebCore {
  static final Logger log = Logger(null, sourceType: JsonWebCore);

  Future<String> getStringFromWeb(Uri url) async {
    Response request = await get(url);
    return request.body;
  }

  Map<String, PackageScreenshots> parseScreenshotsMap(JsonObject jsonObject) {
    IList<String> screenshotKeys = jsonObject.keys;
    List<MapEntry<String, PackageScreenshots>?> screenshotEntriesList =
        screenshotKeys
            .map<MapEntry<String, PackageScreenshots>?>((packageName) =>
                getEntryFromJson<MapEntry<String, PackageScreenshots>>(
                    packageName: packageName,
                    packageScreenshotsMap: jsonObject,
                    fromJson: PackageScreenshots.getScreenshotsEntryFromJson))
            .toList();

    return Map<String, PackageScreenshots>.fromEntries(
        screenshotEntriesList.nonNulls);
  }

  T? getEntryFromJson<T>(
      {required String packageName,
      required JsonObject packageScreenshotsMap,
      required T Function(String packageName, JsonObject packageObject)
          fromJson}) {
    JsonObject? packageObject =
        packageScreenshotsMap.getUnsafe(packageName).asObject().toNullable();
    if (packageObject == null) {
      log.error('$packageName is not an object');
      return null;
    }
    return fromJson(packageName, packageObject);
  }

  Future<Map<String, PackageScreenshots>>
      parseScreenshotsMapFromMartiClimentRepo(String data) async {
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
    if (!object.contains("icons_and_screenshots")) {
      log.error('json does not contain icons_and_screenshots');
      return {};
    }
    JsonObject? packageScreenshotsMap =
        object.getUnsafe("icons_and_screenshots").asObject().toNullable();
    if (packageScreenshotsMap == null) {
      log.error('"icons_and_screenshots" not an object');
      return {};
    }
    return parseScreenshotsMap(packageScreenshotsMap);
  }
}
