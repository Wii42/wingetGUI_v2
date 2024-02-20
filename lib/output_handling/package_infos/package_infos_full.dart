import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/best_fitting_locale.dart';
import 'package:winget_gui/helpers/locale_parser.dart';
import 'package:winget_gui/output_handling/package_infos/info_yaml_parser.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_peek.dart';

import './package_infos.dart';
import 'agreement_infos.dart';
import 'info.dart';
import 'info_json_parser.dart';
import 'info_map_parser.dart';
import 'info_with_link.dart';
import 'installer_infos.dart';
import 'installer_objects/installer_type.dart';
import 'package_attribute.dart';

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
    this.packageLocale,
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

      Info<String>? description =
          parser.maybeStringFromMap(PackageAttribute.description);
      PackageInfosFull infos = PackageInfosFull(
        name: parser.maybeStringFromMap(PackageAttribute.name),
        id: parser.maybeStringFromMap(PackageAttribute.id),
        description: description,
        shortDescription: parser.maybeFirstLineFromInfo(description,
            destination: PackageAttribute.shortDescription),
        supportUrl:
            parser.maybeLinkFromMap(PackageAttribute.publisherSupportUrl),
        version: parser.maybeStringFromMap(PackageAttribute.version),
        website: parser.maybeLinkFromMap(PackageAttribute.website),
        author: parser.maybeStringFromMap(PackageAttribute.author),
        moniker: parser.maybeStringFromMap(PackageAttribute.moniker),
        documentation:
            parser.maybeListWithLinksFromMap(PackageAttribute.documentation),
        category: parser.maybeStringFromMap(PackageAttribute.category),
        pricing: parser.maybeStringFromMap(PackageAttribute.pricing),
        freeTrial: parser.maybeStringFromMap(PackageAttribute.freeTrial),
        ageRating: parser.maybeStringFromMap(PackageAttribute.ageRating),
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
      {required Map<dynamic, dynamic>? details,
      required Map<dynamic, dynamic>? installerDetails}) {
    if (details == null && installerDetails == null) {
      return PackageInfosFull();
    }
    InstallerInfos? installer =
        InstallerInfos.maybeFromYamlMap(installerDetails: installerDetails);

    if (details != null) {
      details.removeWhere((key, value) => value == null);
      InfoYamlParser parser = InfoYamlParser(map: details);
      PackageInfosFull infos = PackageInfosFull(
        name: parser.maybeStringFromMap(PackageAttribute.name),
        id: parser.maybeStringFromMap(PackageAttribute.id),
        description: parser.maybeStringFromMap(PackageAttribute.description),
        shortDescription:
            parser.maybeStringFromMap(PackageAttribute.shortDescription),
        supportUrl:
            parser.maybeLinkFromMap(PackageAttribute.publisherSupportUrl),
        version: parser.maybeStringFromMap(PackageAttribute.version),
        website: parser.maybeLinkFromMap(PackageAttribute.website),
        author: parser.maybeStringFromMap(PackageAttribute.author),
        moniker: parser.maybeStringFromMap(PackageAttribute.moniker),
        documentation:
            parser.maybeDocumentationsFromMap(PackageAttribute.documentation),
        releaseNotes: parser.maybeInfoWithLinkFromMap(
            textInfo: PackageAttribute.releaseNotes,
            urlInfo: PackageAttribute.releaseNotesUrl),
        agreement: parser.maybeAgreementFromMap(),
        tags: parser.maybeTagsFromMap(),
        packageLocale:
            parser.maybeLocaleFromMap(PackageAttribute.packageLocale),
        installer: installer,
        otherInfos: details.isNotEmpty
            ? details.map<String, String>(
                (key, value) => MapEntry(key.toString(), value.toString()))
            : null,
      );
      return infos..setImplicitInfos();
    } else {
      return PackageInfosFull(installer: installer);
    }
  }

  factory PackageInfosFull.fromMSJson(
      {required Map<String, dynamic>? file, Locale? locale}) {
    if (file == null) {
      return PackageInfosFull();
    }
    Map<String, dynamic>? data = file['Data'];
    print('data: $data ');
    InfoJsonParser dataParser = InfoJsonParser(map: data ?? {});
    List<dynamic>? versions = data?['Versions'];
    Map<String, dynamic>? version = versions?.lastOrNull;
    InfoJsonParser versionParser = InfoJsonParser(map: version ?? {});
    Map<String, dynamic>? defaultLocale = version?['DefaultLocale'];
    Map<String, dynamic>? selectedLocale =
        getOptimalLocaleMap(defaultLocale, version, locale);
    InfoJsonParser localeParser =
        InfoJsonParser(map: selectedLocale ?? defaultLocale ?? {});
    PackageInfosFull infos = PackageInfosFull(
      name: localeParser.maybeStringFromMap(PackageAttribute.name),
      id: dataParser.maybeStringFromMap(PackageAttribute.id),
      description:
          localeParser.maybeStringFromMap(PackageAttribute.description),
      shortDescription:
          localeParser.maybeStringFromMap(PackageAttribute.shortDescription),
      supportUrl:
          localeParser.maybeLinkFromMap(PackageAttribute.publisherSupportUrl),
      version: versionParser.maybeStringFromMap(PackageAttribute.version),
      website: localeParser.maybeLinkFromMap(PackageAttribute.website),
      author: localeParser.maybeStringFromMap(PackageAttribute.author),
      moniker: localeParser.maybeStringFromMap(PackageAttribute.moniker),
      releaseNotes: localeParser.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.releaseNotes,
          urlInfo: PackageAttribute.releaseNotesUrl),
      agreement: versionParser.maybeAgreementFromMap(),
      tags: versionParser.maybeTagsFromMap(),
      packageLocale:
          versionParser.maybeLocaleFromMap(PackageAttribute.packageLocale),
      installer: InstallerInfos.maybeFromJsonMap(installerDetails: file),
      otherInfos: file.isNotEmpty
          ? file.map<String, String>(
              (key, value) => MapEntry(key.toString(), value.toString()))
          : null,
    );
    return infos..setImplicitInfos();
  }

  static Map<String, dynamic>? getOptimalLocaleMap(
      Map<String, dynamic>? defaultLocale,
      Map<String, dynamic>? version,
      Locale? locale) {
    Map<String, dynamic>? selectedLocale = defaultLocale;
    List<dynamic>? locales = version?['Locales'];
    if (locales != null && locale != null && locales.isNotEmpty) {
      List<Locale> availableLocales = locales
          .map<Locale?>((e) =>
              LocaleParser.tryParse(e[PackageAttribute.packageLocale.apiKey]))
          .nonNulls
          .toList();
      Locale? bestFitting = locale.bestFittingLocale(availableLocales);
      if (bestFitting != null) {
        selectedLocale = locales.firstWhere(
            (element) =>
                LocaleParser.tryParse(
                    element[PackageAttribute.packageLocale.apiKey]) ==
                bestFitting,
            orElse: () => defaultLocale);
      }
    }
    return selectedLocale ?? defaultLocale;
  }

  bool hasInstallerDetails() => installer != null;

  bool hasTags() => tags != null;

  bool hasDescription() => description != null || shortDescription != null;

  bool hasReleaseNotes() => releaseNotes?.text != null;

  @override
  bool isMicrosoftStore() => (installer?.type?.value == InstallerType.msstore &&
      installer?.storeProductID != null);

  @override
  bool isWinget() =>
      !isMicrosoftStore() && id != null && id!.value.contains('.');

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
    String? source = isWinget()
        ? 'winget'
        : isMicrosoftStore()
            ? 'msstore'
            : null;
    return PackageInfosPeek(
      name: name,
      id: id,
      version: version,
      source: source != null
          ? Info<String>(value: source, title: PackageAttribute.source.title)
          : null,
      otherInfos: otherInfos,
      screenshots: screenshots,
      publisherIcon: publisherIcon,
    );
  }
}
