import 'package:winget_gui/helpers/package_screenshots.dart';

/// Service that provides a abstract Interface co communicate with the server,
/// at the moment the WingetUI Githhub repo of marticliment.
abstract class ServerInterface {
  /// Loads pacakge screenshots from  a server,
  /// at the moment from the WingetUI repo of marticliment.
  Future<Map<String, PackageScreenshots>> fetchPackageScreenshotsFromServer();

  /// Loads invalid image urls from a server,
  /// at the moment from the WingetUI repo of marticliment.
  Future<List<Uri>> fetchInvalidImageUrlsFromServer();
}

class ServerInterfaceService {
  static final ServerInterfaceService instance = ServerInterfaceService._();

  ServerInterfaceService._();

  static ServerInterface? _implementation;

  static void setImplementation(ServerInterface implementation) {
    _implementation = implementation;
  }

  Future<Map<String, PackageScreenshots>> fetchPackageScreenshotsFromServer() {
    _assertInitialized();
    return _implementation!.fetchPackageScreenshotsFromServer();
  }

  Future<List<Uri>> fetchInvalidImageUrlsFromServer() {
    _assertInitialized();
    return _implementation!.fetchInvalidImageUrlsFromServer();
  }

  void _assertInitialized() {
    if (_implementation == null) {
      throw Exception(
          'ServerInterfaceService not initialized, call setImplementation() first.');
    }
  }
}
