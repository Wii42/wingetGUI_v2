import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import 'info.dart';
import 'package_id.dart';
import 'package_infos.dart';
import 'parsers/peek_db_map_parser.dart';
import 'parsers/peek_map_parser.dart';

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

  static final PackageInfosPeek exampleInfos = PackageInfosPeek(
    name:
    Info.fromAttribute(PackageAttribute.name, value: 'Prototype Widget'),
    id: Info.fromAttribute(PackageAttribute.id,
        value: PackageId.parse('Prototype.Widget')),
    version:Info.fromAttribute(PackageAttribute.version,
        value: VersionOrString.parse('1.0.0')),
    availableVersion: Info.fromAttribute(PackageAttribute.availableVersion,
        value: VersionOrString.parse('1.0.1')),
    source: Info.fromAttribute(PackageAttribute.source,
        value: PackageSources.unknownSource),
  );
}
