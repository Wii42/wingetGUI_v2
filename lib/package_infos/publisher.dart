import 'dart:collection';

import 'package:persistent_storage_interface/service.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';

extension PublisherHelper on Publisher {


  String? nameFromDBbyPublisherId() {
    return PublisherBuilder.nameFromDBbyPublisherId(id);
  }

  static String? nameFromDBbyPackageId(PackageId? packageId) {
    if (packageId != null && packageId.string.isNotEmpty) {
      return PersistentStorageService
          .instance.publisherNameByPackageId[packageId.string];
    }
    return null;
  }
}

class PublisherBuilder {
  PackageId? packageId;
  String? publisherId;
  String? fullName;
  String? nameFittingId;
  Uri? icon;
  Uri? website;
  bool isFullInfos;

  /// Names which are matched against the publisher id.
  Iterable<String?> possiblePublisherNames;

  /// If the publisher id is null, the first non-null name is used.
  Iterable<String?> anyPublisherNames;

  PublisherBuilder({
    this.packageId,
    this.fullName,
    this.website,
    this.possiblePublisherNames = const [],
    this.anyPublisherNames = const [],
    this.isFullInfos = false,
  });

  Publisher build() {
    publisherId ??= packageId?.probablyPublisherId();
    nameFittingId ??= fetchName();
    icon ??= fetchIcon();
    return Publisher(
      id: publisherId,
      fullName: fullName,
      nameFittingId: nameFittingId,
      icon: icon,
      website: website,
    );
  }

  String? fetchName() {
    String? publisherName = PackageScreenshotsList
            .instance
            .publisherIcons[packageId?.probablyPublisherId()]
            ?.nameUsingDefaultSource ??
        nameFromDBbyPublisherId(publisherId) ??
        PublisherHelper.nameFromDBbyPackageId(packageId);
    if (publisherName != null) {
      return publisherName;
    }
    String? reconstructedName = reconstructPublisherNameByCompareTo(
        [fullName, ...possiblePublisherNames]);
    if (publisherId == null) {
      reconstructedName ??= fullName ??
          anyPublisherNames.nonNulls.firstOrNull ??
          reconstructFromWebsite();
    }
    if (reconstructedName != null) {
      publisherName = reconstructedName;
      if (isFullInfos) {
        savePublisherName(publisherName);
      }
    }
    return publisherName;
  }

  /// Try to guess the correct spaces and dots in the publisher name.
  String? reconstructPublisherNameByCompareTo(Iterable<String?> otherNames) {
    List<String> names =
        otherNames.nonNulls.where((element) => element.isNotEmpty).toList();
    int lengthFullNames = names.length;
    addPartialNames(names);
    if (names.isEmpty || packageId?.probablyPublisherId() == null) {
      return null;
    }
    String? publisherID =
        Publisher.canonicalize(packageId!.probablyPublisherId()!);
    for ((int, String) indexedName in names.indexed) {
      String name = indexedName.$2;
      int index = indexedName.$1;
      String nameAsId = Publisher.canonicalize(name);
      if (nameAsId == publisherID) {
        name = _stripOfEndingChars(name, index, lengthFullNames);
        return name;
      }
      String nameAsIdCustom =
          Publisher.canonicalize(name, customDiacritics: true);
      if (nameAsIdCustom == publisherID) {
        name = _stripOfEndingChars(name, index, lengthFullNames);
        return name;
      }
    }
    return null;
  }

  String? reconstructFromWebsite() => website?.host;

  String _stripOfEndingChars(String name, int index, int lengthFullNames) {
    if (index < lengthFullNames) {
      return name;
    }
    if (name.contains(RegExp(r'[a-zA-Z0-9],$'))) {
      name = name.take(name.length - 1);
    }
    if (name.contains(RegExp(r'[a-zA-Z0-9]\s&$'))) {
      name = name.take(name.length - 2);
    }
    return name;
  }

  /// Add all partial names, e.g. "Microsoft Corporation Ltd." -> ["Microsoft Corporation", "Microsoft"]
  void addPartialNames(List<String> names) {
    LinkedHashSet<String> partNames = LinkedHashSet();
    for (String name in names) {
      Iterable<String> parts = name.split(' ');
      if (parts.length > 1) {
        for (int i = parts.length - 1; i > 1; i--) {
          String partName = parts.take(i).join(' ');
          partNames.add(partName);
        }
      }
    }
    names.addAll(partNames.where((element) => element.isNotEmpty));
  }

  static String? nameFromDBbyPublisherId(String? publisherId) {
    if (publisherId != null) {
      return PersistentStorageService
          .instance.publisherNameByPublisherId[publisherId];
    }
    return null;
  }

  void savePublisherName(String? name) {
    if (name == null) {
      return;
    }
    if (publisherId != null) {
      PersistentStorageService
          .instance.publisherNameByPublisherId[publisherId!] = name;
    }
    if (packageId != null) {
      PersistentStorageService
          .instance.publisherNameByPackageId[packageId!.string] = name;
    }
  }

  Uri? fetchIcon() {
    PackageScreenshotsList screenshotsList = PackageScreenshotsList.instance;
    JsonPublisher? publisher =
        screenshotsList.publisherIcons[packageId?.probablyPublisherId()] ??
            screenshotsList.publisherIcons[nameFittingId];
    return publisher?.iconUsingDefaultSource;
  }
}
