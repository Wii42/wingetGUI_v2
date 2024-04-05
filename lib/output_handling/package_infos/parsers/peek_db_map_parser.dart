import 'info_abstract_map_parser.dart';
import 'info_db_map_parser.dart';
import 'peek_abstract_map_parser.dart';

class PeekDBMapParser extends PeekAbstractMapParser<String, dynamic> {
  PeekDBMapParser(super.details);

  @override
  Map<String, dynamic> flattenedDetailsMap() => details;

  @override
  InfoAbstractMapParser<String, dynamic> getParser(Map<String, dynamic> map) =>
      InfoDBMapParser(map: map);
}
