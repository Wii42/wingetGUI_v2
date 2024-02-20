import 'package:winget_gui/output_handling/package_infos/agreement_infos.dart';

import 'package:winget_gui/output_handling/package_infos/info.dart';

import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import 'info_api_parser.dart';

class InfoJsonParser extends InfoApiParser<String> {
  InfoJsonParser({required super.map});

  @override
  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromJsonMap(map: map);
  }

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic p1) parser}) {
    dynamic node = map[attribute.apiKey!];
    if (node == null || node is! List) {
      return null;
    }
    map.remove(attribute.apiKey!);
    return Info<List<T>>.fromAttribute(attribute,
        value: node.map<T>(parser).toList());
  }

  @override
  List<String>? maybeTagsFromMap() {
    String key = PackageAttribute.tags.apiKey!;
    List<dynamic>? tagList = map[key] as List?;
    if (tagList != null) {
      List<String> tags = tagList.map((element) => element.toString()).toList();
      map.remove(key);
      return tags;
    }
    return null;
  }
}
