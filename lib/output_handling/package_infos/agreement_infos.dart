import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/full_map_parser.dart';

import 'info.dart';
import 'parsers/info_json_parser.dart';
import 'info_with_link.dart';
import 'parsers/info_yaml_parser.dart';
import 'package_attribute.dart';

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
    if (map == null) {
      return null;
    }
    InfoYamlParser parser = InfoYamlParser(map: map);

    AgreementInfos agreement = AgreementInfos(
      title: PackageAttribute.agreement.title,
      publisher: parser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.publisher,
          urlInfo: PackageAttribute.publisherUrl),
      license: parser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.license,
          urlInfo: PackageAttribute.licenseUrl),
      copyright: parser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.copyright,
          urlInfo: PackageAttribute.copyrightUrl),
      privacyUrl: parser.maybeLinkFromMap(PackageAttribute.privacyUrl),
      buyUrl: parser.maybeLinkFromMap(PackageAttribute.buyUrl),
    );
    return agreement.isNotEmpty() ? agreement : null;
  }

  static AgreementInfos? maybeFromJsonMap({
    required Map<String, dynamic>? map,
    required Map<String, dynamic>? agreementsMap,
  }) {
    if (map == null && agreementsMap == null) {
      return null;
    }
    InfoJsonParser parser = InfoJsonParser(map: map ?? {});
    InfoJsonParser agreementsParser = InfoJsonParser(map: agreementsMap ?? {});

    AgreementInfos agreement = AgreementInfos(
      title: PackageAttribute.agreement.title,
      publisher: parser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.publisher,
          urlInfo: PackageAttribute.publisherUrl),
      license: parser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.license,
          urlInfo: PackageAttribute.licenseUrl),
      copyright: parser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.copyright,
          urlInfo: PackageAttribute.copyrightUrl),
      privacyUrl: parser.maybeLinkFromMap(PackageAttribute.privacyUrl),
      termsOfTransaction: agreementsParser
          .maybeStringFromMap(PackageAttribute.termsOfTransaction),
      seizureWarning:
          agreementsParser.maybeStringFromMap(PackageAttribute.seizureWarning),
      storeLicenseTerms: agreementsParser
          .maybeStringFromMap(PackageAttribute.storeLicenseTerms),
    );
    return agreement.isNotEmpty() ? agreement : null;
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
