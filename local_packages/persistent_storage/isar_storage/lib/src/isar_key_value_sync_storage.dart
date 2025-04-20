import 'package:isar/isar.dart';
import 'isar_models/publisher_name_by_package_id.dart';

import 'package:persistent_storage_interface/interface.dart';
import 'isar_models/favicon.dart';
import 'isar_models/model.dart';
import 'isar_models/publisher_name_by_publisher_id.dart';
import 'isar_models/setting.dart';

abstract class IsarKeyValueSyncStorage<T extends Object, M extends Model<T>>
    extends KeyValueSyncStorage<String, T> {
  final IsarCollection<M> _table;
  final Isar _isar;

  Map<String, T> _cache = {};

  IsarKeyValueSyncStorage(this._table, this._isar, {required this.tableName});

  M fromMapEntry(MapEntry<String, T> entry) {
    return createModel(entry.key, entry.value);
  }

  M createModel(String key, T value);

  Future<void> loadCache() async {
    List<M> list = await _isar.txn(() => _table.where().findAll());
    _cache = Map.fromEntries(list.map((e) => e.toMapEntry()));
  }

  @override
  void addEntry(String key, T value) {
    M model = createModel(key, value);
    _isar.writeTxn(() => _table.put(model));
    _cache[key] = value;
  }

  @override
  void deleteAllEntries() {
    _table.clear();
    _cache.clear();
  }

  @override
  void deleteEntry(String key) {
    _table.deleteByIndex(r'key', [key]);
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
    Iterable<M> models = entries.entries.map((e) => fromMapEntry(e));
    _isar.writeTxn(() => _table.putAll(models.toList()));
    _cache.addAll(entries);
  }

  @override
  String tableName;
}

class SettingsStorage extends IsarKeyValueSyncStorage<String, Setting> {
  SettingsStorage(super.table, super.isar, {required super.tableName});

  @override
  Setting createModel(String key, String value) {
    return Setting(key: key, value: value);
  }
}

class FaviconStorage extends IsarKeyValueSyncStorage<Uri, Favicon> {
  FaviconStorage(super.table, super.isar, {required super.tableName});

  @override
  Favicon createModel(String key, Uri value) {
    return Favicon.fromUrl(key: key, uri: value);
  }
}

class PublisherNameByPackageIdStorage
    extends IsarKeyValueSyncStorage<String, PublisherNameByPackageId> {
  PublisherNameByPackageIdStorage(super.table, super.isar,
      {required super.tableName});

  @override
  PublisherNameByPackageId createModel(String key, String value) {
    return PublisherNameByPackageId(key: key, value: value);
  }
}

class PublisherNameByPublisherIdStorage
    extends IsarKeyValueSyncStorage<String, PublisherNameByPublisherId> {
  PublisherNameByPublisherIdStorage(super.table, super.isar,
      {required super.tableName});

  @override
  PublisherNameByPublisherId createModel(String key, String value) {
    return PublisherNameByPublisherId(key: key, value: value);
  }
}
