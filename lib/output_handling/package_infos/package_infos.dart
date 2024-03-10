import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';
import 'package:winget_gui/output_handling/package_infos/to_string_info_extensions.dart';

import '../../helpers/log_stream.dart';
import '../../helpers/package_screenshots.dart';
import '../../helpers/package_screenshots_list.dart';
import '../../helpers/version_or_string.dart';
import '../../package_sources/package_source.dart';
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

  PackageInfos({
    this.name,
    this.id,
    this.version,
    this.screenshots,
    this.checkedForScreenshots = false,
    this.publisherIcon,
    Info<PackageSources>? source,
    this.otherInfos,
  }) {
    log = Logger(this);
    publisherName = PackageScreenshotsList
        .instance.publisherIcons[probablyPublisherID()]?.nameUsingDefaultSource;
    this.source = source ??
        Info<PackageSources>.fromAttribute(PackageAttribute.source,
            value: PackageSources.none);
  }

  bool hasVersion() => (version != null && version?.value.stringVersion != 'Unknown');
  bool hasSpecificVersion() => version != null && version!.value.isSpecificVersion();

  void setImplicitInfos() {
    screenshots = PackageScreenshotsList.instance.getPackage(this);
    checkedForScreenshots = true;
    publisherIcon = PackageScreenshotsList
        .instance.publisherIcons[probablyPublisherID()]?.iconUsingDefaultSource;
  }

  bool isWinget();
  bool isMicrosoftStore();

  Info<Uri>? get manifest {
    if (id == null || !isWinget()) {
      return null;
    }
    return Info<Uri>(
        title: (locale) => locale.infoTitle(PackageAttribute.manifest.name),
        value: Uri.parse(
            'https://github.com/microsoft/winget-pkgs/tree/master/manifests/$idInitialLetter/$idAsPath'));
  }

  Info<Uri>? get manifestApi {
    if (id == null && isWinget()) {
      return null;
    }
    return Info<Uri>(
        title: (locale) => locale.infoTitle(PackageAttribute.manifest.name),
        value: Uri.parse(
            'https://api.github.com/repos/microsoft/winget-pkgs/contents/manifests/$idInitialLetter/$idAsPath'));
  }

  Info<Uri>? get versionManifestPath {
    if (id == null && isWinget() && hasSpecificVersion()) {
      return null;
    }
    return Info<Uri>(
        title: (locale) => locale.infoTitle(PackageAttribute.manifest.name),
        value: Uri.parse(
            'https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/$idInitialLetter/$idAsPath/${version!.value}/${id!.value}'));
  }

  String? get idInitialLetter {
    if (id == null) {
      return null;
    }
    return id!.value.firstChar().toLowerCase();
  }

  String? get idAsPath {
    if (id == null) {
      return null;
    }
    return id!.value.replaceAll('.', '/');
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
    if(version.isTypeVersion()){
      return version.version?.toString();
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
}
