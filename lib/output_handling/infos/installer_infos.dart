import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'info_enum.dart';
import 'info_map_parser.dart';

class InstallerInfos {
  final String? type, sha256Hash, locale;
  final Uri? url;
  final DateTime? releaseDate;
  final Map<String, String>? otherInfos;

  InstallerInfos({
    this.type,
    this.url,
    this.sha256Hash,
    this.locale,
    this.releaseDate,
    this.otherInfos,
  });

  static maybeFromMap(
      {required Map<String, String>? installerDetails,
        required AppLocalizations locale}) {
    if (installerDetails == null || installerDetails.isEmpty) {
      return null;
    }
    InfoMapParser parser = InfoMapParser(map: installerDetails, locale: locale);
    String? releaseDateString = parser.maybeDetailFromMap(Info.releaseDate);
    DateTime? releaseDate = (releaseDateString != null
        ? DateTime.tryParse(releaseDateString)
        : null);
    return InstallerInfos(
        type: parser.maybeDetailFromMap(Info.installerType),
        url: parser.maybeLinkFromMap(Info.installerURL),
        sha256Hash: parser.maybeDetailFromMap(Info.sha256Installer),
        locale: parser.maybeDetailFromMap(Info.installerLocale),
        releaseDate: releaseDate,
        otherInfos: installerDetails);
  }
}