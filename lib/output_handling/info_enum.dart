import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_commands.dart';

enum Info {
  id(title: 'App ID'),
  description(title: 'About'),
  name(title: 'Name'),
  publisher(title: 'Publisher'),
  publisherUrl(title: 'Publisher URL'),
  publisherSupportUrl(title: 'Support'),
  version(title: 'Version'),
  availableVersion(title: 'Available'),
  tags(title: 'Tags'),
  releaseNotes(title: 'Release Notes'),
  releaseNotesUrl(title: 'Show Online'),
  installer(title: 'Installer'),
  source(title: 'Source'),
  website(title: 'Website'),
  license(title: 'License'),
  licenseUrl(title: 'License'),
  copyright(title: 'Copyright'),
  copyrightUrl(title: 'Copyright'),
  privacyUrl(title: 'Privacy'),
  buyUrl(title: 'Buy'),
  termsOfTransaction(title: 'Terms of Transaction'),
  seizureWarning(title: 'Seizure Warning'),
  storeLicenseTerms(title: 'Store License Terms'),
  author(title: 'Author'),
  moniker(title: 'Moniker'),
  documentation(title: 'Documentation'),
  agreement(title: 'Agreement'),
  category(title: 'Category'),
  pricing(title: 'Pricing'),
  freeTrial(title: 'Free Trial'),
  ageRating(title: 'Age Rating'),
  installerType(title: 'Installer Type'),
  storeProductID(title: 'Store Product ID'),
  installerURL(title: 'Download Installer Manually'),
  sha256Installer(title: 'SHA256 Installer'),
  installerLocale(title: 'Locale'),
  releaseDate(title: 'Release Date'),
  ;

  final String title;

  const Info({required this.title});

  String key(AppLocalizations local) {
    String key = local.infoKey(this.name);
    if (key == notFoundError) {
      throw Exception(key);
    }
    return key;
  }
}
