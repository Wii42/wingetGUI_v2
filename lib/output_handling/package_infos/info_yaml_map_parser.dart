import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:yaml/yaml.dart';

import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'package_attribute.dart';

class InfoYamlMapParser {
  Map<dynamic, dynamic> map;
  InfoYamlMapParser({required this.map});

  Info<String>? maybeDetailFromMap(PackageAttribute attribute,
      {required String key}) {
    dynamic node = map[key];
    String? detail = (node != null) ? node.toString() : null;
    map.remove(key);
    return (detail != null)
        ? Info<String>(title: attribute.title, value: detail)
        : null;
  }

  Info<Uri>? maybeLinkFromMap(PackageAttribute infoKey, {required String key}) {
    Info<String>? link = maybeDetailFromMap(infoKey, key: key);
    if (link == null) {
      return null;
    }
    return Info<Uri>(title: link.title, value: Uri.parse(link.value));
  }

  Info<List<InfoWithLink>>? maybeDocumentationsFromMap(
      PackageAttribute attribute,
      {required String key}) {
    YamlList? node = map[key];
    if (node == null || node.value.isEmpty) {
      return null;
    }
    print(node.value.runtimeType);
    if (node.value is YamlList) {
      List<Map> entries = node.value.map<Map>((e) => e as Map).toList();
      if (entries.every((element) =>
          element.containsKey('DocumentLabel') &&
          element.containsKey('DocumentUrl'))) {
        List<InfoWithLink> linkList = entries
            .map<InfoWithLink>((e) =>
                InfoWithLink(title:(_) =>  e['DocumentLabel'], text:  e['DocumentLabel'],url: Uri.parse(e['DocumentUrl'])))
            .toList();
        print(linkList);
        map.remove(key);
        return Info<List<InfoWithLink>>(
            title: attribute.title, value: linkList);
      }
    }

    List<InfoWithLink> list = node
        .map((element) => InfoWithLink(title: (_) => element.toString()))
        .toList();
    map.remove(key);
    return Info<List<InfoWithLink>>(title: attribute.title, value: list);
  }

  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromYamlMap(
      map: map,
    );
  }

  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo,
      required String textKey,
      required String urlKey}) {
    return InfoWithLink.maybeFromYamlMap(
      map: map,
      textInfo: textInfo,
      textKey: textKey,
      urlKey: urlKey,
    );
  }

  Info<DateTime>? maybeDateTimeFromMap(PackageAttribute attribute,
      {required String key}) {
    Info<String>? dateInfo = maybeDetailFromMap(attribute, key: key);
    if (dateInfo == null) {
      return null;
    }
    return Info<DateTime>(
        title: dateInfo.title, value: DateTime.parse(dateInfo.value));
  }

  List<String>? maybeTagsFromMap() {
    String key = 'Tags';
    YamlList? tagList = map[key] as YamlList?;
    if (tagList != null) {
      List<String> tags = tagList.map((element) => element.toString()).toList();
      map.remove(key);
      return tags;
    }
    return null;
  }
}
