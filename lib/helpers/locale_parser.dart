import 'package:intl/locale.dart' as intl;
import 'package:winget_gui/output_handling/package_infos/installer_objects/installer_locale.dart';

class LocaleParser {
  static InstallerLocale? tryParse(final String rawLocale) {
    final intlLocale = intl.Locale.tryParse(rawLocale);
    if (intlLocale != null) {
      return InstallerLocale.fromSubtags(
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
