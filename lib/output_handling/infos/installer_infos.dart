import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'app_attribute.dart';
import 'info.dart';
import 'info_map_parser.dart';

class InstallerInfos {
  final String Function(AppLocalizations) title;
  final Info<String>? type, sha256Hash, locale, storeProductID;
  final Info<Uri>? url;
  final Info<DateTime>? releaseDate;
  final Map<String, String>? otherInfos;

  InstallerInfos({
    required this.title,
    this.type,
    this.url,
    this.sha256Hash,
    this.locale,
    this.storeProductID,
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
    return InstallerInfos(
        title: AppAttribute.installer.title,
        type: parser.maybeDetailFromMap(AppAttribute.installerType),
        url: parser.maybeLinkFromMap(AppAttribute.installerURL),
        sha256Hash: parser.maybeDetailFromMap(AppAttribute.sha256Installer),
        locale: parser.maybeDetailFromMap(AppAttribute.installerLocale),
        storeProductID: parser.maybeDetailFromMap(AppAttribute.storeProductID),
        releaseDate: parser.maybeDateTimeFromMap(AppAttribute.releaseDate),
        otherInfos: installerDetails);
  }
}
