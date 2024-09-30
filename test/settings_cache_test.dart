import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winget_gui/helpers/settings_cache.dart';
import 'package:winget_gui/persistent_storage/persistent_storage_interface.dart';
import 'package:winget_gui/persistent_storage/persistent_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SettingsCache settings = SettingsCache.instance;
  PersistentStorageService.setImplementation(MockPersistentStorage());
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

class MockSharedPreferences extends Fake
    implements KeyValueSyncStorage<String, String> {
  Map<String, String> data = {};

  @override
  void addEntry(String key, String value) {
    data[key] = value;
    return;
  }

  @override
  String? getEntry(String key) {
    return data[key];
  }

  @override
  void deleteEntry(String key) {
    data.remove(key);
  }
}

class MockPersistentStorage extends Fake implements PersistentStorage {
  @override
  KeyValueSyncStorage<String, String> settings = MockSharedPreferences();

  @override
  bool get isInitialized => true;
}
