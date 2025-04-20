import 'package:winget_core/src/package_localizer.dart';

import '../../localization_name.dart';

abstract class IdentifyingProperty {
  String shortTitle([PackageLocalizer? locale]);

  String? longTitle([PackageLocalizer? locale, LocalizationName? localeNames]);

  bool get fullTitleHasShortAlways;
}

extension Titles on IdentifyingProperty {
  String fullTitle([PackageLocalizer? locale, LocalizationName? localeNames]) {
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

  String title([PackageLocalizer? locale, LocalizationName? localeNames]) {
    String short = shortTitle(locale);
    String? long = longTitle(locale, localeNames);
    if (long == null) {
      return short;
    } else {
      return long;
    }
  }
}
