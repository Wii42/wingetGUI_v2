import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../helpers/locale_parser.dart';
import 'agreement_infos.dart';
import 'info.dart';
import 'info_with_link.dart';
import 'installer_objects/installer_type.dart';
import 'package_attribute.dart';

class InfoMapParser {
  AppLocalizations locale;
  Map<String, String> map;
  InfoMapParser({required this.map, required this.locale});

  Info<String>? maybeStringFromMap(PackageAttribute attribute) {
    String key = attribute.key(locale);
    String? detail = map[key];
    map.remove(key);
    return (detail != null)
        ? Info<String>(
            title: attribute.title, value: detail, copyable: attribute.copyable)
        : null;
  }

  Info<Uri>? maybeLinkFromMap(PackageAttribute infoKey) {
    Info<String>? link = maybeStringFromMap(infoKey);
    if (link == null) {
      return null;
    }
    return Info<Uri>(title: link.title, value: Uri.parse(link.value));
  }

  Info<List<InfoWithLink>>? maybeListWithLinksFromMap(
      PackageAttribute attribute) {
    Info<String>? list = maybeStringFromMap(attribute);
    if (list == null) {
      return null;
    }
    return Info<List<InfoWithLink>>(
        title: list.title,
        value: list.value
            .split('\n')
            .map((e) => InfoWithLink(title: attribute.title, text: e))
            .toList());
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
    Info<String>? dateInfo = maybeStringFromMap(PackageAttribute.releaseDate);
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

  Info<Locale>? maybeLocaleFromMap(PackageAttribute installerLocale) {
    Info<String>? localeInfo = maybeStringFromMap(installerLocale);
    if (localeInfo == null) {
      return null;
    }
    return Info<Locale>(
        title: localeInfo.title, value: LocaleParser.parse(localeInfo.value));
  }

  Info<InstallerType>? maybeInstallerTypeFromMap(
      PackageAttribute installerType) {
    Info<String>? typeInfo = maybeStringFromMap(installerType);
    if (typeInfo == null) {
      return null;
    }
    return Info<InstallerType>(
        title: typeInfo.title,
        value: InstallerType.maybeParse(typeInfo.value)!);
  }
}
