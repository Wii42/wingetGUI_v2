import 'package:winget_gui/output_handling/package_infos/parsers/info_abstract_map_parser.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';

import '../info.dart';
import '../info_with_link.dart';

abstract class InfoApiParser<A> extends InfoAbstractMapParser<A, dynamic> {
  InfoApiParser({required super.map});

  @override
  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    assert(attribute.apiKey != null, '$attribute has no apiKey');
    dynamic node = map[attribute.apiKey];
    String? detail = (node != null) ? valueToString(node) : null;
    map.remove(attribute.apiKey!);
    return (detail != null)
        ? Info<String>.fromAttribute(attribute, value: detail)
        : null;
  }

  String? valueToString(dynamic value) {
    return value.toString();
  }

  @override
  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    return InfoWithLink.maybeFromApiMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
    );
  }

  @override
  Map<String, String>? getOtherInfos() {
    map.remove('\$type');
    if (map.isEmpty) return null;
    Map<String, String?> other =
        map.map((key, value) => MapEntry(key.toString(), valueToString(value)));
    other.removeWhere((key, value) => value == null);
    return other.cast<String, String>();
  }

  Info<T>? maybeFromMap<T extends Object>(PackageAttribute attribute,
      {required T Function(dynamic) parser}) {
    Object? node = map[attribute.apiKey];
    if (node == null) {
      return null;
    }
    map.remove(attribute.apiKey!);
    return Info<T>.fromAttribute(attribute, value: parser(node));
  }
}
