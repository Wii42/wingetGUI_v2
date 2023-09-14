import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/settings_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsCache settings = SettingsCache.instance;
  settings.setMockSharedPreferences(MockSharedPreferences());
  assert(settings.initialized == true);

  test('wingetLocale', () {
    expect(settings.wingetLocale, null);
    settings.wingetLocale = const Locale('en', 'US');
    expect(settings.wingetLocale, const Locale('en', 'US'));

    settings.wingetLocale = null;
    expect(settings.wingetLocale, null);
  });

  test('themeMOde', () {
    expect(settings.themeMode, null);

    settings.themeMode = ThemeMode.dark;
    expect(settings.themeMode, ThemeMode.dark);

    settings.themeMode = null;
    expect(settings.themeMode, null);
  });
}

class MockSharedPreferences extends Fake implements SharedPreferences {
  Map<String, String> data = {};

  @override
  Future<bool> setString(String key, String value) {
    data[key] = value;
    return Future.value(true);
  }

  @override
  String? getString(String key) {
    return data[key];
  }

  @override
  Future<bool> remove(String key) {
    data.remove(key);
    return Future.value(true);
  }
}
