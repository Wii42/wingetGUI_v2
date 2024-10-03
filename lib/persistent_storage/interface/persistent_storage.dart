import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';

import 'bulk_storage.dart';
import 'key_value_storage.dart';

/// Persistent storage service, pure data layer, no business logic.
abstract class PersistentStorage {
  /// Initializes the persistent storage service.
  ///
  /// Must be called before any other method, otherwise they will throw an exception.
  Future<void> initialize();

  /// Whether the storage is initialized. If not, all other methods will throw an exception.
  bool get isInitialized;

  /// Map which maps package id's to another id which is used in the screenshot database.
  Future<Map<String, CustomIconKey>> loadCustomIconKeys();

  /// Loads custom defined package screenshots.
  Future<Map<String, PackageScreenshots>> loadCustomPackageScreenshots();

  /// Loads custom defined publisher icons and display names.
  Future<Map<String, JsonPublisher>> loadCustomPublisherData();

  /// Loads a list of package ids which are banned from the screenshot database,
  /// because their icon url in the database is invalid.
  Future<List<String>> loadBannedIcons();

  /// Stores package screenshots in the persistent storage.
  ///
  /// Faster than repeatedly fetching from Server.
  BulkMapStorage<String, PackageScreenshots> get packageScreenshots;

  /// Stores automatically fetched favicons in the persistent storage.
  KeyValueSyncStorage<String, Uri> get favicon;

  /// Stores automatically fetched publisher icons in the persistent storage.
  /// Key is the package id. Used if no publisher name is available.
  KeyValueSyncStorage<String, String> get publisherNameByPackageId;

  /// Stores automatically fetched publisher icons in the persistent storage.
  /// Key is the publisher id.
  KeyValueSyncStorage<String, String> get publisherNameByPublisherId;

  /// Stores all packages with an update available.
  ///
  /// Used to get the updates before Winget is called.
  BulkListStorage<PackageInfosPeek> get updatePackages;

  /// Stores all installed packages.
  ///
  /// Used to get the installed packages before Winget is called.
  BulkListStorage<PackageInfosPeek> get installedPackages;

  /// Stores all available packages.
  ///
  /// Used to get the available packages before Winget is called.
  BulkListStorage<PackageInfosPeek> get availablePackages;

  KeyValueSyncStorage<String, String> get settings;
}
