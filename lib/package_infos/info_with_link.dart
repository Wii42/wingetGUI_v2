import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_extension.dart';
import 'package:winget_gui/helpers/log_stream.dart';

import 'info.dart';
import 'package_attribute.dart';

class InfoWithLink {
  late final Logger log;
  final String Function(AppLocalizations) title;
  final String? text;
  final Uri? url;

  InfoWithLink({required this.title, this.text, this.url}) {
    assert(text != null || url != null);
    log = Logger(this, sourceType: InfoWithLink);
  }

  bool hasText() => text != null;

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

  Info<Uri> toUriInfo() {
    if (url == null) {
      log.warning('Warning in InfoWithLink.toUriInfo(): url is null!');
    }
    return (toUriInfoIfHasUrl()) ?? Info<Uri>(title: title, value: Uri());
  }

  Info<Uri>? toUriInfoIfHasUrl() =>
      (url != null) ? Info<Uri>(title: title, value: url!) : null;

  Info<String> toStringInfo() =>
      Info<String>(title: title, value: text ?? url!.toString());

  Info<String>? toInfoStringIfHasText() =>
      (text != null) ? toStringInfo() : null;

  static InfoWithLink? maybeFromApiMap(
      {required Map<dynamic, dynamic>? map,
      required PackageAttribute textInfo,
      required PackageAttribute urlInfo}) {
    if (map == null) {
      return null;
    }
    return maybeFrom(map, textInfo, textInfo.apiKey!, urlInfo.apiKey!);
  }

  static InfoWithLink? maybeFrom(
      Map map, PackageAttribute textInfo, String textKey, String urlKey) {
    String? text = map[textKey];
    String? urlString = map[urlKey];
    if (urlString != null && urlString.isEmpty) {
      urlString = null;
    }
    if (text == null && urlString == null) {
      return null;
    }
    if (text != null && urlString == null) {
      if (StringHelper.isLink(text)) {
        urlString = text;
        text = null;
      }
    }
    if (text != null) {
      if (StringHelper.isLink(text)) {
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
