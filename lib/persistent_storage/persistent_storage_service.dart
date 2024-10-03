import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/interface/persistent_storage.dart';

import 'interface/bulk_storage.dart';
import 'interface/key_value_storage.dart';

class PersistentStorageService implements PersistentStorage {
  static PersistentStorageService instance = PersistentStorageService._();
  PersistentStorageService._();

  PersistentStorage? _implementation;

  static void setImplementation(PersistentStorage implementation) {
    instance._implementation = implementation;
  }

  static Future<void> initializeImplementation(
      PersistentStorage implementation) {
    setImplementation(implementation);
    return instance.initialize();
  }

  @override
  BulkListStorage<PackageInfosPeek> get availablePackages {
    _assertInitialized();
    return _implementation!.availablePackages;
  }

  @override
  KeyValueSyncStorage<String, Uri> get favicon {
    _assertInitialized();
    return _implementation!.favicon;
  }

  @override
  Future<void> initialize() {
    _assertHasImplementation();
    return _implementation!.initialize();
  }

  @override
  BulkListStorage<PackageInfosPeek> get installedPackages {
    _assertInitialized();
    return _implementation!.installedPackages;
  }

  @override
  Future<List<String>> loadBannedIcons() {
    _assertInitialized();
    return _implementation!.loadBannedIcons();
  }

  @override
  Future<Map<String, CustomIconKey>> loadCustomIconKeys() {
    _assertInitialized();
    return _implementation!.loadCustomIconKeys();
  }

  @override
  Future<Map<String, PackageScreenshots>> loadCustomPackageScreenshots() {
    _assertInitialized();
    return _implementation!.loadCustomPackageScreenshots();
  }

  @override
  Future<Map<String, JsonPublisher>> loadCustomPublisherData() {
    _assertInitialized();
    return _implementation!.loadCustomPublisherData();
  }

  @override
  BulkMapStorage<String, PackageScreenshots> get packageScreenshots {
    _assertInitialized();
    return _implementation!.packageScreenshots;
  }

  @override
  KeyValueSyncStorage<String, String> get publisherNameByPackageId {
    _assertInitialized();
    return _implementation!.publisherNameByPackageId;
  }

  @override
  KeyValueSyncStorage<String, String> get publisherNameByPublisherId {
    _assertInitialized();
    return _implementation!.publisherNameByPublisherId;
  }

  @override
  BulkListStorage<PackageInfosPeek> get updatePackages {
    _assertInitialized();
    return _implementation!.updatePackages;
  }

  void _assertInitialized() {
    _assertHasImplementation();
    if (!isInitialized) {
      throw Exception('PersistentStorageService not initialized: '
          'Make sure to call PersistentStorageService.initializeImplementation() beforehand');
    }
  }

  void _assertHasImplementation() {
    if (_implementation == null) {
      throw Exception('PersistentStorageService not initialized: '
          'Make sure to call PersistentStorageService.setImplementation() beforehand');
    }
  }

  @override
  bool get isInitialized =>
      _implementation != null && _implementation!.isInitialized;

  @override
  KeyValueSyncStorage<String, String> get settings => _implementation!.settings;
}
