import 'dart:convert';

abstract class KeyValueStorage<K, V> {
  /// Gets all key-value pairs from the persistent storage.
  Future<Map<K, V>> loadAllPairs();

  /// Saves the given work entries to the persistent storage.
  Future<void> saveEntries(Map<K, V> entries);

  /// Gets a single entry from the persistent storage. Returns null if not found.
  Future<V?> getEntry(K key);

  /// Adds a new work entry to the persistent storage.
  Future<void> addEntry(K key, V value);

  /// Deletes the given work entry from the persistent storage.
  Future<void> deleteEntry(K key);

  /// Deletes all work entries from the persistent storage.
  Future<void> deleteAllEntries();
}

/// Storage for key-value pairs. Allows CRUD operations.
/// Same as [KeyValueStorage], but without async.
abstract class KeyValueSyncStorage<K, V> implements TableRepresentation<K, V> {
  /// Get all key-value pairs from the persistent storage.
  ///
  /// Changes to the returned map will not be saved to the storage.
  @override
  Map<K, V> get entries;

  /// Saves the given work entries to the persistent storage.
  void saveEntries(Map<K, V> entries);

  /// Gets a single entry from the persistent storage. Returns null if not found.
  V? getEntry(K key);

  /// Adds a new work entry to the persistent storage.
  void addEntry(K key, V value);

  /// Deletes the given work entry from the persistent storage.
  void deleteEntry(K key);

  /// Deletes all work entries from the persistent storage.
  @override
  void deleteAllEntries();

  operator []=(K key, V value) => addEntry(key, value);
  operator [](K key) => getEntry(key);

  @override
  Map<String, dynamic> entryToMap((K, V) entry) {
    return {'key': entry.$1, 'value': entry.$2};
  }

  @override
  String toJsonString() {
    return jsonEncode(entries);
  }
}

abstract class TableRepresentation<K, V> {
  String get tableName;

  Map<K, V> get entries;

  void deleteAllEntries();

  String toJsonString();

  Map<String, dynamic> entryToMap((K, V) entry);
}