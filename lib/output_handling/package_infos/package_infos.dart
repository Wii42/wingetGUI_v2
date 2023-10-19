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
            'https://github.com/microsoft/winget-pkgs/tree/master/manifests/${id!.value.firstChar().toLowerCase()}/${id!.value.replaceAll('.', '/')}'));
  }
}
