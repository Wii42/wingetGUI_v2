import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import 'full_abstract_map_parser.dart';
import 'info_yaml_parser.dart';

class FullYamlParser extends FullAbstractMapParser<dynamic, dynamic> {
  Map<dynamic, dynamic> installerDetails;
  String? source;
  FullYamlParser(
      {Map<dynamic, dynamic> details = const {},
      this.installerDetails = const {},
      this.source})
      : super(details);

  @override
  Map<dynamic, dynamic> flattenedDetailsMap() {
    details[PackageAttribute.source.apiKey!] = source;
    return details;
  }

  @override
  Map<dynamic, dynamic> flattenedInstallerDetailsMap() => installerDetails;

  @override
  InfoYamlParser getParser(Map<dynamic, dynamic> map) {
    return InfoYamlParser(map: map);
  }
}
