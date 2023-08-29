import 'package:winget_gui/output_handling/infos/package_infos.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'info_enum.dart';
import 'info_with_link.dart';

class InfoMapParser {
  AppLocalizations locale;
  Map<String, String> map;
  InfoMapParser({required this.map, required this.locale});

  String? maybeDetailFromMap(Info infoKey) {
    String key = infoKey.key(locale);
    String? detail = map[key];
    map.remove(key);
    return detail;
  }

  Uri? maybeLinkFromMap(Info infoKey) {
    String? link = maybeDetailFromMap(infoKey);
    if (link == null) {
      return null;
    }
    return Uri.parse(link);
  }

  AgreementInfos? maybeAgreementFromMap() {
    return AgreementInfos.maybeFromMap(
      map: map,
      locale: locale,
    );
  }

  InfoWithLink? maybeInfoWithLinkFromMap(
      {required Info textInfo, required Info urlInfo}) {
    return InfoWithLink.maybeFromMap(
      map: map,
      textInfo: textInfo,
      urlInfo: urlInfo,
      locale: locale,
    );
  }

  List<String>? maybeTagsFromMap() {
    String key = Info.tags.key(locale);
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
