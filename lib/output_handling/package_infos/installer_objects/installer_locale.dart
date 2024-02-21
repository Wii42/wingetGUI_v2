import 'dart:ui';

import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'identifying_property.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstallerLocale extends Locale
    with LocaleTitleMixin
    implements IdentifyingProperty {
  InstallerLocale(super.languageCode);

  InstallerLocale.fromSubtags({
    required super.languageCode,
    super.countryCode,
    super.scriptCode,
  }) : super.fromSubtags();
}

mixin LocaleTitleMixin on Locale implements IdentifyingProperty {
  @override
  String? longTitle([AppLocalizations? locale, LocaleNames? localeNames]) {
    if (localeNames == null) throw ArgumentError.notNull("localeNames");
    print("${toString()}: ${localeNames.nameOf(toString())}");
    return localeNames.nameOf(toString());
  }

  @override
  String shortTitle([AppLocalizations? locale]) {
    return toLanguageTag();
  }

  @override
  String fullTitle([AppLocalizations? locale, LocaleNames? localeNames]) {
    return title(locale, localeNames);
  }

  @override
  bool get fullTitleHasShortAlways => false;
}
