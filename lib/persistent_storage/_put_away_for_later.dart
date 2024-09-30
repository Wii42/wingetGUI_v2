import 'package:winget_gui/db/favicon_table.dart';
import 'package:winget_gui/db/publisher_name_table.dart';
import 'package:winget_gui/db/winget_table.dart';
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
  final FaviconTable faviconsTable;

  PackagePictures({
    required this.publisherIcons,
    required this.faviconsTable,
  });
}

abstract class PublisherNames {
  final PublisherNameTable byPackageId;
  final PublisherNameTable byPublisherId;

  PublisherNames({required this.byPackageId, required this.byPublisherId});
}

abstract class PackageTables {
  final WingetDBTable updates;
  final WingetDBTable installed;
  final WingetDBTable available;

  PackageTables(
      {required this.updates,
        required this.installed,
        required this.available});
}