import 'package:winget_gui/helpers/package_screenshots.dart';

import 'json_web_core.dart';

class WebFetcher {
  JsonWebCore jsonWebCore = JsonWebCore();

  //static final Logger log = Logger(null, sourceType: WebFetcher);

  static const String wingetUIScreenshotDatabaseUrl =
      'https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/screenshot-database-v2.json';
  static const String wingetUIInvalidScreenshotsUrl =
      "https://raw.githubusercontent.com/marticliment/WingetUI/main/WebBasedData/invalid_urls.txt";
  static final Uri screenshotsSource = Uri.parse(wingetUIScreenshotDatabaseUrl);
  static final Uri invalidScreenshotsSource =
      Uri.parse(wingetUIInvalidScreenshotsUrl);

  /// Fetches invalid image URLs from the marticliment/wingetUI GithHub repo.
  Future<List<Uri>> fetchInvalidImageUrlsFromMartiClimentRepo() async {
    String data = await jsonWebCore.getStringFromWeb(invalidScreenshotsSource);
    List<String> lines = data.split('\n');
    return lines
        .map<Uri?>((e) => Uri.tryParse(e.trim()))
        .where((element) => element != null)
        .cast<Uri>()
        .toList();
  }

  Future<Map<String, PackageScreenshots>>
      fetchPackageScreenshotsFromMartiClimentRepo() async {
    String data = await jsonWebCore.getStringFromWeb(screenshotsSource);
    return jsonWebCore.parseScreenshotsMapFromMartiClimentRepo(data);
  }

  Future<String> fetchPackageScreenshotsFromMartiClimentRepoRaw() async {
    return jsonWebCore.getStringFromWeb(screenshotsSource);
  }
}
