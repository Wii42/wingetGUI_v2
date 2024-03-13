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
  InfoMapParser getInfoParser(Map<String, String> details) =>
      _getParser(details);

  @override
  InfoMapParser getInstallerParser(Map<String, String> installerDetails) =>
      _getParser(installerDetails);

  @override
  InfoMapParser getAgreementParser(Map<String, String> agreementDetails) =>
      _getParser(agreementDetails);

  InfoMapParser _getParser(Map<String, String> details) {
    return InfoMapParser(map: details, locale: locale);
  }
}
