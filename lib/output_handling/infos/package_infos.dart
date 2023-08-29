import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'info_enum.dart';
import 'info_map_parser.dart';
import 'info_with_link.dart';
import 'installer_infos.dart';

class PackageInfos {
  final String? name,
      id,
      description,
      version,
      availableVersion,
      source,
      author,
      moniker,
      documentation,
      category,
      pricing,
      freeTrial,
      ageRating,
      storeProductID;
  final InfoWithLink? releaseNotes;
  final List<String>? tags;
  final AgreementInfos? agreement;
  final Uri? website, supportUrl;
  final InstallerInfos? installer;
  final Map<String, String>? otherInfos;

  PackageInfos({
    this.name,
    this.id,
    this.description,
    this.supportUrl,
    this.version,
    this.availableVersion,
    this.source,
    this.website,
    this.author,
    this.moniker,
    this.documentation,
    this.category,
    this.pricing,
    this.freeTrial,
    this.ageRating,
    this.storeProductID,
    this.releaseNotes,
    this.agreement,
    this.tags,
    this.installer,
    this.otherInfos,
  });

  factory PackageInfos.fromMap(
      {required Map<String, String>? details,
      Map<String, String>? installerDetails,
      required AppLocalizations locale}) {
    if (details == null && installerDetails == null) {
      return PackageInfos();
    }
    InstallerInfos installer = InstallerInfos();
    if (details != null) {
      InfoMapParser parser = InfoMapParser(map: details, locale: locale);

      return PackageInfos(
        name: parser.maybeDetailFromMap(Info.name),
        id: parser.maybeDetailFromMap(Info.id),
        description: parser.maybeDetailFromMap(Info.description),
        supportUrl: parser.maybeLinkFromMap(Info.publisherSupportUrl),
        version: parser.maybeDetailFromMap(Info.version),
        availableVersion: parser.maybeDetailFromMap(Info.availableVersion),
        source: parser.maybeDetailFromMap(Info.source),
        website: parser.maybeLinkFromMap(Info.website),
        author: parser.maybeDetailFromMap(Info.author),
        moniker: parser.maybeDetailFromMap(Info.moniker),
        documentation: parser.maybeDetailFromMap(Info.documentation),
        category: parser.maybeDetailFromMap(Info.category),
        pricing: parser.maybeDetailFromMap(Info.pricing),
        freeTrial: parser.maybeDetailFromMap(Info.freeTrial),
        ageRating: parser.maybeDetailFromMap(Info.ageRating),
        storeProductID: parser.maybeDetailFromMap(Info.storeProductID),
        releaseNotes: parser.maybeInfoWithLinkFromMap(
            textInfo: Info.releaseNotes, urlInfo: Info.releaseNotesUrl),
        agreement: parser.maybeAgreementFromMap(),
        tags: parser.maybeTagsFromMap(),
        installer: installer,
        otherInfos: details.isNotEmpty ? details : null,
      );
    } else {
      return PackageInfos(installer: installer);
    }
  }

  bool hasInstallerDetails() => installer != null;

  bool hasTags() => tags != null;

  bool hasVersion() => (version != null && version != 'Unknown');

  bool hasDescription() => description != null;

  bool hasReleaseNotes() => releaseNotes?.text != null;
}

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
