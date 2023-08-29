import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'info_enum.dart';

class InfoWithLink {
  final String? text;
  final Uri? url;
  InfoWithLink({this.text, this.url});

  static InfoWithLink? maybeFromMap(
      {required Map<String, String>? map,
        required Info textInfo,
        required Info urlInfo,
        required AppLocalizations locale}) {
    if (map == null) {
      return null;
    }
    String textKey = textInfo.key(locale);
    String urlKey = urlInfo.key(locale);
    String? text = map[textKey];
    String? urlString = map[urlKey];
    if (text == null && urlString == null) {
      return null;
    }
    Uri? url = (urlString != null) ? Uri.parse(urlString) : null;

    map.remove(textKey);
    map.remove(urlKey);
    return InfoWithLink(text: text, url: url);
  }
}