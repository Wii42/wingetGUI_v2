import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/info_db_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/parsers/peek_abstract_map_parser.dart';

class PeekDBMapParser extends PeekAbstractMapParser<String, dynamic> {
  PeekDBMapParser(super.details);

  @override
  Map<String, dynamic> flattenedDetailsMap() => details;

  @override
  InfoAbstractMapParser<String, dynamic> getParser(Map<String, dynamic> map) =>
      InfoDBMapParser(map: map);
}
