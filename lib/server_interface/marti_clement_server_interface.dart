import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/persistent_storage/web_fetcher.dart';
import 'package:winget_gui/server_interface/server_interface.dart';

class MartiClientServerInterface implements ServerInterface {
  WebFetcher webFetcher = WebFetcher();

  @override
  Future<List<Uri>> fetchInvalidImageUrlsFromServer() =>
      webFetcher.fetchInvalidImageUrlsFromMartiClimentRepo();

  @override
  Future<Map<String, PackageScreenshots>> fetchPackageScreenshotsFromServer() =>
      webFetcher.fetchPackageScreenshotsFromMartiClimentRepo();
}
