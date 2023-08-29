import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'agreement_infos.dart';
import 'app_attribute.dart';
import 'info.dart';
import 'info_with_link.dart';

class InfoMapParser {
  AppLocalizations locale;
  Map<String, String> map;
  InfoMapParser({required this.map, required this.locale});

  Info<String>? maybeDetailFromMap(AppAttribute attribute) {
    String key = attribute.key(locale);
    String? detail = map[key];
    map.remove(key);
    return (detail != null)
        ? Info<String>(title: attribute.title, value: detail)
        : null;
  }

  Info<Uri>? maybeLinkFromMap(AppAttribute infoKey) {
    Info<String>? link = maybeDetailFromMap(infoKey);
    if (link == null) {
      return null;
    }
    return Info<Uri>(title: link.title, value: Uri.parse(link.value));
  }

  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromMap(
      map: map,
      locale: locale,
    );
  }

  InfoWithLink? maybeInfoWithLinkFromMap(
      {required AppAttribute textInfo, required AppAttribute urlInfo}) {
    return InfoWithLink.maybeFromMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
      locale: locale,
    );
  }

  Info<DateTime>? maybeDateTimeFromMap(AppAttribute attribute) {
    Info<String>? dateInfo = maybeDetailFromMap(AppAttribute.releaseDate);
    if (dateInfo == null) {
      return null;
    }
    return Info<DateTime>(
        title: dateInfo.title, value: DateTime.parse(dateInfo.value));
  }

  List<String>? maybeTagsFromMap() {
    String key = AppAttribute.tags.key(locale);
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
