/// Bulk storage for Collections.
///
/// Use if no single key-value pair is needed, but all of them.
/// Same for saving and deleting. Save overwrites all old entries in storage.
abstract class BulkStorage<T> {
  /// Loads all entries from the storage.
  Future<T> loadAll();

  /// Saves all entries to the storage. Overwrites all old entries in storage.
  Future<void> saveAll(T collection);

  /// Deletes all entries from the storage.
  Future<void> deleteAll();
}

/// Bulk storage for key-value pairs.
///
/// Use if no single key-value pair is needed, but all of them.
/// Same for saving and deleting. Save overwrites all old entries in storage.
abstract class BulkMapStorage<K, V> implements BulkStorage<Map<K, V>> {
  /// Loads all entries from the storage.
  @override
  Future<Map<K, V>> loadAll();

  /// Saves all entries to the storage. Overwrites all old entries in storage.
  @override
  Future<void> saveAll(Map<K, V> map);

  /// Deletes all entries from the storage.
  @override
  Future<void> deleteAll();
}

abstract class BulkListStorage<T>
    implements BulkStorage<List<T>> {
  /// Loads all entries from the storage.
  @override
  Future<List<T>> loadAll();

  /// Saves all entries to the storage. Overwrites all old entries in storage.
  @override
  Future<void> saveAll(List<T> list);

  /// Deletes all entries from the storage.
  @override
  Future<void> deleteAll();
}

abstract class BulkListSyncStorage<T> {
  /// Loads all entries from the storage.
  List<T> get entries;

  /// Saves all entries to the storage. Overwrites all old entries in storage.
  void saveAll(List<T> list);

  /// Deletes all entries from the storage.
  void deleteAll();
}