import 'package:winget_core/winget_core.dart';

import 'full_abstract_map_parser.dart';
import 'info_map_parser.dart';

class FullMapParser extends FullAbstractMapParser<String, String> {
  Map<String, String> installerDetails;
  PackageLocalizer localizer;

  FullMapParser({
    Map<String, String> details = const {},
    this.installerDetails = const {},
    required this.localizer,
  }) : super(details);

  @override
  Map<String, String> flattenedDetailsMap() => details;

  @override
  Iterable<Map<String, String>> flattenedInstallerList() => [installerDetails];

  @override
  InfoMapParser getParser(Map<String, String> map) {
    return InfoMapParser(map: map, locale: localizer);
  }
}
