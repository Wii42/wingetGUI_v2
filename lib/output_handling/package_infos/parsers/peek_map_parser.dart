import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/peek_abstract_map_parser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'info_map_parser.dart';

class PeekMapParser extends PeekAbstractMapParser<String, String> {
  AppLocalizations locale;

  PeekMapParser({required Map<String, String> details, required this.locale})
      : super(details);

  @override
  Map<String, String> flattenedDetailsMap() => details;

  @override
  InfoAbstractMapParser<String, String> getParser(Map<String, String> map) {
    return InfoMapParser(map: map, locale: locale);
  }
}
