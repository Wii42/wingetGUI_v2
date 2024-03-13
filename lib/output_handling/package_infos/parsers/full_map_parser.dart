import 'package:winget_gui/output_handling/package_infos/parsers/full_abstract_map_parser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'info_map_parser.dart';

class FullMapParser extends FullAbstractMapParser<String, String> {
  Map<String, String> installerDetails;
  AppLocalizations locale;
  FullMapParser(
      {Map<String, String> details = const {},
      this.installerDetails = const {},
      required this.locale})
      : super(details);

  @override
  Map<String, String> flattenedDetailsMap() => details;

  @override
  Map<String, String> flattenedInstallerDetailsMap() => installerDetails;

  @override
  InfoMapParser getParser(Map<String, String> map) {
    return InfoMapParser(map: map, locale: locale);
  }
}
