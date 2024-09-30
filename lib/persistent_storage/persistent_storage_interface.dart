import 'package:winget_gui/helpers/extensions/screenshots_list_loader.dart';
import 'package:winget_gui/helpers/json_publisher.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';

/// Persistent storage service, pure data layer, no business logic.
abstract class PersistentStorage {
  /// Initializes the persistent storage service.
  ///
  /// Must be called before any other method, otherwise they will throw an exception.
  Future<void> initialize();

  /// Whether the storage is initialized. If not, all other methods will throw an exception.
  bool get isInitialized;

  /// Map which maps package id's to another id which is used in the screenshot database.
  Future<Map<String, CustomIconKey>> loadCustomIconKeys();

  /// Loads custom defined package screenshots.
  Future<Map<String, PackageScreenshots>> loadCustomPackageScreenshots();

  /// Loads custom defined publisher icons and display names.
  Future<Map<String, JsonPublisher>> loadCustomPublisherData();

  /// Loads a list of package ids which are banned from the screenshot database,
  /// because their icon url in the database is invalid.
  Future<List<String>> loadBannedIcons();

  /// Stores package screenshots in the persistent storage.
  ///
  /// Faster than repeatedly fetching from Server.
  BulkMapStorage<String, PackageScreenshots> get packageScreenshots;

  /// Stores automatically fetched favicons in the persistent storage.
  KeyValueStorage<String, Uri> get favicon;

  /// Stores automatically fetched publisher icons in the persistent storage.
  /// Key is the package id. Used if no publisher name is available.
  KeyValueStorage<String, String> get publisherNameByPackageId;

  /// Stores automatically fetched publisher icons in the persistent storage.
  /// Key is the publisher id.
  KeyValueStorage<String, String> get publisherNameByPublisherId;

  /// Stores all packages with an update available.
  ///
  /// Used to get the updates before Winget is called.
  BulkListStorage<PackageInfosPeek> get updatePackages;

  /// Stores all installed packages.
  ///
  /// Used to get the installed packages before Winget is called.
  BulkListStorage<PackageInfosPeek> get installedPackages;

  /// Stores all available packages.
  ///
  /// Used to get the available packages before Winget is called.
  BulkListStorage<PackageInfosPeek> get availablePackages;
}

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

abstract class BulkListStorage<T> implements BulkStorage<List<T>> {
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
