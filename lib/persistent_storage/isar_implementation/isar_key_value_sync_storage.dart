import 'package:isar_key_value/isar_key_value.dart';

import '../persistent_storage.dart';

class IsarKeyValueSyncStorage<T> extends KeyValueSyncStorage<String, T>{
  final IsarKeyValue _storage;

  Map<String,T> _cache = {};

  IsarKeyValueSyncStorage(this._storage, {required this.tableName});

  Future<void> loadCache() async {
    _cache = await _storage.getAll<T>();
  }

  @override
  void addEntry(String key, T value) {
    _storage.set(key, value);
    _cache[key] = value;
  }

  @override
  void deleteAllEntries() {
    _storage.clear();
    _cache.clear();
  }

  @override
  void deleteEntry(String key) {
    _storage.remove(key);
    _cache.remove(key);
  }

  @override
  Map<String, T> get entries => Map.unmodifiable(_cache);

  @override
  T? getEntry(String key) {
    return _cache[key];
  }

  @override
  void saveEntries(Map<String, T> entries) {
    for (var entry in entries.entries) {
      _storage.set<T>(entry.key, entry.value);
      _cache[entry.key] = entry.value;
    }
  }

  @override
  String tableName;

}