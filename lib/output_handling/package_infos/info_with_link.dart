import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/extensions/string_extension.dart';
import 'info.dart';
import 'package_attribute.dart';

class InfoWithLink {
  final String Function(AppLocalizations) title;
  final String? text;
  final Uri? url;
  InfoWithLink({required this.title, this.text, this.url}) {
    assert(text != null || url != null);
  }

  static InfoWithLink? maybeFromMap(
      {required Map<String, String>? map,
      required PackageAttribute textInfo,
      required PackageAttribute urlInfo,
      required AppLocalizations locale}) {
    if (map == null) {
      return null;
    }
    String textKey = textInfo.key(locale);
    String urlKey = urlInfo.key(locale);
    return maybeFrom(map, textInfo, textKey, urlKey);
  }

  static String checkUrlContainsHttp(String url) {
    if (url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('mailto:') ||
        url.startsWith('ms-windows-store://')) {
      return url;
    } else {
      return 'https://$url';
    }
  }

  Info<Uri> toInfoUri() => tryToInfoUri()!;

  Info<Uri>? tryToInfoUri() =>
      (url != null) ? Info<Uri>(title: title, value: url!) : null;

  Info<String> toInfoString() => tryToInfoString()!;
  Info<String>? tryToInfoString() =>
      (text != null) ? Info<String>(title: title, value: text!) : null;

  static InfoWithLink? maybeFromYamlMap(
      {required Map<dynamic, dynamic>? map,
      required PackageAttribute textInfo,
      required PackageAttribute urlInfo}) {
    if (map == null) {
      return null;
    }
    return maybeFrom(map, textInfo, textInfo.yamlKey!, urlInfo.yamlKey!);
  }

  static InfoWithLink? maybeFrom(
      Map map, PackageAttribute textInfo, String textKey, String urlKey) {
    String? text = map[textKey];
    String? urlString = map[urlKey];
    if (text == null && urlString == null) {
      return null;
    }
    if (text != null && urlString == null) {
      if (isLink(text)) {
        urlString = text;
        text = null;
      }
    }
    Uri? url = (urlString != null)
        ? Uri.tryParse(checkUrlContainsHttp(urlString))
        : null;
    map.remove(textKey);
    map.remove(urlKey);
    return InfoWithLink(title: textInfo.title, text: text, url: url);
  }

  @override
  String toString() {
    return 'InfoWithLink{title: $title, text: $text, url: $url}';
  }
}
