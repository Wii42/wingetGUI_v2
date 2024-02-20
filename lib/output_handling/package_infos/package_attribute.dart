import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../winget_commands.dart';

enum PackageAttribute {
  id(copyable: true, couldBeLink: false, apiKey: 'PackageIdentifier'),
  description(apiKey: 'Description'),
  shortDescription(apiKey: 'ShortDescription'),
  name(apiKey: 'PackageName'),
  publisher(apiKey: 'Publisher'),
  publisherUrl(apiKey: 'PublisherUrl'),
  publisherSupportUrl(apiKey: 'PublisherSupportUrl'),
  version(couldBeLink: false, apiKey: 'PackageVersion'),
  availableVersion(couldBeLink: false),
  tags(apiKey: 'Tags'),
  releaseNotes(apiKey: 'ReleaseNotes'),
  releaseNotesUrl(apiKey: 'ReleaseNotesUrl'),
  installer,
  source,
  website(apiKey: 'PackageUrl'),
  license(apiKey: 'License'),
  licenseUrl(apiKey: 'LicenseUrl'),
  copyright(apiKey: 'Copyright'),
  copyrightUrl(apiKey: 'CopyrightUrl'),
  privacyUrl(apiKey: 'PrivacyUrl'),
  buyUrl(apiKey: 'PurchaseUrl'),
  termsOfTransaction(apiKey: 'TermsOfTransaction'),
  seizureWarning(apiKey: 'SeizureWarning'),
  storeLicenseTerms(apiKey: 'StoreLicenseTerms'),
  author(apiKey: 'Author'),
  moniker(apiKey: 'Moniker'),
  documentation(apiKey: 'Documentations'),
  agreement(apiKey: 'Agreements'),
  category(apiKey: 'Category'),
  pricing(apiKey: 'Pricing'),
  freeTrial(apiKey: 'FreeTrial'),
  ageRating,
  installerType(apiKey: 'InstallerType'),
  storeProductID(apiKey: 'MSStoreProductIdentifier', copyable: true),
  installerURL(apiKey: 'InstallerUrl'),
  sha256Installer(copyable: true, apiKey: 'InstallerSha256'),
  installerLocale(apiKey: 'InstallerLocale'),
  packageLocale(apiKey: 'PackageLocale'),
  releaseDate(apiKey: 'ReleaseDate'),
  match,
  manifest,
  installers(apiKey: 'Installers'),
  upgradeBehavior(apiKey: 'UpgradeBehavior'),
  fileExtensions(apiKey: 'FileExtensions', couldBeLink: false),
  platform(apiKey: 'Platform'),
  architecture(apiKey: 'Architecture'),
  minimumOSVersion(couldBeLink: false, apiKey: 'MinimumOSVersion'),
  installScope(apiKey: 'Scope'),
  signatureSha256(copyable: true, apiKey: 'SignatureSha256'),
  elevationRequirement(apiKey: 'ElevationRequirement'),
  productCode(copyable: true, apiKey: 'ProductCode'),
  appsAndFeaturesEntries(apiKey: 'AppsAndFeaturesEntries'),
  installerSwitches(apiKey: 'InstallerSwitches'),
  installModes(apiKey: 'InstallModes'),
  nestedInstallerType(apiKey: 'NestedInstallerType'),
  availableCommands(apiKey: 'Commands', couldBeLink: false),
  dependencies(apiKey: 'Dependencies'),
  protocols(apiKey: 'Protocols', couldBeLink: false),
  markets(apiKey: 'Markets'),
  packageFamilyName(apiKey: 'PackageFamilyName', copyable: true),
  ;

  final bool copyable;
  final String? apiKey;
  final bool couldBeLink;
  const PackageAttribute(
      {this.copyable = false, this.couldBeLink = true, this.apiKey});

  String key(AppLocalizations local) {
    String key = local.infoKey(this.name);
    if (key == notFoundError) {
      throw Exception("$key: ${this.name} in AppAttributes.key");
    }
    return key;
  }

  String title(AppLocalizations local) {
    String title = local.infoTitle(this.name);
    if (title == notFoundError) {
      throw Exception("$title: ${this.name} in AppAttributes.title");
    }
    return title;
  }
}
