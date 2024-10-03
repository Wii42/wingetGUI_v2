import 'package:winget_gui/persistent_storage/json_sharedprefs_sqlite_implementation/sqflite_db/package_db.dart';
import 'package:winget_gui/persistent_storage/persistent_storage.dart';

/// Abstraction to wrap DB table with two columns: key and value.
///
/// The key is a String
/// [V] is the type of the value.
class FaviconsStorage<V extends Object> extends KeyValueSyncStorage<String, V> {
  final DBTable<String, V> _table;

  FaviconsStorage(this._table, {this.tableName = 'Favicon'});
  @override
  void addEntry(String key, V value) => _table.insert(key, value);

  @override
  void deleteAllEntries() => _table.deleteAll();

  @override
  void deleteEntry(String key) => _table.delete(key);

  @override
  Map<String, V> get entries => _table.entries;

  @override
  V? getEntry(String key) => _table.getEntry(key);

  @override
  void saveEntries(Map<String, V> entries) => _table.addEntries(entries);

  @override
  String tableName;
}