/// Storage for a table of entries. Allows CRUD operations.
abstract class TableStorage<T, K> {
  /// Gets all entries from the persistent storage.
  Future<List<T>> loadAllEntries();

  /// Saves the given entries to the persistent storage.
  Future<void> saveEntries(List<T> entries);

  /// Gets a single entry from the persistent storage. Returns null if not found.
  Future<T?> getEntry(K id);

  /// Adds a new entry to the persistent storage.
  Future<void> addEntry(T entry);

  /// Updates an existing entry in the persistent storage.
  Future<void> updateEntry(T newEntry, T oldEntry);

  /// Deletes the given entry from the persistent storage.
  Future<void> deleteEntry(T entry);

  /// Deletes all entries from the persistent storage.
  Future<void> deleteAllEntries();
}