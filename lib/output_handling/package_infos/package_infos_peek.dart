import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/package_id.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/peek_db_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/peek_map_parser.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import '../../helpers/version_or_string.dart';
import './package_infos.dart';
import 'info.dart';

class PackageInfosPeek extends PackageInfos {
  final Info<String>? match;
  final Info<VersionOrString>? availableVersion;

  PackageInfosPeek({
    super.name,
    super.id,
    super.version,
    super.screenshots,
    super.checkedForScreenshots = false,
    this.availableVersion,
    super.source,
    super.publisher,
    this.match,
    super.otherInfos,
  }) {
    setPublisher();
  }

  factory PackageInfosPeek.fromMap(
      {required Map<String, String>? details,
      required AppLocalizations locale}) {
    return PeekMapParser(details: details ?? {}, locale: locale).parse();
  }

  factory PackageInfosPeek.fromDBMap(Map<String, String>? details) {
    return PeekDBMapParser(details ?? {}).parse();
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
        value: PackageId.parse(id),
      ),
    );
  }

  @override
  PackageInfosPeek toPeek() => this;
}
