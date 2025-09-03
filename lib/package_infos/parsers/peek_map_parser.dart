import 'package:winget_core/winget_core.dart';
import 'package:winget_core/winget_parsers.dart';

import 'info_map_parser.dart';

class PeekMapParser extends PeekAbstractMapParser<String, String> {
  PackageLocalizer locale;

  PeekMapParser({required Map<String, String> details, required this.locale})
    : super(details);

  @override
  Map<String, String> flattenedDetailsMap() => details;

  @override
  InfoAbstractMapParser<String, String> getParser(Map<String, String> map) {
    return InfoMapParser(map: map, locale: locale);
  }
}
