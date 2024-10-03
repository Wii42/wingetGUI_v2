import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

abstract class IdentifyingProperty {
  String shortTitle([AppLocalizations? locale]);

  String? longTitle([AppLocalizations? locale, LocaleNames? localeNames]);

  bool get fullTitleHasShortAlways;
}

extension Titles on IdentifyingProperty {
  String fullTitle([AppLocalizations? locale, LocaleNames? localeNames]) {
    if (!fullTitleHasShortAlways) {
      return title(locale, localeNames);
    }
    String short = shortTitle(locale);
    String? long = longTitle(locale, localeNames);
    if (long == null) {
      return short;
    } else {
      return '$long ($short)';
    }
  }

  String title([AppLocalizations? locale, LocaleNames? localeNames]) {
    String short = shortTitle(locale);
    String? long = longTitle(locale, localeNames);
    if (long == null) {
      return short;
    } else {
      return long;
    }
  }
}
