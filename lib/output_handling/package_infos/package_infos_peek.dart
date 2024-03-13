import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import '../../helpers/version_or_string.dart';
import './package_infos.dart';
import 'info.dart';
import 'info_map_parser.dart';
import 'package_attribute.dart';

class PackageInfosPeek extends PackageInfos {
  final Info<String>? match;
  final Info<VersionOrString>? availableVersion;

  PackageInfosPeek({
    super.name,
    super.id,
    super.version,
    super.screenshots,
    super.checkedForScreenshots = false,
    super.publisherIcon,
    this.availableVersion,
    super.source,
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
      version: parser.maybeVersionOrStringFromMap(PackageAttribute.version),
      availableVersion:
          parser.maybeVersionOrStringFromMap(PackageAttribute.availableVersion),
      source: parser.sourceFromMap(PackageAttribute.source),
      match: parser.maybeStringFromMap(PackageAttribute.match),
      otherInfos: details.isNotEmpty ? details : null,
    );
    return infos;
    //..setImplicitInfos();
  }

  bool hasInfosFull() {
    return source.value != PackageSources.none &&
        source.value != PackageSources.unknownSource &&
        id != null; // &&
  }

  bool hasAvailableVersion() {
    return availableVersion != null && availableVersion!.value.isVersion();
  }

  bool hasSpecificAvailableVersion() =>
      availableVersion != null && availableVersion!.value.isSpecificVersion();

  @override
  bool isMicrosoftStore() => source.value == PackageSources.microsoftStore;

  @override
  bool isWinget() => source.value == PackageSources.winget;

  @override
  String toString() {
    return "PackageInfosPeek{"
        "name: ${name?.value}, "
        "id: ${id?.value}, "
        "version: ${version?.value}, "
        "availableVersion: ${availableVersion?.value}, "
        "source: ${source.value}, "
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
