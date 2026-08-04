import 'package:winget_core/winget_core.dart';

/// Service that provides a abstract Interface to communicate with the server,
/// at the moment the UniGetUI GitHub repo from Devolutions.
abstract class ServerInterface {
  /// Loads package screenshots from  a server,
  /// at the moment from the UniGetUI repo from Devolutions.
  Future<Map<String, PackageScreenshots>> fetchPackageScreenshotsFromServer();

  /// Loads invalid image urls from a server,
  /// at the moment from the UniGetUI repo from Devolutions.
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
        'ServerInterfaceService not initialized, call setImplementation() first.',
      );
    }
  }
}
