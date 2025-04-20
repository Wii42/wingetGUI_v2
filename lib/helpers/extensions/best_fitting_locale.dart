import 'package:intl/locale.dart' as intl;
import 'dart:ui' as ui;

extension BestFittingLocale on intl.Locale {
  intl.Locale? bestFittingLocale(List<intl.Locale> availableLocales) {
    if (availableLocales.contains(this)) {
      return this;
    }
    if (availableLocales.length == 1) {
      return availableLocales.single;
    }

    List<intl.Locale> matchingLocales = availableLocales
        .where((element) => element.languageCode == languageCode)
        .toList();
    if (matchingLocales.isNotEmpty) {
      if (matchingLocales.length == 1) {
        return matchingLocales.single;
      } else {
        List<intl.Locale> exactMatchingLocales = matchingLocales
            .where((element) => element.toLanguageTag() == toLanguageTag())
            .toList();
        if (exactMatchingLocales.isNotEmpty) {
          return exactMatchingLocales.first;
        }
        return matchingLocales.first;
      }
    }
    return null;
  }

  ui.Locale get asUiLocale {
    return ui.Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }
}

extension UiLocaleAsIntlLocale on ui.Locale {
  intl.Locale get asIntlLocale {
    return intl.Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }
}
