import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'info.dart';
import 'info_map_parser.dart';
import 'info_yaml_map_parser.dart';
import 'info_with_link.dart';
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
    if (map == null) {
      return null;
    }
    InfoMapParser parser = InfoMapParser(map: map, locale: locale);

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
      termsOfTransaction:
          parser.maybeStringFromMap(PackageAttribute.termsOfTransaction),
      seizureWarning:
          parser.maybeStringFromMap(PackageAttribute.seizureWarning),
      storeLicenseTerms:
          parser.maybeStringFromMap(PackageAttribute.storeLicenseTerms),
    );
    return agreement.isNotEmpty() ? agreement : null;
  }

  static AgreementInfos? maybeFromYamlMap(
      {required Map<dynamic, dynamic>? map}) {
    if (map == null) {
      return null;
    }
    InfoYamlMapParser parser = InfoYamlMapParser(map: map);

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
