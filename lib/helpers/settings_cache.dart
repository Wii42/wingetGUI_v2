import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/locale_parser.dart';

class SettingsCache {
  static const String _guiLocaleKey = 'guiLocale',
      _wingetLocaleKey = 'wingetLocale';
  SharedPreferences? _prefs;
  static final SettingsCache instance = SettingsCache._();
  SettingsCache._();

  Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

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
      _prefs!.remove('themeMode');
      return;
    }
    _prefs!.setString('themeMode', themeMode.toString());
  }

  ThemeMode? get themeMode {
    String? string = _prefs!.getString('themeMode');
    if (string == null) {
      return null;
    }
    return ThemeMode.values.firstWhere((e) => e.toString() == string);
  }

  get initialized => _prefs != null;

  void _setLocale(Locale? locale, String key) {
    if (locale == null) {
      _prefs!.remove(key);
      return;
    }
    _prefs!.setString(key, locale.toLanguageTag());
  }

  Locale? _getLocale(String key) {
    String? string = _prefs!.getString(key);
    if (string == null) {
      return null;
    }
    return LocaleParser.parse(string);
  }

  @visibleForTesting
  void setMockSharedPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }
}
