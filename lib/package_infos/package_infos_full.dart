import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/package_sources/package_source.dart';

import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'installer_objects/installer.dart';
import 'installer_objects/installer_type.dart';
import 'package_attribute.dart';
import 'package_infos.dart';
import 'package_infos_peek.dart';
import 'parsers/full_json_parser.dart';
import 'parsers/full_map_parser.dart';
import 'parsers/full_yaml_parser.dart';

class PackageInfosFull extends PackageInfos {
  final Info<String>? description,
      shortDescription,
      author,
      moniker,
      category,
      pricing,
      freeTrial,
      ageRating;
  final Info<List<InfoWithLink>>? documentation;
  final InfoWithLink? releaseNotes;
  final List<String>? tags;
  final AgreementInfos? agreement;
  final Info<Uri>? website, supportUrl;
  final Info<Locale>? packageLocale;
  final Info<List<Installer>>? installer;
  final Info<String>? installationNotes;

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
    this.packageLocale,
    this.installationNotes,
    this.installer,
    super.source,
    super.publisher,
    InfoWithLink? publisherInfo, // name and website
    super.otherInfos,
  }) {
    setPublisher(
        fullName: publisherInfo?.text,
        publisherWebsite: publisherInfo?.url,
        isFullInfos: true);
  }

  factory PackageInfosFull.fromMap(
      {required Map<String, String>? details,
      Map<String, String>? installerDetails,
      required AppLocalizations locale}) {
    return FullMapParser(
            details: details ?? {},
            installerDetails: installerDetails ?? {},
            locale: locale)
        .parse();
  }

  factory PackageInfosFull.fromYamlMap(
      {required Map<dynamic, dynamic>? details,
      required Map<dynamic, dynamic>? installerDetails,
      String? source}) {
    return FullYamlParser(
            details: details ?? {},
            installerDetails: installerDetails ?? {},
            source: source)
        .parse();
  }

  factory PackageInfosFull.fromMSJson(
      {required Map<String, dynamic>? file, Locale? locale, String? source}) {
    return FullJsonParser(
            details: file ?? const {}, locale: locale, source: source)
        .parse();
  }

  bool hasInstallerDetails() => installer != null;

  bool hasTags() => tags != null;

  bool hasDescription() => description != null || shortDescription != null;

  bool hasReleaseNotes() => releaseNotes?.text != null;

  @override
  bool isMicrosoftStore() =>
      source.value == PackageSources.microsoftStore ||
      ((installer?.value.firstOrNull?.type?.value) == InstallerType.msstore &&
          (installer?.value.firstOrNull?.storeProductID) != null);

  @override
  bool isWinget() =>
      source.value == PackageSources.winget ||
      (!isMicrosoftStore() && id != null && id!.value.separator == '.');

  Info<String>? get additionalDescription {
    if (!hasDescription()) {
      return null;
    }
    if (shortDescription == null) {
      return description;
    }
    if (description == null) {
      return null;
    }
    if (!description!.value.startsWith(shortDescription!.value)) {
      return Info<String>(
          title: description!.title, value: '\n${description!.value}');
    }
    if (description!.value == shortDescription!.value) {
      return null;
    }

    String additionalDescription =
        description!.value.substring(shortDescription!.value.length);

    if (additionalDescription.trim() == '.') {
      return null;
    }

    return Info<String>(
        title: description!.title, value: additionalDescription);
  }

  @override
  String toString() {
    return [
      if (name != null) "name: ${name!.value}",
      if (id != null) "id: ${id!.value}",
      if (version != null) "version: ${version!.value}",
      if (description != null) "description: ${description!.value}",
      if (shortDescription != null)
        "shortDescription: ${shortDescription!.value}",
      if (supportUrl != null) "supportUrl: ${supportUrl!.value}",
      if (website != null) "website: ${website!.value}",
      if (author != null) "author: ${author!.value}",
      if (moniker != null) "moniker: ${moniker!.value}",
      if (documentation != null) "documentation: ${documentation!.value}",
      if (releaseNotes != null) "releaseNotes: $releaseNotes",
      if (agreement != null) "agreement: $agreement",
      if (tags != null) "tags: ${tags!.join(', ')}",
      if (packageLocale != null) "packageLocale: ${packageLocale!.value}",
      if (installer != null) "installer: ${installer!}",
      if (otherInfos != null) "otherInfos: ${otherInfos!.toString()}",
    ].join(', ');
  }

  @override
  PackageInfosPeek toPeek() {
    PackageSources? source = isWinget()
        ? PackageSources.winget
        : isMicrosoftStore()
            ? PackageSources.microsoftStore
            : null;
    return PackageInfosPeek(
      name: name,
      id: id,
      version: version,
      source: (source != null)
          ? Info<PackageSources>.fromAttribute(PackageAttribute.source,
              value: source)
          : this.source,
      otherInfos: otherInfos,
      screenshots: screenshots,
      publisher: publisher,
    );
  }

  @override
  Iterable<String?> get possiblePublisherNames {
    return [
      author?.value,
      ...super.possiblePublisherNames,
    ];
  }

  @override
  Iterable<String?> get anyPublisherNames =>
      [author?.value, ...super.anyPublisherNames];
}
