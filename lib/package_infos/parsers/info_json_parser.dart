import 'package:dart_casing/dart_casing.dart';

import '../info.dart';
import '../info_with_link.dart';
import '../installer_objects/dependencies.dart';
import '../installer_objects/installer.dart';
import '../package_attribute.dart';
import 'info_api_parser.dart';

class InfoJsonParser extends InfoApiParser<String> {
  List<dynamic>? agreements;
  InfoJsonParser({required super.map, this.agreements});

  @override
  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required T Function(dynamic) parser}) {
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
      if (tags.isNotEmpty) {
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

  @override
  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(
      PackageAttribute attribute) {
    return maybeValueFromMap(
        attribute,
        (p0) => [
              InfoWithLink(
                  title: (locale) => p0.toString(), text: p0.toString())
            ]);
  }

  @override
  Info<List<Installer>>? maybeInstallersFromMap(PackageAttribute installers) {
    return maybeListFromMap<Installer>(PackageAttribute.installers,
        parser: (map) {
      return Installer.fromJson(map);
    });
  }

  @override
  Info<Dependencies>? maybeDependenciesFromMap(PackageAttribute dependencies) {
    return maybeFromMap<Dependencies>(dependencies,
        parser: (e) => Dependencies());
  }
}
