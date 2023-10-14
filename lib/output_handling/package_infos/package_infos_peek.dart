import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './package_infos.dart';

import 'package_attribute.dart';
import 'info.dart';
import 'info_map_parser.dart';

class PackageInfosPeek extends PackageInfos {
  final Info<String>? availableVersion, source, match;

  PackageInfosPeek({
    super.name,
    super.id,
    super.version,
    this.availableVersion,
    this.source,
    this.match,
    super.otherInfos,
  });

  factory PackageInfosPeek.fromMap(
      {required Map<String, String>? details,
      required AppLocalizations locale}) {
    if (details == null) {
      return PackageInfosPeek();
    }
    InfoMapParser parser = InfoMapParser(map: details, locale: locale);
    PackageInfosPeek infos = PackageInfosPeek(
      name: parser.maybeDetailFromMap(PackageAttribute.name),
      id: parser.maybeDetailFromMap(PackageAttribute.id),
      version: parser.maybeDetailFromMap(PackageAttribute.version),
      availableVersion:
          parser.maybeDetailFromMap(PackageAttribute.availableVersion),
      source: parser.maybeDetailFromMap(PackageAttribute.source),
      match: parser.maybeDetailFromMap(PackageAttribute.match),
      otherInfos: details.isNotEmpty ? details : null,
    );
    return infos;
      //..screenshots = PackageScreenshotsList.instance.getPackage(infos);
  }

  bool hasInfosFull() {
    return source != null &&
        source!.value.isNotEmpty &&
        id != null &&
        !id!.value.endsWith('…');
  }
}
