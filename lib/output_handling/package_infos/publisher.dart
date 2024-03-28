import 'dart:collection';

import 'package:diacritic/diacritic.dart';
import 'package:winget_gui/output_handling/package_infos/info_with_link.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/json_publisher.dart';
import '../../helpers/package_screenshots_list.dart';
import '../../package_sources/package_source.dart';
import '../../widget_assets/favicon_db.dart';

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
    required String? packageId,
    String? fullName,
    Uri? website,
    Iterable<String?> possiblePublisherNames = const [],
    Iterable<String?> anyPublisherNames = const [],
    PackageSources source = PackageSources.none,
    bool isFullInfos = false,
  }) {
    return _PublisherBuilder(
      packageId: packageId,
      fullName: fullName,
      website: website,
      possiblePublisherNames: possiblePublisherNames,
      anyPublisherNames: anyPublisherNames,
      source: source,
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

  static String? nameFromDBbyPackageId(String? packageId) {
    if (packageId != null) {
      return FaviconDB.instance.publisherNamesByPackageId.getEntry(packageId);
    }
    return null;
  }
}

class _PublisherBuilder {
  String? packageId;
  String? publisherId;
  String? fullName;
  String? nameFittingId;
  Uri? icon;
  Uri? website;
  PackageSources source;
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
    this.source = PackageSources.none,
    this.isFullInfos = false,
  });

  Publisher build() {
    publisherId ??=
        (source == PackageSources.winget ? probablyPublisherID() : null);
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
    String? publisherName = PackageScreenshotsList.instance
            .publisherIcons[probablyPublisherID()]?.nameUsingDefaultSource ??
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

  String? probablyPublisherID() {
    String? publisherId = packageId;
    if (publisherId == null) {
      return null;
    }
    if (publisherId.contains('.')) {
      return publisherId.split('.').first;
    }
    if (publisherId.trim().contains(' ')) {
      return publisherId.trim().split(' ').first;
    }
    return null;
  }

  /// Try to guess the correct spaces and dots in the publisher name.
  String? reconstructPublisherNameByCompareTo(Iterable<String?> otherNames) {
    List<String> names =
        otherNames.nonNulls.where((element) => element.isNotEmpty).toList();
    addPartialNames(names);
    if (names.isEmpty || probablyPublisherID() == null) {
      return null;
    }
    String? publisherID = _canonicalize(probablyPublisherID()!);
    for (String name in names) {
      String nameAsId = _canonicalize(name);
      if (nameAsId == publisherID) {
        return name;
      }
      String nameAsIdCustom = _canonicalize(name, customDiacritics: true);
      if (nameAsIdCustom == publisherID) {
        return name;
      }
    }
    return null;
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

  ///remove all spaces, dots and commas and convert to lowercase.
  /// [customDiacritics] if true, use custom diacritics, like ä -> ae.
  String _canonicalize(String string, {bool customDiacritics = false}) {
    if (customDiacritics) {
      string = _replaceDiacriticsWithCustom(string);
    }
    string = removeDiacritics(string);
    return string.replaceAll(RegExp(r'[ .,\-&]'), '').toLowerCase();
  }

  String _replaceDiacriticsWithCustom(String string) {
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

  static String? nameFromDBbyPublisherId(String? publisherId) {
    if (publisherId != null) {
      return FaviconDB.instance.publisherNamesByPublisherId
          .getEntry(publisherId);
    }
    return null;
  }

  void savePublisherName(String? name) {
    if (name == null) {
      return;
    }
    if (publisherId != null) {
      FaviconDB.instance.publisherNamesByPublisherId.insert(publisherId!, name);
    }
    if (packageId != null) {
      FaviconDB.instance.publisherNamesByPackageId.insert(packageId!, name);
    }
  }

  Uri? fetchIcon() {
    PackageScreenshotsList screenshotsList = PackageScreenshotsList.instance;
    JsonPublisher? publisher =
        screenshotsList.publisherIcons[probablyPublisherID()] ??
            screenshotsList.publisherIcons[nameFittingId];
    return publisher?.iconUsingDefaultSource;
  }
}
