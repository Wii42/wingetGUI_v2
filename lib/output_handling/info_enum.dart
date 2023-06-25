import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../winget_commands.dart';

enum Info {
  id(),
  description(),
  name(),
  publisher(),
  publisherUrl(),
  publisherSupportUrl(),
  version(),
  availableVersion(),
  tags(),
  releaseNotes(),
  releaseNotesUrl(),
  installer(),
  source(),
  website(),
  license(),
  licenseUrl(),
  copyright(),
  copyrightUrl(),
  privacyUrl(),
  buyUrl(),
  termsOfTransaction(),
  seizureWarning(),
  storeLicenseTerms(),
  author(),
  moniker(),
  documentation(),
  agreement(),
  category(),
  pricing(),
  freeTrial(),
  ageRating(),
  installerType(),
  storeProductID(),
  installerURL(),
  sha256Installer(),
  installerLocale(),
  releaseDate(),
  ;

  const Info();

  String key(AppLocalizations local) {
    String key = local.infoKey(this.name);
    if (key == notFoundError) {
      throw Exception(key);
    }
    return key;
  }

  String title(AppLocalizations local) {
    String title = local.infoTitle(this.name);
    if (title == notFoundError) {
      throw Exception(title);
    }
    return title;
  }
}
