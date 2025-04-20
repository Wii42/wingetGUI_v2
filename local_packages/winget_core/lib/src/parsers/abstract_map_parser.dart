import 'package:winget_core/winget_core.dart';

import 'info_abstract_map_parser.dart';

abstract class AbstractMapParser<A, B, T extends PackageInfos> {
  Map<A, B> details;

  AbstractMapParser(this.details);

  /// Parses the details of the package and returns a [PackageInfos] object.
  T parse();

  /// Returns a map with all the details of the package.
  Map<A, B> flattenedDetailsMap();

  /// Returns the parser to be used to parse the details.
  InfoAbstractMapParser<A, B> getParser(Map<A, B> map);
}
