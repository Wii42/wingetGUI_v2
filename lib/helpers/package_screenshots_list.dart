import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_screenshot_identifiers.dart';

import 'extensions/screenshots_list_loader.dart';
import 'json_publisher.dart';
import 'log_stream.dart';
import 'package_screenshots.dart';
import 'screenshots_list_load_helper.dart';

class PackageScreenshotsList with ScreenshotsListLoadHelper {
  late final Logger log;

  SharedPreferences? _prefs;
  static final PackageScreenshotsList instance = PackageScreenshotsList._();
  Map<String, PackageScreenshots> screenshotMap = {};
  List<Uri> invalidScreenshotUrls = [];
  final Map<String, String> idToPackageKeyMap = {};
  Map<String, JsonPublisher> publisherIcons = {};
  Map<String, PackageScreenshots> customScreenshots = {};

  PackageScreenshotsList._() {
    log = Logger(this);
  }

  Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @visibleForTesting
  void setMockSharedPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  SharedPreferences? get prefs => _prefs;

  Future<void> fetchScreenshots() async {
    await ensureInitialized();
    await fetchWebInvalidScreenshots();
    await Future.wait([
      //loadPublisherIcons(),
      loadPublisherJson(),
      fetchWebScreenshots(),
      loadCustomPackageScreenshots(),
    ]);
    if (screenshotMap.isEmpty) {
      await loadScreenshots();
    }
  }

  PackageScreenshots? getPackage(PackageInfos packageInfos) {
    if (screenshotMap.isEmpty && customScreenshots.isEmpty) {
      return null;
    }

    String? packageKey = idToPackageKeyMap[packageInfos.id?.value.string];
    if (packageKey != null) {
      log.info(
          'found packageKey $packageKey for ${packageInfos.id?.value} in idToPackageKeyMap');

      return screenshotMap[packageKey] ??
          customScreenshots[packageKey] ??
          customScreenshots[packageInfos.idFirstTwoParts];
    }

    return _guessPackageKey(packageInfos);
  }

  PackageScreenshots? _guessPackageKey(PackageInfos packageInfos) {
    for (String possibleKey in packageInfos.possibleScreenshotKeys) {
      PackageScreenshots? screenshots = screenshotMap[possibleKey];
      if (screenshots != null) {
        if (packageInfos.id != null) {
          idToPackageKeyMap[packageInfos.id!.value.string] = possibleKey;
        }
        if (screenshots.icon != null || screenshots.screenshots != null) {
          return screenshots;
        }
        if (screenshots.backup != null) {
          return screenshots.backup;
        }
      }
    }
    if (packageInfos.id != null) {
      String id = packageInfos.id!.value.string;
      PackageScreenshots? screenshots = customScreenshots[id];
      if (screenshots != null) {
        idToPackageKeyMap[id] = id;
      } else {
        for (String possibleKey in packageInfos.idWithWildcards) {
          PackageScreenshots? possibleScreenshots =
              customScreenshots[possibleKey];
          if (possibleScreenshots != null) {
            idToPackageKeyMap[id] = possibleKey;
            return possibleScreenshots;
          }
        }
      }
      return screenshots;
    }
    return null;
  }

  Future<void> reloadPublisher() async {
    publisherIcons.clear();
    await loadPublisherJson();
  }

  Future<void> reloadCustomScreenshots() async {
    customScreenshots.clear();
    await loadCustomPackageScreenshots();
  }
}

extension PublisherUsingDefaultSource on JsonPublisher {
  String? get nameUsingDefaultSource =>
      nameUsingSource(PackageScreenshotsList.instance.publisherIcons);
  Uri? get iconUsingDefaultSource =>
      iconUsingSource(PackageScreenshotsList.instance.publisherIcons);
  Uri? get solidIconUsingDefaultSource =>
      solidIconUsingSource(PackageScreenshotsList.instance.publisherIcons);
}
