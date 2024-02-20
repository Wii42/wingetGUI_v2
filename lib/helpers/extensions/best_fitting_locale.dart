import 'dart:ui';

extension BestFittingLocale on Locale {
  Locale? bestFittingLocale(List<Locale> availableLocales) {
    if (availableLocales.contains(this)) {
      return this;
    }
    if (availableLocales.length == 1) {
      return availableLocales.single;
    }

    List<Locale> matchingLocales = availableLocales
        .where((element) => element.languageCode == languageCode)
        .toList();
    if (matchingLocales.isNotEmpty) {
      if (matchingLocales.length == 1) {
        return matchingLocales.single;
      } else {
        List<Locale> exactMatchingLocales = matchingLocales
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
}
