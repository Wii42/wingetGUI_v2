import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/output_handling/package_infos/agreement_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/abstract_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';

import '../../../package_sources/package_source.dart';
import '../info.dart';
import '../installer_objects/computer_architecture.dart';
import '../installer_objects/installer.dart';
import '../package_attribute.dart';

abstract class FullAbstractMapParser<A, B>
    extends AbstractMapParser<A, B, PackageInfosFull> {
  FullAbstractMapParser(super.details);

  /// Parses the details of the package and returns a [PackageInfosFull] object.
  @override
  PackageInfosFull parse() {
    Map<A, B> detailsMap = flattenedDetailsMap();
    InfoAbstractMapParser<A, B> p = getParser(detailsMap);
    Info<String>? description =
        p.maybeStringFromMap(PackageAttribute.description);
    Info<String>? shortDescription = _getShortDescription(p, description);
    Info<PackageSources>? source = p.sourceFromMap(PackageAttribute.source);
    PackageInfosFull infos = PackageInfosFull(
      name: p.maybeStringFromMap(PackageAttribute.name),
      id: p.maybePackageIdFromMap(PackageAttribute.id, source: source.value),
      description: description,
      shortDescription: shortDescription,
      supportUrl: p.maybeLinkFromMap(PackageAttribute.publisherSupportUrl),
      version: p.maybeVersionOrStringFromMap(PackageAttribute.version),
      website: p.maybeLinkFromMap(PackageAttribute.website),
      author: p.maybeStringFromMap(PackageAttribute.author),
      moniker: p.maybeStringFromMap(PackageAttribute.moniker),
      documentation:
          p.maybeDocumentationsFromMap(PackageAttribute.documentation),
      category: p.maybeStringFromMap(PackageAttribute.category),
      pricing: p.maybeStringFromMap(PackageAttribute.pricing),
      freeTrial: p.maybeStringFromMap(PackageAttribute.freeTrial),
      ageRating: p.maybeStringFromMap(PackageAttribute.ageRating),
      releaseNotes: p.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.releaseNotes,
          urlInfo: PackageAttribute.releaseNotesUrl),
      agreement: _parseAgreementInfos(detailsMap),
      tags: p.maybeTagsFromMap(),
      packageLocale: p.maybeLocaleFromMap(PackageAttribute.packageLocale),
      installer: _parseInstallerInfos(),
      source: source,
      publisherInfo: p.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.publisher,
          urlInfo: PackageAttribute.publisherUrl),
      installationNotes:
          p.maybeStringFromMap(PackageAttribute.installationNotes),
      otherInfos: p.otherDetails(),
    );
    return infos..setImplicitInfos();
  }

  Info<String>? _getShortDescription(
      InfoAbstractMapParser<dynamic, dynamic> p, Info<String>? description) {
    Info<String>? shortDescription =
        p.maybeStringFromMap(PackageAttribute.shortDescription);
    if (shortDescription != null &&
        shortDescription.value.trim().endsWith('...') &&
        description != null) {
      String shortWithoutEllipsis =
          shortDescription.value.take(shortDescription.value.length - 3).trim();
      if (description.value.startsWith(shortWithoutEllipsis)) {
        shortDescription = p.maybeFirstLineFromInfo(description,
            destination: PackageAttribute.shortDescription);
      }
    }
    return shortDescription;
  }

  Info<List<Installer>>? _parseInstallerInfos() {
    Iterable<Map<A, B>> installerDetailsList = flattenedInstallerList();
    if (installerDetailsList.isEmpty) {
      return null;
    }
    return Info<List<Installer>>.fromAttribute(PackageAttribute.installer,
        value: installerDetailsList.map<Installer>(parseInstaller).toList());
  }

  Installer parseInstaller(Map<A, B> map) {
    InfoAbstractMapParser<A, B> p = getParser(map);
    return Installer(
      architecture: p.maybeArchitectureFromMap(PackageAttribute.architecture) ??
          fallbackArchitecture,
      url: p.maybeLinkFromMap(PackageAttribute.installerURL),
      sha256Hash: p.maybeStringFromMap(PackageAttribute.sha256Installer),
      locale: p.maybeInstallerLocaleFromMap(PackageAttribute.installerLocale),
      platform: p.maybePlatformFromMap(PackageAttribute.platform),
      minimumOSVersion:
          p.maybeVersionOrStringFromMap(PackageAttribute.minimumOSVersion),
      type: p.maybeInstallerTypeFromMap(PackageAttribute.installerType),
      scope: p.maybeScopeFromMap(PackageAttribute.installScope),
      signatureSha256: p.maybeStringFromMap(PackageAttribute.signatureSha256),
      elevationRequirement:
          p.maybeStringFromMap(PackageAttribute.elevationRequirement),
      productCode: p.maybeStringFromMap(PackageAttribute.productCode),
      appsAndFeaturesEntries:
          p.maybeStringFromMap(PackageAttribute.appsAndFeaturesEntries),
      switches: p.maybeStringFromMap(PackageAttribute.installerSwitches),
      modes: p.maybeInstallModesFromMap(PackageAttribute.installModes),
      nestedInstallerType:
          p.maybeInstallerTypeFromMap(PackageAttribute.nestedInstallerType),
      upgradeBehavior:
          p.maybeUpgradeBehaviorFromMap(PackageAttribute.upgradeBehavior),
      availableCommands:
          p.maybeStringListFromMap(PackageAttribute.availableCommands),
      storeProductID: p.maybeStringFromMap(PackageAttribute.storeProductID),
      markets: p.maybeStringFromMap(PackageAttribute.markets),
      packageFamilyName:
          p.maybeStringFromMap(PackageAttribute.packageFamilyName),
      expectedReturnCodes: p.maybeExpectedReturnCodesFromMap(
          PackageAttribute.expectedReturnCodes),
      releaseDate: p.maybeDateTimeFromMap(PackageAttribute.releaseDate),
      fileExtensions: p.maybeStringListFromMap(PackageAttribute.fileExtensions),
      protocols: p.maybeStringListFromMap(PackageAttribute.protocols),
      dependencies: p.maybeDependenciesFromMap(PackageAttribute.dependencies),
      successCodes: p.maybeListFromMap(PackageAttribute.installerSuccessCodes,
          parser: (e) => int.parse(e.toString())),
      other: p.otherDetails() ?? {},
    );
  }

  static final Info<ComputerArchitecture> fallbackArchitecture =
      Info<ComputerArchitecture>.fromAttribute(PackageAttribute.architecture,
          value: ComputerArchitecture.matchAll);

  AgreementInfos? _parseAgreementInfos(Map<A, B> agreementDetails) {
    InfoAbstractMapParser<A, B> p = getParser(agreementDetails);
    AgreementInfos agreement = AgreementInfos(
      title: PackageAttribute.agreement.title,
      license: p.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.license,
          urlInfo: PackageAttribute.licenseUrl),
      copyright: p.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.copyright,
          urlInfo: PackageAttribute.copyrightUrl),
      privacyUrl: p.maybeLinkFromMap(PackageAttribute.privacyUrl),
      buyUrl: p.maybeLinkFromMap(PackageAttribute.buyUrl),
      termsOfTransaction:
          p.maybeStringFromMap(PackageAttribute.termsOfTransaction),
      seizureWarning: p.maybeStringFromMap(PackageAttribute.seizureWarning),
      storeLicenseTerms:
          p.maybeStringFromMap(PackageAttribute.storeLicenseTerms),
    );
    return agreement.isNotEmpty() ? agreement : null;
  }

  AgreementInfos? parseAgreementInfos() {
    Map<A, B> agreementDetails = flattenedDetailsMap();
    return _parseAgreementInfos(agreementDetails);
  }

  /// Returns an iterable with all the installer details of the package.
  Iterable<Map<A, B>> flattenedInstallerList();
}
