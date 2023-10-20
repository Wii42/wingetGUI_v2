import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/package_infos/info_yaml_map_parser.dart';
import 'package:yaml/yaml.dart';

import './package_infos.dart';
import 'agreement_infos.dart';
import 'info.dart';
import 'info_map_parser.dart';
import 'info_with_link.dart';
import 'installer_infos.dart';
import 'package_attribute.dart';

class PackageInfosFull extends PackageInfos {
  final Info<String>? description, shortDescription,
      author,
      moniker,
      documentation,
      category,
      pricing,
      freeTrial,
      ageRating;
  final InfoWithLink? releaseNotes;
  final List<String>? tags;
  final AgreementInfos? agreement;
  final Info<Uri>? website, supportUrl;
  final InstallerInfos? installer;

  PackageInfosFull({
    super.name,
    super.id,
    this.description,
    this.shortDescription,
    this.supportUrl,
    super.version,
    this.website,
    this.author,
    this.moniker,
    this.documentation,
    this.category,
    this.pricing,
    this.freeTrial,
    this.ageRating,
    this.releaseNotes,
    this.agreement,
    this.tags,
    this.installer,
    super.otherInfos,
  });

  factory PackageInfosFull.fromMap(
      {required Map<String, String>? details,
      Map<String, String>? installerDetails,
      required AppLocalizations locale}) {
    if (details == null && installerDetails == null) {
      return PackageInfosFull();
    }
    InstallerInfos? installer = InstallerInfos.maybeFromMap(
        installerDetails: installerDetails, locale: locale);
    if (details != null) {
      InfoMapParser parser = InfoMapParser(map: details, locale: locale);

      PackageInfosFull infos = PackageInfosFull(
        name: parser.maybeDetailFromMap(PackageAttribute.name),
        id: parser.maybeDetailFromMap(PackageAttribute.id),
        description: parser.maybeDetailFromMap(PackageAttribute.description),
        supportUrl:
            parser.maybeLinkFromMap(PackageAttribute.publisherSupportUrl),
        version: parser.maybeDetailFromMap(PackageAttribute.version),
        website: parser.maybeLinkFromMap(PackageAttribute.website),
        author: parser.maybeDetailFromMap(PackageAttribute.author),
        moniker: parser.maybeDetailFromMap(PackageAttribute.moniker),
        documentation:
            parser.maybeDetailFromMap(PackageAttribute.documentation),
        category: parser.maybeDetailFromMap(PackageAttribute.category),
        pricing: parser.maybeDetailFromMap(PackageAttribute.pricing),
        freeTrial: parser.maybeDetailFromMap(PackageAttribute.freeTrial),
        ageRating: parser.maybeDetailFromMap(PackageAttribute.ageRating),
        releaseNotes: parser.maybeInfoWithLinkFromMap(
            textInfo: PackageAttribute.releaseNotes,
            urlInfo: PackageAttribute.releaseNotesUrl),
        agreement: parser.maybeAgreementFromMap(),
        tags: parser.maybeTagsFromMap(),
        installer: installer,
        otherInfos: details.isNotEmpty ? details : null,
      );
      return infos..setImplicitInfos();
    } else {
      return PackageInfosFull(installer: installer);
    }
  }

  factory PackageInfosFull.fromYamlMap(
      {required Map<dynamic, dynamic>? details, required Map<dynamic, dynamic>? installerDetails}) {
    if (details == null && installerDetails == null) {
      return PackageInfosFull();
    }
    InstallerInfos? installer =
        InstallerInfos.maybeFromYamlMap(installerDetails: installerDetails);

    if (details != null) {InfoYamlMapParser parser = InfoYamlMapParser(map: details);
      PackageInfosFull infos = PackageInfosFull(
        name: parser.maybeDetailFromMap(PackageAttribute.name, key: 'PackageName'),
        id: parser.maybeDetailFromMap(PackageAttribute.id, key: 'PackageIdentifier'),
        description: parser.maybeDetailFromMap(PackageAttribute.description, key: 'Description'),
        shortDescription: parser.maybeDetailFromMap(PackageAttribute.description, key: 'ShortDescription'),
        supportUrl:
        parser.maybeLinkFromMap(PackageAttribute.publisherSupportUrl, key: 'PublisherSupportUrl'),
        version: parser.maybeDetailFromMap(PackageAttribute.version, key: 'PackageVersion'),
        website: parser.maybeLinkFromMap(PackageAttribute.website, key: 'PackageUrl'),
        author: parser.maybeDetailFromMap(PackageAttribute.author, key: 'Author'),
        moniker: parser.maybeDetailFromMap(PackageAttribute.moniker, key: 'Moniker'),
        documentation:
        parser.maybeDetailFromMap(PackageAttribute.documentation, key: 'Documentation'),
        releaseNotes: parser.maybeInfoWithLinkFromMap(
            textInfo: PackageAttribute.releaseNotes,
        textKey: 'ReleaseNotes',
        urlKey: 'ReleaseNotesUrl'),
        agreement: parser.maybeAgreementFromMap(),
        tags: parser.maybeTagsFromMap(),
        installer: installer,
        otherInfos: details.isNotEmpty ? details.map<String, String>((key, value) => MapEntry(key.toString(), value.toString())) : null,
      );
      return infos..setImplicitInfos();
    } else {
      return PackageInfosFull(installer: installer);
    }
  }

  bool hasInstallerDetails() => installer != null;

  bool hasTags() => tags != null;

  bool hasDescription() => description != null;

  bool hasReleaseNotes() => releaseNotes?.text != null;

  @override
  bool isMicrosoftStore() => (installer?.type?.value.trim() == 'msstore' &&
      installer?.storeProductID != null);

  @override
  bool isWinget() =>
      !isMicrosoftStore() && id != null && id!.value.contains('.');
}
