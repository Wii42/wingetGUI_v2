import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'package_attribute.dart';

class InfoMapParser {
  AppLocalizations locale;
  Map<String, String> map;
  InfoMapParser({required this.map, required this.locale});

  Info<String>? maybeDetailFromMap(PackageAttribute attribute) {
    String key = attribute.key(locale);
    String? detail = map[key];
    map.remove(key);
    return (detail != null)
        ? Info<String>(title: attribute.title, value: detail)
        : null;
  }

  Info<Uri>? maybeLinkFromMap(PackageAttribute infoKey) {
    Info<String>? link = maybeDetailFromMap(infoKey);
    if (link == null) {
      return null;
    }
    return Info<Uri>(title: link.title, value: Uri.parse(link.value));
  }

  Info<List<InfoWithLink>>? maybeListWithLinksFromMap(PackageAttribute attribute) {
    Info<String>? list = maybeDetailFromMap(attribute);
    if (list == null) {
      return null;
    }
    return Info<List<InfoWithLink>>(title: list.title, value: list.value.split('\n').map((e) => InfoWithLink(title: attribute.title, text: e)).toList());
  }

  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromMap(
      map: map,
      locale: locale,
    );
  }

  InfoWithLink? maybeInfoWithLinkFromMap(
      {required PackageAttribute textInfo, required PackageAttribute urlInfo}) {
    return InfoWithLink.maybeFromMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
      locale: locale,
    );
  }

  Info<DateTime>? maybeDateTimeFromMap(PackageAttribute attribute) {
    Info<String>? dateInfo = maybeDetailFromMap(PackageAttribute.releaseDate);
    if (dateInfo == null) {
      return null;
    }
    return Info<DateTime>(
        title: dateInfo.title, value: DateTime.parse(dateInfo.value));
  }

  List<String>? maybeTagsFromMap() {
    String key = PackageAttribute.tags.key(locale);
    String? tagString = map[key];
    if (tagString != null) {
      List<String> tags = _extractTags(tagString);
      map.remove(key);
      return tags;
    }
    return null;
  }

  List<String> _extractTags(String tagString) {
    List<String> split = tagString.split('\n');
    return [
      for (String s in split)
        if (s.isNotEmpty) s.trim()
    ];
  }
}
