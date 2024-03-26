import 'dart:collection';

import 'package:diacritic/diacritic.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/package_infos/info_extensions.dart';
import 'package:winget_gui/widget_assets/favicon_db.dart';

import '../../helpers/log_stream.dart';
import '../../helpers/package_screenshots.dart';
import '../../helpers/package_screenshots_list.dart';
import '../../helpers/publisher.dart';
import '../../helpers/version_or_string.dart';
import '../../package_sources/ms_store_source.dart';
import '../../package_sources/package_source.dart';
import '../../package_sources/winget_source.dart';
import 'info.dart';

abstract class PackageInfos {
  late final Logger log;

  final Info<String>? name, id;
  late final Info<PackageSources> source;
  Info<VersionOrString>? version;

  final Map<String, String>? otherInfos;
  PackageScreenshots? screenshots;
  bool checkedForScreenshots = false;
  Uri? publisherIcon;
  String? publisherName;
  Uri? automaticFoundFavicons;

  PackageInfos({
    this.name,
    this.id,
    this.version,
    this.screenshots,
    this.checkedForScreenshots = false,
    this.publisherIcon,
    Info<PackageSources>? source,
    this.otherInfos,
    this.automaticFoundFavicons,
  }) {
    log = Logger(this);
    setSource(source);
    setPublisherName();
  }

  /// Set the [source] based on other attributes.
  /// Overrides should call [super.setSource()] at the start.
  void setSource(Info<PackageSources>? sourceInfo) {
    source = sourceInfo ??
        Info<PackageSources>.fromAttribute(PackageAttribute.source,
            value: PackageSources.none);
  }

  /// Set the [publisherName] based on other attributes.
  /// Overrides should call [super.setPublisherName()] at the start.
  void setPublisherName() {
    publisherName = PackageScreenshotsList.instance
            .publisherIcons[probablyPublisherID()]?.nameUsingDefaultSource ??
        publisherNameFromDB();
    if (publisherName != null) {
      return;
    }
    String? reconstructedName =
        reconstructPublisherNameByCompareTo(possiblePublisherNames);
    if (publisherID == null && reconstructedName == null) {
      reconstructedName = anyPublisherName();
    }
    if (reconstructedName != null) {
      publisherName = reconstructedName;
      savePublisherName();
    }
  }

  void savePublisherName() {}

  bool hasVersion() =>
      (version != null && version?.value.stringVersion != 'Unknown');
  bool hasSpecificVersion() =>
      version != null && version!.value.isSpecificVersion();

  void setImplicitInfos() {
    PackageScreenshotsList screenshotsList = PackageScreenshotsList.instance;
    screenshots = screenshotsList.getPackage(this);
    checkedForScreenshots = true;
    Publisher? publisher =
        screenshotsList.publisherIcons[probablyPublisherID()] ??
            screenshotsList.publisherIcons[publisherName];
    publisherIcon = publisher?.iconUsingDefaultSource;
    if (id != null) {
      automaticFoundFavicons = FaviconDB.instance.getFavicon(id!.value);
    }
  }

  bool isWinget();
  bool isMicrosoftStore();

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
    return Info<Uri>.fromAttribute(PackageAttribute.manifest,
        value: manifestUrl);
  }

  String? get publisherID => isWinget() ? probablyPublisherID() : null;

  String? probablyPublisherID() {
    String? id = this.id?.value;
    if (id == null) {
      return null;
    }
    if (id.contains('.')) {
      return id.split('.').first;
    }
    if (id.trim().contains(' ')) {
      return id.trim().split(' ').first;
    }
    return null;
  }

  bool probablySamePackage(PackageInfos i) {
    bool sameID = id != null && i.id?.value == id?.value;
    bool sameVersion = version == null || i.version?.value == version?.value;
    return sameID && sameVersion;
  }

  bool hasKnownSource() => isWinget() || isMicrosoftStore();

  String? versionWithoutEllipsis() => _withoutEllipsis(version?.toStringInfo());

  bool hasCompleteId() {
    return id != null && id!.value.isNotEmpty && !id!.value.endsWith('…');
  }

  String? idWithoutEllipsis() => _withoutEllipsis(id);

  String? _withoutEllipsis(Info<String>? info) {
    if (info == null) {
      return null;
    }
    if (info.value.endsWith('…')) {
      return info.value.substring(0, info.value.length - 1);
    }
    return info.value;
  }

  PackageInfosPeek toPeek();

  String? displayVersion() {
    if (this.version == null) {
      return null;
    }
    VersionOrString version = this.version!.value;
    if (version.isTypeVersion()) {
      return version.version!.copyWithIfNull(prefix: 'v').toString();
    }
    if (name != null) {
      if (version.stringVersion!.startsWith(name!.value)) {
        return version.stringVersion!.substring(name!.value.length).trim();
      }
    }
    return version.stringVersion;
  }

  static Info<PackageSources>? sourceInfo(String? source) {
    if (source == null) {
      return null;
    }
    return Info<PackageSources>.fromAttribute(PackageAttribute.source,
        value: PackageSources.fromString(source));
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

  /// A list of names that could be the publisher name.
  Iterable<String?> get possiblePublisherNames => [name?.value];

  String? anyPublisherName() {
    return null;
  }

  String? publisherNameFromDB() {
    if (id == null) {
      return null;
    }
    return FaviconDB.instance.getPublisherName(id!.value);
  }
}
