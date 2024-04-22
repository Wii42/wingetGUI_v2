import 'dart:collection';

import 'package:diacritic/diacritic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/db/package_db.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots_list.dart';

import 'info_with_link.dart';
import 'package_attribute.dart';
import 'package_id.dart';

class Publisher {
  final String? id;

  /// The name as provided by the manifest file.
  final String? fullName;

  /// The id but with spaces and dots, or if [id] is null, the name of the publisher.
  final String? nameFittingId;
  final Uri? icon;
  final Uri? website;

  Publisher({
    this.id,
    this.fullName,
    this.nameFittingId,
    this.icon,
    this.website,
  });

  factory Publisher.build({
    required PackageId? packageId,
    String? fullName,
    Uri? website,
    Iterable<String?> possiblePublisherNames = const [],
    Iterable<String?> anyPublisherNames = const [],
    bool isFullInfos = false,
  }) {
    return _PublisherBuilder(
      packageId: packageId,
      fullName: fullName,
      website: website,
      possiblePublisherNames: possiblePublisherNames,
      anyPublisherNames: anyPublisherNames,
      isFullInfos: isFullInfos,
    ).build();
  }

  /// Title under which the publisher is displayed, is not the publisher name.
  String title(AppLocalizations locale) =>
      PackageAttribute.publisher.title(locale);

  InfoWithLink? get infoWithLink {
    if (fullName == null && website == null) {
      return null;
    }
    return InfoWithLink(
      title: title,
      text: fullName,
      url: website,
    );
  }

  String? nameFromDBbyPublisherId() {
    return _PublisherBuilder.nameFromDBbyPublisherId(id);
  }

  static String? nameFromDBbyPackageId(PackageId? packageId) {
    if (packageId != null && packageId.string.isNotEmpty) {
      return PackageDB.instance.publisherNamesByPackageId[packageId.string];
    }
    return null;
  }

  /// Canonicalizes a string so it could match a publisher id.
  /// Removes all spaces, dots and commas and convert to lowercase.
  /// [customDiacritics] if true, use custom diacritics, like ä -> ae.
  static String canonicalize(String string, {bool customDiacritics = false}) {
    if (customDiacritics) {
      string = _replaceDiacriticsWithCustom(string);
    }
    string = removeDiacritics(string);
    return string.replaceAll(RegExp(r"[\s.,\-&'´’!?\\/|()]"), '').toLowerCase();
  }

  static String _replaceDiacriticsWithCustom(String string) {
    return string.replaceAllMapped(RegExp(r'[äöüÄÖÜ]'), (match) {
      return switch (match.group(0)!) {
        'ä' => 'ae',
        'ö' => 'oe',
        'ü' => 'ue',
        'Ä' => 'ae',
        'Ö' => 'oe',
        'Ü' => 'ue',
        _ => match.group(0)!
      };
    });
  }
}

class _PublisherBuilder {
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

  _PublisherBuilder({
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
        Publisher.nameFromDBbyPackageId(packageId);
    if (publisherName != null) {
      return publisherName;
    }
    String? reconstructedName = reconstructPublisherNameByCompareTo(
        [fullName, ...possiblePublisherNames]);
    if (publisherId == null && reconstructedName == null) {
      reconstructedName = fullName ?? anyPublisherNames.nonNulls.firstOrNull;
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
      return PackageDB.instance.publisherNamesByPublisherId[publisherId];
    }
    return null;
  }

  void savePublisherName(String? name) {
    if (name == null) {
      return;
    }
    if (publisherId != null) {
      PackageDB.instance.publisherNamesByPublisherId[publisherId!] = name;
    }
    if (packageId != null) {
      PackageDB.instance.publisherNamesByPackageId[packageId!.string] = name;
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
