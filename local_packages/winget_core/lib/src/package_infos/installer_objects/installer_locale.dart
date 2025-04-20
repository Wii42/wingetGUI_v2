import 'package:intl/locale.dart';
import 'package:winget_core/src/localization_name.dart';
import 'package:winget_core/src/package_localizer.dart';

import 'identifying_property.dart';

class InstallerLocale extends Locale
    with LocaleTitleMixin
    implements IdentifyingProperty {
  @override
  String? countryCode;

  @override
  String languageCode;

  @override
  String? scriptCode;

  InstallerLocale({
    required this.languageCode,
    this.scriptCode,
    this.countryCode,
  });

  static final InstallerLocale matchAll =
      InstallerLocale(languageCode: '<match all>');

  @override
  String toLanguageTag() {
    return Locale.fromSubtags(
            languageCode: languageCode,
            scriptCode: scriptCode,
            countryCode: countryCode)
        .toLanguageTag();
  }

  @override
  Iterable<String> get variants => [];

  static InstallerLocale? tryParse(final String rawLocale) {
    final intlLocale = Locale.tryParse(rawLocale);
    if (intlLocale != null) {
      return InstallerLocale(
          languageCode: intlLocale.languageCode,
          countryCode: intlLocale.countryCode,
          scriptCode: intlLocale.scriptCode);
    }
    return null;
  }

  static InstallerLocale parse(String rawLocale) {
    InstallerLocale? locale = tryParse(rawLocale);
    if (locale == null) {
      throw ArgumentError.value(rawLocale, 'rawLocale', 'Invalid locale');
    }
    return locale;
  }
}

mixin LocaleTitleMixin on Locale implements IdentifyingProperty {
  @override
  String? longTitle([PackageLocalizer? locale, LocalizationName? localeNames]) {
    if (localeNames == null) throw ArgumentError.notNull("localeNames");
    return localeNames.nameOf(toString());
  }

  @override
  String shortTitle([PackageLocalizer? locale]) {
    return toLanguageTag();
  }

  @override
  bool get fullTitleHasShortAlways => false;
}
