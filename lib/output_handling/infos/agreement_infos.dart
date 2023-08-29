import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'info_enum.dart';
import 'info_map_parser.dart';
import 'info_with_link.dart';

class AgreementInfos {
  final InfoWithLink? publisher, license, copyright;
  final Uri? privacyUrl, buyUrl;
  final String? termsOfTransaction, seizureWarning, storeLicenseTerms;

  AgreementInfos({
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
      publisher: parser.maybeInfoWithLinkFromMap(
          textInfo: Info.publisher, urlInfo: Info.publisherUrl),
      license: parser.maybeInfoWithLinkFromMap(
          textInfo: Info.license, urlInfo: Info.licenseUrl),
      copyright: parser.maybeInfoWithLinkFromMap(
          textInfo: Info.copyright, urlInfo: Info.copyrightUrl),
      privacyUrl: parser.maybeLinkFromMap(Info.privacyUrl),
      buyUrl: parser.maybeLinkFromMap(Info.buyUrl),
      termsOfTransaction: parser.maybeDetailFromMap(Info.termsOfTransaction),
      seizureWarning: parser.maybeDetailFromMap(Info.seizureWarning),
      storeLicenseTerms: parser.maybeDetailFromMap(Info.storeLicenseTerms),
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