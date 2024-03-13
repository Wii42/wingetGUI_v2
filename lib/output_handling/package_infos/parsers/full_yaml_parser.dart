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
  InfoYamlParser getInfoParser(Map<dynamic, dynamic> details) =>
      _getParser(details);

  @override
  InfoYamlParser getInstallerParser(Map<dynamic, dynamic> installerDetails) =>
      _getParser(installerDetails);

  @override
  InfoYamlParser getAgreementParser(Map<dynamic, dynamic> agreementDetails) =>
      _getParser(agreementDetails);

  InfoYamlParser _getParser(Map<dynamic, dynamic> details) {
    return InfoYamlParser(map: details);
  }
}
