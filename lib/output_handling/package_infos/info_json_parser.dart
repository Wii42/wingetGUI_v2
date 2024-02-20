import 'package:winget_gui/output_handling/package_infos/agreement_infos.dart';

import 'package:winget_gui/output_handling/package_infos/info.dart';

import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import 'info_api_parser.dart';
import 'package:dart_casing/dart_casing.dart';

class InfoJsonParser extends InfoApiParser<String> {
  List<dynamic>? agreements;
  InfoJsonParser({required super.map, this.agreements});

  @override
  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromJsonMap(map: map, agreementsMap: agreementMap);
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
      if(tags.isNotEmpty) {
        return tags;
      }
    }
    return null;
  }

  @override
  String? valueToString(value) {
    if (value is Map<String, dynamic>) {
      value.remove('\$type');
      Map<String, String?> other = value
          .map((key, value) => MapEntry(key.toString(), valueToString(value)));
      other.removeWhere((key, value) => value == null);
      Map<String, String> nonNulls = other.cast<String, String>();
      if (nonNulls.length == 1) {
        return nonNulls.values.first;
      }
      return nonNulls.isNotEmpty ? nonNulls.toString() : null;
    }
    if (value is List) {
      List list = value.map<String?>((e) => valueToString(e)).nonNulls.toList();
      if (list.length == 1) {
        return list.first;
      }
      return list.isNotEmpty ? list.toString() : null;
    }
    return value.toString();
  }

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    assert(attribute.apiKey != null);
    dynamic node = map[attribute.apiKey];
    String? detail = (node != null) ? valueToString(node) : null;
    map.remove(attribute.apiKey!);
    return (detail != null)
        ? Info<String>.fromAttribute(attribute, value: detail)
        : null;
  }

  Map<String, String>? get agreementMap {
    if (agreements == null) return null;
    Iterable<MapEntry<String?, String?>> nullableMap =
        agreements!.map<MapEntry<String?, String?>>((e) {
      String? key = e['AgreementLabel'];
      if (key != null) {
        key = Casing.pascalCase(key);
      }
      String? value = e['AgreementUrl'] ?? e['Agreement'];
      return MapEntry(key, value);
    });
    Iterable<MapEntry<String, String>> nonNulls = nullableMap
        .where((element) => element.key != null && element.value != null)
        .map((e) => MapEntry(e.key!, e.value!));
    if (nonNulls.isEmpty) return null;
    return Map.fromEntries(nonNulls);
  }
}
