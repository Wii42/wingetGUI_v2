import 'package:winget_gui/output_handling/package_infos/installer_objects/dependencies.dart';
import 'package:yaml/yaml.dart';

import 'agreement_infos.dart';
import 'info.dart';
import 'info_api_parser.dart';
import 'info_with_link.dart';
import 'installer_objects/expected_return_code.dart';
import 'package_attribute.dart';

class InfoYamlParser extends InfoApiParser<dynamic> {
  InfoYamlParser({required super.map});

  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(
      PackageAttribute attribute) {
    YamlList? node = map[attribute.apiKey!];
    if (node == null || node.value.isEmpty) {
      return null;
    }
    if (node.value is YamlList) {
      List<Map> entries = node.value.map<Map>((e) => e as Map).toList();
      if (entries.every((element) =>
          element.containsKey('DocumentLabel') &&
          element.containsKey('DocumentUrl'))) {
        List<InfoWithLink> linkList = entries
            .map<InfoWithLink>(
              (e) => InfoWithLink(
                title: (_) => e['DocumentLabel'],
                text: e['DocumentLabel'],
                url: Uri.parse(e['DocumentUrl']),
              ),
            )
            .toList();
        map.remove(attribute.apiKey!);
        return Info<List<InfoWithLink>>.fromAttribute(attribute,
            value: linkList);
      }
    }

    List<InfoWithLink> list = node.map((element) {
      if (element is YamlMap) {
        return InfoWithLink(
            title: (_) => element.keys.join(', '),
            text: element['DocumentLabel'],
            url: Uri.tryParse(element['DocumentUrl']));
      }
      return InfoWithLink(
          title: (_) => element.toString(), text: element.toString());
    }).toList();
    map.remove(attribute.apiKey!);
    return Info<List<InfoWithLink>>.fromAttribute(attribute, value: list);
  }

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic) parser}) {
    YamlList? node = map[attribute.apiKey!];
    if (node == null || node.value.isEmpty) {
      return null;
    }
    map.remove(attribute.apiKey!);
    return Info<List<T>>.fromAttribute(attribute,
        value: node.value.map<T>(parser).toList());
  }

  @override
  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromYamlMap(map: map);
  }

  @override
  List<String>? maybeTagsFromMap() {
    String key = PackageAttribute.tags.apiKey!;
    YamlList? tagList = map[key] as YamlList?;
    if (tagList != null) {
      List<String> tags = tagList.map((element) => element.toString()).toList();
      map.remove(key);
      return tags;
    }
    return null;
  }

  Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    return maybeFromMap<Dependencies>(dependencies,
        parser: (e) => Dependencies.fromYamlMap(e));
  }

  @override
  String? valueToString(value) {
    if (value is YamlMap) {
      Map<dynamic, dynamic> valueMap = value;
      Map<String, String?> other = valueMap
          .map((key, value) => MapEntry(key.toString(), valueToString(value)));
      other.removeWhere((key, value) => value == null);
      Map<String, String> nonNulls = other.cast<String, String>();
      if (nonNulls.length == 1) {
        return nonNulls.values.first;
      }
      return nonNulls.isNotEmpty ? nonNulls.toString() : null;
    }
    if (value is YamlList) {
      List list =
          value.value.map<String?>((e) => valueToString(e)).nonNulls.toList();
      if (list.length == 1) {
        return list.first;
      }
      return list.isNotEmpty ? list.toString() : null;
    }
    return value.toString();
  }
}
