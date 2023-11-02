import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../winget_commands.dart';

enum PackageAttribute {
  id(copyable: true, couldBeLink: false, yamlKey: 'PackageIdentifier'),
  description(yamlKey: 'Description'),
  shortDescription(yamlKey: 'ShortDescription'),
  name(yamlKey: 'PackageName'),
  publisher(yamlKey: 'Publisher'),
  publisherUrl(yamlKey: 'PublisherUrl'),
  publisherSupportUrl(yamlKey: 'PublisherSupportUrl'),
  version(couldBeLink: false,yamlKey: 'PackageVersion'),
  availableVersion(couldBeLink: false),
  tags(yamlKey: 'Tags'),
  releaseNotes(yamlKey: 'ReleaseNotes'),
  releaseNotesUrl(yamlKey: 'ReleaseNotesUrl'),
  installer,
  source,
  website(yamlKey: 'PackageUrl'),
  license(yamlKey: 'License'),
  licenseUrl(yamlKey: 'LicenseUrl'),
  copyright(yamlKey: 'Copyright'),
  copyrightUrl(yamlKey: 'CopyrightUrl'),
  privacyUrl(yamlKey: 'PrivacyUrl'),
  buyUrl(yamlKey: 'PurchaseUrl'),
  termsOfTransaction,
  seizureWarning,
  storeLicenseTerms,
  author(yamlKey: 'Author'),
  moniker(yamlKey: 'Moniker'),
  documentation(yamlKey: 'Documentations'),
  agreement,
  category,
  pricing,
  freeTrial,
  ageRating,
  installerType(yamlKey: 'InstallerType'),
  storeProductID(copyable: true),
  installerURL(yamlKey: 'InstallerUrl'),
  sha256Installer(copyable: true, yamlKey: 'InstallerSha256'),
  installerLocale(yamlKey: 'InstallerLocale'),
  packageLocale(yamlKey: 'PackageLocale'),
  releaseDate(yamlKey: 'ReleaseDate'),
  match,
  manifest,
  installers(yamlKey: 'Installers'),
  upgradeBehavior(yamlKey: 'UpgradeBehavior'),
  fileExtensions(yamlKey: 'FileExtensions', couldBeLink: false),
  platform(yamlKey: 'Platform'),
  architecture(yamlKey: 'Architecture'),
  minimumOSVersion(couldBeLink: false, yamlKey: 'MinimumOSVersion'),
  installScope(yamlKey: 'Scope'),
  signatureSha256(copyable: true, yamlKey: 'SignatureSha256'),
  elevationRequirement(yamlKey: 'ElevationRequirement'),
  productCode(copyable: true, yamlKey: 'ProductCode'),
  appsAndFeaturesEntries(yamlKey: 'AppsAndFeaturesEntries'),
  installerSwitches(yamlKey: 'InstallerSwitches'),
  installModes(yamlKey: 'InstallModes'),
  nestedInstallerType(yamlKey: 'NestedInstallerType'),
  availableCommands(yamlKey: 'Commands', couldBeLink: false),
  dependencies(yamlKey: 'Dependencies'),
  ;

  final bool copyable;
  final String? yamlKey;
  final bool couldBeLink;
  const PackageAttribute({this.copyable = false, this.couldBeLink = true, this.yamlKey});

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
