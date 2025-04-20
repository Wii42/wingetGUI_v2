import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:winget_core/winget_core.dart';

class LocalizedName extends LocalizationName {
  final LocaleNames names;

  LocalizedName(this.names);

  @override
  nameOf(languageTag) {
    names.nameOf(languageTag);
  }
}

extension LocaleNamesAsLocalizedName on LocaleNames {
  LocalizedName get asLocalizedName => LocalizedName(this);
}
