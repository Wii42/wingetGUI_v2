
import 'package:winget_core/winget_core.dart';
import 'package_infos_peek.dart';
import 'publisher.dart';

abstract class PackageInfos {

  final Info<String>? name;
  final Info<PackageId>? id;
  late final Info<PackageSources> source;
  Info<VersionOrString>? version;
  Publisher? publisher;
  final Map<String, String>? otherInfos;
  PackageScreenshots? screenshots;
  bool checkedForScreenshots = false;
  Uri? automaticFoundFavicons;

  PackageInfos({
    this.name,
    this.id,
    this.version,
    this.screenshots,
    this.checkedForScreenshots = false,
    this.publisher,
    Info<PackageSources>? source,
    this.otherInfos,
    this.automaticFoundFavicons,
  }) {
    setSource(source);
  }

  /// Set the [source] based on other attributes.
  /// Overrides should call [super.setSource()] at the start.
  void setSource(Info<PackageSources>? sourceInfo) {
    source = sourceInfo ??
        Info<PackageSources>.fromAttribute(PackageAttribute.source,
            value: PackageSources.none);
  }

  bool hasVersion() =>
      (version != null && version?.value.stringVersion != 'Unknown');

  bool hasSpecificVersion() =>
      version != null && version!.value.isSpecificVersion();

  bool isWinget();

  bool isMicrosoftStore();

  bool probablySamePackage(PackageInfos i) {
    bool sameID = id != null && i.id?.value == id?.value;
    bool sameVersion = version == null || i.version?.value == version?.value;
    return sameID && sameVersion;
  }

  bool hasKnownSource() => isWinget() || isMicrosoftStore();


  bool hasCompleteId() {
    return id != null && id!.value.isComplete;
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

  /// A list of names that could be the publisher name.
  Iterable<String?> get possiblePublisherNames => [name?.value];

  Iterable<String?> get anyPublisherNames {
    return [];
  }
}
