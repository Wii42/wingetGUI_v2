import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/persistent_storage/persistent_storage.dart';

import 'locale_parser.dart';

class SettingsCache {
  static const String _guiLocaleKey = 'guiLocale',
      _wingetLocaleKey = 'wingetLocale';

  KeyValueSyncStorage<String, String> get _settingsStorage =>
      PersistentStorageService.instance.settings;
  static final SettingsCache instance = SettingsCache._();

  SettingsCache._();

  set guiLocale(Locale? guiLocale) {
    _setLocale(guiLocale, _guiLocaleKey);
  }

  Locale? get guiLocale {
    return _getLocale(_guiLocaleKey);
  }

  set wingetLocale(Locale? wingetLocale) {
    _setLocale(wingetLocale, _wingetLocaleKey);
  }

  Locale? get wingetLocale {
    return _getLocale(_wingetLocaleKey);
  }

  set themeMode(ThemeMode? themeMode) {
    if (themeMode == null) {
      _settingsStorage.deleteEntry('themeMode');
      return;
    }
    _settingsStorage.addEntry('themeMode', themeMode.toString());
  }

  ThemeMode? get themeMode {
    String? string = _settingsStorage.getEntry('themeMode');
    if (string == null) {
      return null;
    }
    return ThemeMode.values.firstWhere((e) => e.toString() == string);
  }

  get initialized => PersistentStorageService.instance.isInitialized;

  void _setLocale(Locale? locale, String key) {
    if (locale == null) {
      _settingsStorage.deleteEntry(key);
      return;
    }
    _settingsStorage.addEntry(key, locale.toLanguageTag());
  }

  Locale? _getLocale(String key) {
    String? string = _settingsStorage.getEntry(key);
    if (string == null) {
      return null;
    }
    return LocaleParser.parse(string);
  }
}
