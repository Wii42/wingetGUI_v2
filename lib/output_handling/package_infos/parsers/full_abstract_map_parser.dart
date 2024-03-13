import 'package:winget_gui/output_handling/package_infos/agreement_infos.dart';
import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';
import 'package:winget_gui/output_handling/package_infos/package_infos_full.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';

import '../package_attribute.dart';

abstract class FullAbstractMapParser<A, B> {
  Map<A, B> details;

  FullAbstractMapParser(this.details);

  /// Parses the details of the package and returns a [PackageInfosFull] object.
  PackageInfosFull parse() {
    Map<A, B> detailsMap = flattenedDetailsMap();
    InfoAbstractMapParser<A, B> p = getParser(detailsMap);
    PackageInfosFull infos = PackageInfosFull(
      name: p.maybeStringFromMap(PackageAttribute.name),
      id: p.maybeStringFromMap(PackageAttribute.id),
      description: p.maybeStringFromMap(PackageAttribute.description),
      shortDescription: p.maybeStringFromMap(PackageAttribute.shortDescription),
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
      installer: parseInstallerInfos(),
      source: p.sourceFromMap(PackageAttribute.source),
      otherInfos: p.otherDetails(),
    );
    return infos..setImplicitInfos();
  }

  InstallerInfos? parseInstallerInfos() {
    InfoAbstractMapParser<A, B> p = getParser(flattenedInstallerDetailsMap());
    return InstallerInfos(
      title: PackageAttribute.installer.title,
      type: p.maybeInstallerTypeFromMap(PackageAttribute.installerType),
      url: p.maybeLinkFromMap(PackageAttribute.installerURL),
      sha256Hash: p.maybeStringFromMap(PackageAttribute.sha256Installer),
      locale: p.maybeInstallerLocaleFromMap(PackageAttribute.installerLocale),
      storeProductID: p.maybeStringFromMap(PackageAttribute.storeProductID),
      releaseDate: p.maybeDateTimeFromMap(PackageAttribute.releaseDate),
      installers: p.maybeInstallersFromMap(PackageAttribute.installers),
      upgradeBehavior:
          p.maybeUpgradeBehaviorFromMap(PackageAttribute.upgradeBehavior),
      fileExtensions: p.maybeStringListFromMap(PackageAttribute.fileExtensions),
      platform: p.maybePlatformFromMap(PackageAttribute.platform),
      minimumOSVersion:
          p.maybeVersionOrStringFromMap(PackageAttribute.minimumOSVersion),
      scope: p.maybeScopeFromMap(PackageAttribute.installScope),
      installModes: p.maybeInstallModesFromMap(PackageAttribute.installModes),
      installerSwitches:
          p.maybeStringFromMap(PackageAttribute.installerSwitches),
      elevationRequirement:
          p.maybeStringFromMap(PackageAttribute.elevationRequirement),
      productCode: p.maybeStringFromMap(PackageAttribute.productCode),
      appsAndFeaturesEntries:
          p.maybeStringFromMap(PackageAttribute.appsAndFeaturesEntries),
      nestedInstallerType:
          p.maybeInstallerTypeFromMap(PackageAttribute.nestedInstallerType),
      availableCommands:
          p.maybeStringListFromMap(PackageAttribute.availableCommands),
      protocols: p.maybeStringListFromMap(PackageAttribute.protocols),
      dependencies: p.maybeDependenciesFromMap(PackageAttribute.dependencies),
      expectedReturnCodes: p.maybeExpectedReturnCodesFromMap(
          PackageAttribute.expectedReturnCodes),
      successCodes: p.maybeListFromMap(PackageAttribute.installerSuccessCodes,
          parser: (e) => int.parse(e.toString())),
      otherInfos: p.otherDetails(),
    );
  }

  AgreementInfos? _parseAgreementInfos(Map<A, B> agreementDetails) {
    InfoAbstractMapParser<A, B> p = getParser(agreementDetails);
    AgreementInfos agreement = AgreementInfos(
      title: PackageAttribute.agreement.title,
      publisher: p.maybeInfoWithLinkFromMap(
          textInfo: PackageAttribute.publisher,
          urlInfo: PackageAttribute.publisherUrl),
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

  /// Returns a map with all the details of the package, except the installer details.
  Map<A, B> flattenedDetailsMap();

  /// Returns a map with all the details of the installer.
  Map<A, B> flattenedInstallerDetailsMap();

  /// Returns the parser to be used to parse the details.
  InfoAbstractMapParser<A, B> getParser(Map<A, B> map);
}
