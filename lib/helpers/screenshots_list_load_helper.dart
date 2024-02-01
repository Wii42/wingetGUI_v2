import 'package:http/http.dart';
import 'package:ribs_core/ribs_core.dart';
import 'package:ribs_json/ribs_json.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';

mixin class ScreenshotsListLoadHelper {
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
      // ignore: avoid_print
      print('$packageName is not an object');

      return null;
    }
    return fromJson(packageName, packageObject);
  }
}
