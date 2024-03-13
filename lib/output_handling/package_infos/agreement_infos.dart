import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/full_json_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/full_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/full_yaml_parser.dart';

import 'info.dart';
import 'info_with_link.dart';

class AgreementInfos {
  final String Function(AppLocalizations) title;
  final InfoWithLink? publisher, license, copyright;
  final Info<Uri>? privacyUrl, buyUrl;
  final Info<String>? termsOfTransaction, seizureWarning, storeLicenseTerms;

  AgreementInfos({
    required this.title,
    this.publisher,
    this.license,
    this.copyright,
    this.privacyUrl,
    this.buyUrl,
    this.termsOfTransaction,
    this.seizureWarning,
    this.storeLicenseTerms,
  });

  static AgreementInfos? maybeFromMap(
      {required Map<String, String>? map, required AppLocalizations locale}) {
    return FullMapParser(details: map ?? {}, locale: locale)
        .parseAgreementInfos();
  }

  static AgreementInfos? maybeFromYamlMap(
      {required Map<dynamic, dynamic>? map}) {
    return FullYamlParser(details: map ?? {}).parseAgreementInfos();
  }

  static AgreementInfos? maybeFromJsonMap({
    required Map<String, dynamic>? map,
    required Map<String, dynamic>? agreementsMap,
  }) {
    return FullJsonParser(details: map ?? {}).parseAgreementInfos();
  }

  bool isEmpty() {
    return (publisher == null &&
        license == null &&
        copyright == null &&
        privacyUrl == null &&
        buyUrl == null &&
        termsOfTransaction == null &&
        seizureWarning == null &&
        storeLicenseTerms == null);
  }

  bool isNotEmpty() => !isEmpty();
}
