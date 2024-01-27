import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import './package_infos.dart';
import 'info.dart';
import 'info_map_parser.dart';
import 'package_attribute.dart';

class PackageInfosPeek extends PackageInfos {
  final Info<String>? availableVersion, source, match;

  PackageInfosPeek({
    super.name,
    super.id,
    super.version,
    super.screenshots,
    super.checkedForScreenshots = false,
    super.publisherIcon,
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
      name: parser.maybeStringFromMap(PackageAttribute.name),
      id: parser.maybeStringFromMap(PackageAttribute.id),
      version: parser.maybeStringFromMap(PackageAttribute.version),
      availableVersion:
          parser.maybeStringFromMap(PackageAttribute.availableVersion),
      source: parser.maybeStringFromMap(PackageAttribute.source),
      match: parser.maybeStringFromMap(PackageAttribute.match),
      otherInfos: details.isNotEmpty ? details : null,
    );
    return infos;
    //..setImplicitInfos();
  }

  bool hasInfosFull() {
    return source != null &&
        source!.value.isNotEmpty &&
        id != null;// &&
  }

  bool hasAvailableVersion() {
    return availableVersion != null && availableVersion!.value.isNotEmpty;
  }

  bool hasSpecificAvailableVersion() =>
      (availableVersion != null &&
          availableVersion!.value.isNotEmpty &&
          availableVersion?.value != 'Unknown' &&
          !availableVersion!.value.contains('<')) &&
      !availableVersion!.value.contains('>') &&
      !availableVersion!.value.contains('…');

  @override
  bool isMicrosoftStore() => source?.value == 'msstore';

  @override
  bool isWinget() => source?.value == 'winget';

  @override
  String toString() {
    return "PackageInfosPeek{"
        "name: ${name?.value}, "
        "id: ${id?.value}, "
        "version: ${version?.value}, "
        "availableVersion: ${availableVersion?.value}, "
        "source: ${source?.value}, "
        "match: ${match?.value}, "
        "otherInfos: $otherInfos"
        "}";
  }

  factory PackageInfosPeek.onlyId(String id) {
    return PackageInfosPeek(
      id: Info(
        title: (_) => '',
        value: id,
      ),
    );
  }

  @override
  PackageInfosPeek toPeek() => this;
}
