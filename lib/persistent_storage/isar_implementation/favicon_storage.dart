import 'package:isar_key_value/isar_key_value.dart';

import '../persistent_storage.dart';
import 'isar_key_value_sync_storage.dart';

class FaviconStorage extends KeyValueSyncStorage<String, Uri> {
  late final IsarKeyValueSyncStorage<String> _storage;

  FaviconStorage(IsarKeyValue persistent, {required String tableName}) {
    _storage = IsarKeyValueSyncStorage(persistent, tableName: tableName);
  }
  @override
  void addEntry(String key, Uri value) {
    _storage.addEntry(key, value.toString());
  }

  @override
  void deleteAllEntries() {
    _storage.deleteAllEntries();
  }

  @override
  void deleteEntry(String key) {
    _storage.deleteEntry(key);
  }

  @override
  Map<String, Uri> get entries =>
      _storage.entries.map((key, value) => MapEntry(key, Uri.parse(value)));

  @override
  Uri? getEntry(String key) {
    var value = _storage.getEntry(key);
    if (value == null) {
      return null;
    }
    return Uri.parse(value);
  }

  @override
  void saveEntries(Map<String, Uri> entries) {
    _storage.saveEntries(
        entries.map((key, value) => MapEntry(key, value.toString())));
  }

  @override
  String get tableName => _storage.tableName;
}
