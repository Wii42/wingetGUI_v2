import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_attribute.dart';
import 'info.dart';
import 'info_map_parser.dart';
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
    if (map == null) {
      return null;
    }
    InfoMapParser parser = InfoMapParser(map: map, locale: locale);

    AgreementInfos agreement = AgreementInfos(
      title: AppAttribute.agreement.title,
      publisher: parser.maybeInfoWithLinkFromMap(
          textInfo: AppAttribute.publisher, urlInfo: AppAttribute.publisherUrl),
      license: parser.maybeInfoWithLinkFromMap(
          textInfo: AppAttribute.license, urlInfo: AppAttribute.licenseUrl),
      copyright: parser.maybeInfoWithLinkFromMap(
          textInfo: AppAttribute.copyright, urlInfo: AppAttribute.copyrightUrl),
      privacyUrl: parser.maybeLinkFromMap(AppAttribute.privacyUrl),
      buyUrl: parser.maybeLinkFromMap(AppAttribute.buyUrl),
      termsOfTransaction:
          parser.maybeDetailFromMap(AppAttribute.termsOfTransaction),
      seizureWarning: parser.maybeDetailFromMap(AppAttribute.seizureWarning),
      storeLicenseTerms:
          parser.maybeDetailFromMap(AppAttribute.storeLicenseTerms),
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
