import 'dart:ui';

import 'package:winget_gui/output_handling/package_infos/installer_infos.dart';
import 'package:yaml/yaml.dart';

import '../../helpers/locale_parser.dart';
import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'package_attribute.dart';

class InfoYamlMapParser {
  Map<dynamic, dynamic> map;
  InfoYamlMapParser({required this.map});

  Info<String>? maybeStringFromMap(PackageAttribute attribute,
      {required String key}) {
    dynamic node = map[key];
    String? detail = (node != null) ? node.toString() : null;
    map.remove(key);
    return (detail != null)
        ? Info<String>(title: attribute.title, value: detail)
        : null;
  }

  Info<Uri>? maybeLinkFromMap(PackageAttribute infoKey, {required String key}) {
    Info<String>? link = maybeStringFromMap(infoKey, key: key);
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
    if (node.value is YamlList) {
      List<Map> entries = node.value.map<Map>((e) => e as Map).toList();
      if (entries.every((element) =>
          element.containsKey('DocumentLabel') &&
          element.containsKey('DocumentUrl'))) {
        List<InfoWithLink> linkList = entries
            .map<InfoWithLink>((e) => InfoWithLink(
                title: (_) => e['DocumentLabel'],
                text: e['DocumentLabel'],
                url: Uri.parse(e['DocumentUrl'])))
            .toList();
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

  Info<List<T>>? maybeListFromMap<T>(PackageAttribute attribute,
      {required String key, required T Function(dynamic) parser}) {
    YamlList? node = map[key];
    if (node == null || node.value.isEmpty) {
      return null;
    }
    map.remove(key);
    return Info<List<T>>(
        title: attribute.title, value: node.value.map<T>(parser).toList());
  }

  Info<List<String>>? maybeStringListFromMap(PackageAttribute attribute,
      {required String key}) {
    return maybeListFromMap(attribute, key: key, parser: (e) => e.toString());
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
    Info<String>? dateInfo = maybeStringFromMap(attribute, key: key);
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

  Info<Locale>? maybeLocaleFromMap(PackageAttribute packageLocale,
      {required String key}) {
    Info<String>? localeInfo = maybeStringFromMap(packageLocale, key: key);
    if (localeInfo == null) {
      return null;
    }
    return Info<Locale>(
        title: localeInfo.title, value: LocaleParser.parse(localeInfo.value));
  }

  Info<List<WindowsPlatform>>? maybePlatformFromMap(PackageAttribute platform,
      {required String key}) {
    return maybeListFromMap(platform,
        key: key, parser: (e) => WindowsPlatform.fromYaml(e));
  }
}
