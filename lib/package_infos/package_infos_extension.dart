import 'package:persistent_storage_interface/service.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';
import 'package:winget_gui/package_infos/publisher.dart';
import 'package:winget_gui/package_sources/ms_store_source.dart';
import 'package:winget_gui/package_sources/package_source.dart';
import 'package:winget_gui/package_sources/winget_source.dart';

extension PackageInfosExtension on PackageInfos {
  PackageSource? get packageSource {
    if (isMicrosoftStore()) {
      return MSStoreSource(this);
    }
    if (isWinget()) {
      return WingetSource(this);
    }
    return null;
  }

  Info<Uri>? get manifest {
    Uri? manifestUrl = packageSource?.manifestUrl;
    if (manifestUrl == null) {
      return null;
    }
    return Info<Uri>.fromAttribute(
      PackageAttribute.manifest,
      value: manifestUrl,
    );
  }

  String? versionWithoutEllipsis() => _withoutEllipsis(version?.toStringInfo());

  String? _withoutEllipsis(Info<String>? info) {
    if (info == null) {
      return null;
    }
    if (info.value.endsWith('…')) {
      return info.value.substring(0, info.value.length - 1);
    }
    return info.value;
  }

  void setImplicitInfos() {
    PackageScreenshotsList screenshotsList = PackageScreenshotsList.instance;
    screenshots = screenshotsList.getPackage(this);
    checkedForScreenshots = true;
    if (id != null) {
      automaticFoundFavicons =
          PersistentStorageService.instance.favicon[id!.value.string];
    }
  }

  void setPublisher({
    String? fullName,
    Uri? publisherWebsite,
    bool isFullInfos = false,
  }) {
    publisher ??=
        PublisherBuilder(
          packageId: id?.value,
          fullName: fullName,
          website: publisherWebsite,
          possiblePublisherNames: possiblePublisherNames,
          anyPublisherNames: anyPublisherNames,
          isFullInfos: isFullInfos,
        ).build();
  }
}
