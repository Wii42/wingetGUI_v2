import 'dart:ui';

import 'package:intl/locale.dart' as intl;

class LocaleParser {
  static Locale? tryParse(final String rawLocale) {
    final intlLocale = intl.Locale.tryParse(rawLocale);
    if (intlLocale != null) {
      return Locale.fromSubtags(
          languageCode: intlLocale.languageCode,
          countryCode: intlLocale.countryCode,
          scriptCode: intlLocale.scriptCode);
    }
    return null;
  }

  static Locale parse(String rawLocale) {
    Locale? locale = tryParse(rawLocale);
    if (locale == null) {
      throw ArgumentError.value(rawLocale, 'rawLocale', 'Invalid locale');
    }
    return locale;
  }
}
