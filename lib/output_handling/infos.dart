import 'package:winget_gui/helpers/extensions/string_map_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'infos/info_enum.dart';

class Infos {
  final Map<String, String> details;
  final Map<String, String>? installerDetails;
  final List<String>? tags;

  Infos({required this.details, this.installerDetails, this.tags});

  bool hasInstallerDetails() => installerDetails != null;

  bool hasTags() => tags != null;

  Map<String, String> get allDetails {
    Map<String, String> allDetails = {};
    allDetails.addAll(details);
    if (hasInstallerDetails()) {
      allDetails.addAll(installerDetails!);
    }
    return allDetails;
  }

  bool hasVersion(AppLocalizations locale) =>
      (details.hasInfo(Info.version, locale) &&
          details[Info.version.key(locale)]! != 'Unknown');

  bool hasDescription(AppLocalizations locale) =>
      details.hasInfo(Info.description, locale);

  bool hasReleaseNotes(AppLocalizations locale) =>
      details.hasInfo(Info.releaseNotes, locale);
}
