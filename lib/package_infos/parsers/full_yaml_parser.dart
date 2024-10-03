import 'package:yaml/yaml.dart';

import '../package_attribute.dart';
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
  Iterable<Map<dynamic, dynamic>> flattenedInstallerList() {
    YamlList? yamlList = installerDetails[PackageAttribute.installers.apiKey];
    List<Map<dynamic, dynamic>> list = yamlList?.value
            .map<Map<dynamic, dynamic>>((dynamic e) => e.value)
            .toList() ??
        [];
    installerDetails.remove(PackageAttribute.installers.apiKey);
    List<Map<dynamic, dynamic>> base =
        List.generate(list.length, (index) => Map.from(installerDetails));
    for (int i = 0; i < list.length; i++) {
      // merge the installer details with the base details, in conflict the installer details will overwrite the base details
      base[i].addAll(list[i]);
    }
    return base;
  }

  @override
  InfoYamlParser getParser(Map<dynamic, dynamic> map) {
    return InfoYamlParser(map: map);
  }
}
