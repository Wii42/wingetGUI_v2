import 'package:shared_preferences/shared_preferences.dart';
import 'package:winget_gui/helpers/log_stream.dart';

import '../persistent_storage.dart';

class SettingsStorage extends KeyValueSyncStorage<String, String> {
  Logger log = Logger(null, sourceType: SettingsStorage);
  SharedPreferences prefs;
  String keyPrefix;
  List<String> keys = [];

  SettingsStorage(this.prefs, this.keyPrefix, {this.tableName = 'Settings'});

  @override
  void addEntry(String key, value) {
    prefs.setString(_prefKey(key), value);
    keys.add(key);
  }

  @override
  void deleteAllEntries() {
    for (String key in keys) {
      prefs.remove(_prefKey(key));
    }
    keys.clear();
  }

  @override
  void deleteEntry(String key) {
    prefs.remove(_prefKey(key));
    keys.remove(key);
  }

  @override
  String? getEntry(String key) {
    return prefs.getString(_prefKey(key));
  }

  String _prefKey(String key) => '$keyPrefix:$key';

  @override
  Map<String, String> get entries {
    Map<String, String> map = {};
    for (String key in keys) {
      map[key] = prefs.getString(_prefKey(key))!;
    }
    return map;
  }

  @override
  void saveEntries(Map<String, String> entries) {
    for (MapEntry<String, String> entry in entries.entries) {
      prefs.setString(_prefKey(entry.key), entry.value);
      keys.add(entry.key);
    }
  }

  @override
  String tableName;
}