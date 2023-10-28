import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../winget_commands.dart';

enum PackageAttribute {
  id(copyable: true),
  description,
  name,
  publisher,
  publisherUrl,
  publisherSupportUrl,
  version,
  availableVersion,
  tags,
  releaseNotes,
  releaseNotesUrl,
  installer,
  source,
  website,
  license,
  licenseUrl,
  copyright,
  copyrightUrl,
  privacyUrl,
  buyUrl,
  termsOfTransaction,
  seizureWarning,
  storeLicenseTerms,
  author,
  moniker,
  documentation,
  agreement,
  category,
  pricing,
  freeTrial,
  ageRating,
  installerType,
  storeProductID(copyable: true),
  installerURL,
  sha256Installer(copyable: true),
  installerLocale,
  packageLocale,
  releaseDate,
  match,
  manifest,
  installers,
  upgradeBehavior,
  fileExtensions,
  platform,
  architecture,
  minimumOSVersion,
  installScope,
  signatureSha256(copyable: true),
  elevationRequirement,
  productCode(copyable: true),
  appsAndFeaturesEntries,
  installerSwitches,
  installModes,
  ;

  final bool copyable;
  const PackageAttribute({this.copyable = false});

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
