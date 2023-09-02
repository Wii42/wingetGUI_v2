import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'agreement_infos.dart';
import 'app_attribute.dart';
import 'info.dart';
import 'info_map_parser.dart';
import 'info_with_link.dart';
import 'installer_infos.dart';

class PackageInfos {
  final Info<String>? name,
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
  match;
  final InfoWithLink? releaseNotes;
  final List<String>? tags;
  final AgreementInfos? agreement;
  final Info<Uri>? website, supportUrl;
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
    this.match,
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
    InstallerInfos? installer = InstallerInfos.maybeFromMap(
        installerDetails: installerDetails, locale: locale);
    if (details != null) {
      InfoMapParser parser = InfoMapParser(map: details, locale: locale);

      return PackageInfos(
        name: parser.maybeDetailFromMap(AppAttribute.name),
        id: parser.maybeDetailFromMap(AppAttribute.id),
        description: parser.maybeDetailFromMap(AppAttribute.description),
        supportUrl: parser.maybeLinkFromMap(AppAttribute.publisherSupportUrl),
        version: parser.maybeDetailFromMap(AppAttribute.version),
        availableVersion:
            parser.maybeDetailFromMap(AppAttribute.availableVersion),
        source: parser.maybeDetailFromMap(AppAttribute.source),
        website: parser.maybeLinkFromMap(AppAttribute.website),
        author: parser.maybeDetailFromMap(AppAttribute.author),
        moniker: parser.maybeDetailFromMap(AppAttribute.moniker),
        documentation: parser.maybeDetailFromMap(AppAttribute.documentation),
        category: parser.maybeDetailFromMap(AppAttribute.category),
        pricing: parser.maybeDetailFromMap(AppAttribute.pricing),
        freeTrial: parser.maybeDetailFromMap(AppAttribute.freeTrial),
        ageRating: parser.maybeDetailFromMap(AppAttribute.ageRating),
        match: parser.maybeDetailFromMap(AppAttribute.match),
        releaseNotes: parser.maybeInfoWithLinkFromMap(
            textInfo: AppAttribute.releaseNotes,
            urlInfo: AppAttribute.releaseNotesUrl),
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

  bool hasVersion() => (version != null && version?.value != 'Unknown');

  bool hasDescription() => description != null;

  bool hasReleaseNotes() => releaseNotes?.text != null;
}
