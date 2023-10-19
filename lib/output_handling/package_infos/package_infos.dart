import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import '../../helpers/package_screenshots.dart';
import '../../helpers/package_screenshots_list.dart';
import 'info.dart';

abstract class PackageInfos {
  final Info<String>? name, id, version;

  final Map<String, String>? otherInfos;
  late final PackageScreenshots? screenshots;

  PackageInfos({
    this.name,
    this.id,
    this.version,
    this.otherInfos,
  });

  bool hasVersion() => (version != null && version?.value != 'Unknown');
  bool hasSpecificVersion() => (version != null &&
      version?.value != 'Unknown' &&
      !version!.value.contains('<'));

  void setImplicitInfos() {
    screenshots = PackageScreenshotsList.instance.getPackage(this);
  }

  bool isWinget();
  bool isMicrosoftStore();

  Info<Uri>? get manifest {
    if (id == null && isWinget()) {
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

  Info<Uri>? get versionManifest {
    if (id == null && isWinget() && hasSpecificVersion()) {
      return null;
    }
    return Info<Uri>(
        title: (locale) => locale.infoTitle(PackageAttribute.manifest.name),
        value: Uri.parse(
            'https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/$idInitialLetter/$idAsPath/${version!.value}/${id!.value}.yaml'));
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
}
