// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:winget_core/winget_core.dart';

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
