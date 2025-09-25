import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/package_infos/package_infos_full.dart';

extension PeekToFullExtension on PackageInfosPeek {
  PackageInfosFull toFull() {
    return PackageInfosFull(
      name: name,
      id: id,
      version: version,
      screenshots: screenshots,
      checkedForScreenshots: checkedForScreenshots,
      source: source,
      publisher: publisher,
      otherInfos: otherInfos
    );
  }
}
