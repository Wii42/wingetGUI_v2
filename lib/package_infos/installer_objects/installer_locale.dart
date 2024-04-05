import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'identifying_property.dart';

class InstallerLocale extends Locale
    with LocaleTitleMixin
    implements IdentifyingProperty {
  InstallerLocale(super.languageCode);

  InstallerLocale.fromSubtags({
    required super.languageCode,
    super.countryCode,
    super.scriptCode,
  }) : super.fromSubtags();

  static final InstallerLocale matchAll = InstallerLocale('<match all>');
}

mixin LocaleTitleMixin on Locale implements IdentifyingProperty {
  @override
  String? longTitle([AppLocalizations? locale, LocaleNames? localeNames]) {
    if (localeNames == null) throw ArgumentError.notNull("localeNames");
    return localeNames.nameOf(toString());
  }

  @override
  String shortTitle([AppLocalizations? locale]) {
    return toLanguageTag();
  }

  @override
  bool get fullTitleHasShortAlways => false;
}
