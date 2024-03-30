
import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';

import '../../../package_sources/package_source.dart';
import '../info.dart';
import '../package_attribute.dart';
import '../package_infos_peek.dart';
import 'abstract_map_parser.dart';

abstract class PeekAbstractMapParser<A, B> extends AbstractMapParser<A, B, PackageInfosPeek> {

  PeekAbstractMapParser(super.details);

  /// Parses the details of the package and returns a [PackageInfosPeek] object.
  @override
  PackageInfosPeek parse() {
    Map<A, B> detailsMap = flattenedDetailsMap();
    InfoAbstractMapParser<A, B> p = getParser(detailsMap);
    Info<PackageSources>? source = p.sourceFromMap(PackageAttribute.source);
    PackageInfosPeek infos = PackageInfosPeek(
      name: p.maybeStringFromMap(PackageAttribute.name),
      id: p.maybePackageIdFromMap(PackageAttribute.id, source: source.value),
      version: p.maybeVersionOrStringFromMap(PackageAttribute.version),
      availableVersion: p.maybeVersionOrStringFromMap(PackageAttribute.availableVersion),
      match: p.maybeStringFromMap(PackageAttribute.match),
      source: source,
      otherInfos: p.otherDetails(),
    );
    return infos..setImplicitInfos();
  }
}
