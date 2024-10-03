import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_infos.dart';

/// Stored urls for package screenshots and icons.
///
/// Includes favicons both manually added and automatically fetched by using the app.
/// Includes also manually
abstract class PackagePictures {
  final Map<String, JsonPublisher> publisherIcons;
  PackageScreenshots? getPackage(PackageInfos packageInfos);

  /// Automatically fetched favicons while using app.
  final faviconsTable;

  PackagePictures({
    required this.publisherIcons,
    required this.faviconsTable,
  });
}

abstract class PublisherNames {
  final byPackageId;
  final byPublisherId;

  PublisherNames({required this.byPackageId, required this.byPublisherId});
}
