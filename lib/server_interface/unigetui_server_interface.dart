import 'dart:developer';

import 'package:ribs_json/ribs_json.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/server_interface/server_interface.dart';

/// Service that provides a concrete implementation of the ServerInterface
/// to communicate with the server, at the moment the UniGetUI GitHub repo from Devolutions.
/// Url: [https://github.com/Devolutions/UniGetUI]
class UniGetUIServerInterface implements ServerInterface {
  JsonWebCore jsonWebCore = JsonWebCore();

  static const String uniGetUIScreenshotDatabaseUrl =
      'https://raw.githubusercontent.com/Devolutions/UniGetUI/refs/heads/main/WebBasedData/screenshot-database-v2.json';
  static final Uri screenshotsSource = Uri.parse(uniGetUIScreenshotDatabaseUrl);

  @override
  /// Returns an empty list, as a list of invalid image urls is no longer provided.
  Future<List<Uri>> fetchInvalidImageUrlsFromServer() => Future.value([]);

  @override
  Future<Map<String, PackageScreenshots>>
  fetchPackageScreenshotsFromServer() async {
    String data = await fetchPackageScreenshotsFromUniGetUIRepoRaw();
    return parseScreenshotsMapFromUniGetUIRepo(data);
  }

  Future<String> fetchPackageScreenshotsFromUniGetUIRepoRaw() async {
    return jsonWebCore.getStringFromWeb(screenshotsSource);
  }

  Future<Map<String, PackageScreenshots>> parseScreenshotsMapFromUniGetUIRepo(
    String data,
  ) async {
    Json json = Json.parse(data).getOrElse(() {
      throw Exception('Error parsing JSON');
    });
    JsonObject? object = json.asObject().toNullable();
    if (object == null) {
      log('Json is not an object');
      return {};
    }
    if (!object.contains("icons_and_screenshots")) {
      log('json does not contain icons_and_screenshots');
      return {};
    }
    JsonObject? packageScreenshotsMap =
        object.getUnsafe("icons_and_screenshots").asObject().toNullable();
    if (packageScreenshotsMap == null) {
      log('"icons_and_screenshots" not an object');
      return {};
    }
    return jsonWebCore.parseScreenshotsMap(packageScreenshotsMap);
  }
}
