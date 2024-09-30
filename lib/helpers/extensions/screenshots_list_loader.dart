import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/persistent_storage_service.dart';
import 'package:winget_gui/server_interface/server_interface.dart';

import '../package_screenshots.dart';
import '../package_screenshots_list.dart';

extension ScreenshotsListLoader on PackageScreenshotsList {
  Future<void> screenshotsFromWingetUIJson(
      Map<String, PackageScreenshots> screenshots) async {
    screenshotMap = screenshots;
    await _removeBannedIconsFromScreenshotMap();
    _removeInvalidUrlsFromScreenshotMap();
    await _changeToCustomKeysInScreenshotMap();
    _removeEmptyScreenshotsFromScreenshotsMap();
  }

  Future<void> _changeToCustomKeysInScreenshotMap() async {
    Map<String, CustomIconKey> customIconKeys =
        await PersistentStorageService.instance.loadCustomIconKeys();
    for (String oldKey in customIconKeys.keys) {
      CustomIconKey customKeys = customIconKeys[oldKey]!;
      log.info(customKeys.toString());
      String? newKey = customKeys.newKey;
      if (screenshotMap.containsKey(oldKey)) {
        PackageScreenshots screenshots = screenshotMap[oldKey]!;
        if (newKey != null) {
          screenshotMap[newKey] = screenshots.copyWith(packageKey: newKey);
          screenshotMap.remove(oldKey);
        }
        if (customKeys.otherKeys.isNotEmpty) {
          for (String otherKey in customKeys.otherKeys) {
            screenshotMap[otherKey] =
                screenshots.copyWith(packageKey: otherKey);
          }
        }
      }
    }
  }

  Future<void> _removeBannedIconsFromScreenshotMap() async {
    List<String> bannedKeys =
        await PersistentStorageService.instance.loadBannedIcons();
    for (String key in bannedKeys) {
      screenshotMap.remove(key);
    }
  }

  void _removeInvalidUrlsFromScreenshotMap() {
    for (PackageScreenshots screenshots in screenshotMap.values) {
      if (invalidScreenshotUrls.contains(screenshots.icon)) {
        screenshots.icon = null;
      }
      if (screenshots.screenshots != null) {
        screenshots.screenshots!
            .removeWhere((element) => invalidScreenshotUrls.contains(element));
      }
    }
  }

  Future<void> loadScreenshots() async {
    try {
      Map<String, PackageScreenshots> data =
          await PersistentStorageService.instance.packageScreenshots.loadAll();
      log.warning('loaded data from storage', message: data.toString());
      await screenshotsFromWingetUIJson(data);
      log.info('stored data fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<void> fetchWebScreenshots() async {
    try {
      Map<String, PackageScreenshots> data = await ServerInterfaceService
          .instance
          .fetchPackageScreenshotsFromServer();
      await screenshotsFromWingetUIJson(data);
      await PersistentStorageService.instance.packageScreenshots
          .saveAll(screenshotMap);
      log.info('web data fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<void> fetchWebInvalidScreenshots() async {
    try {
      invalidScreenshotUrls = await ServerInterfaceService.instance
          .fetchInvalidImageUrlsFromServer();
      log.info('invalid icons fetched');
    } catch (e) {
      log.error(e.toString());
    }
  }

  Future<void> loadCustomPackageScreenshots() async {
    customScreenshots =
        await PersistentStorageService.instance.loadCustomPackageScreenshots();

    for (String packageId in customScreenshots.keys) {
      PackageScreenshots? found =
          getPackage(PackageInfosPeek.onlyId(packageId));
      if (found == null) {
        if (!packageId.endsWith('.*')) {
          idToPackageKeyMap[packageId] = packageId;
        }
      } else {
        found.backup ??= customScreenshots[packageId];
      }
    }
  }

  Future<void> loadPublisherJson() async {
    publisherIcons =
        await PersistentStorageService.instance.loadCustomPublisherData();
  }

  void _removeEmptyScreenshotsFromScreenshotsMap() {
    screenshotMap.removeWhere(
      (key, value) {
        return (value.icon == null &&
            (value.screenshots == null || value.screenshots!.isEmpty) &&
            value.backup == null);
      },
    );
  }
}

class CustomIconKey {
  final String oldKey;
  final String? newKey;
  final List<String> otherKeys;

  CustomIconKey({required this.oldKey, this.newKey, this.otherKeys = const []});

  factory CustomIconKey.fromJson(Map<String, dynamic> json, String key) {
    List<dynamic> otherKeys = json['other_keys'] ?? const [];
    return CustomIconKey(
      oldKey: key,
      newKey: json['new_key'],
      otherKeys: otherKeys.cast<String>(),
    );
  }

  @override
  String toString() {
    return 'CustomIconKey{oldKey: $oldKey, newKey: $newKey, otherKeys: $otherKeys}';
  }
}
