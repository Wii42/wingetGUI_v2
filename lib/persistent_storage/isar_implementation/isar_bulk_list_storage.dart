import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:isar_key_value/isar_key_value.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';

import '../persistent_storage.dart';
import 'isar_models/bulk_storage.dart';

/// A persistent storage implementation that uses Isar database.
///
/// [C] is the collection type that is stored in the database.
/// [T] is the type of the elements in the collection.
abstract class IsarBulkStorageI<C, T> implements BulkStorage<C> {
  final IsarCollection<IsarBulkStorage> _bulkListStorage;
  final Isar _isar;
  final String listName;

  IsarBulkStorageI(this._bulkListStorage, this._isar, {required this.listName});

  @override
  Future<void> deleteAll() async {
    await _isar
        .writeTxn(() => _bulkListStorage.deleteByIndex(r'key', [listName]));
    return;
  }

  @override
  Future<C> loadAll() async {
    IsarBulkStorage? model =
        await _isar.txn(() => _bulkListStorage.getByIndex(r'key', [listName]));
    String? jsonList = model?.value;
    return collectionFromString(jsonList);
  }

  @override
  Future<void> saveAll(C collection) {
    String jsonList = stringFromCollection(collection);
    return _isar.writeTxn(() =>
        _bulkListStorage.put(IsarBulkStorage(key: listName, value: jsonList)));
  }

  Map<String, dynamic> toJson(T value);

  T fromJson(Map<String, dynamic> json);

  C collectionFromString(String? jsonList);
  String stringFromCollection(C collection);
}

abstract class IsarBulkListStorage<T> extends IsarBulkStorageI<List<T>, T>
    implements BulkListStorage<T> {
  IsarBulkListStorage(super._bulkListStorage, super._isar,
      {required super.listName});

  @override
  List<T> collectionFromString(String? jsonList) {
    if (jsonList == null) {
      return [];
    }
    List<dynamic> jsonListDecoded = jsonDecode(jsonList);
    return jsonListDecoded.map((e) => fromJson(e)).toList();
  }

  @override
  String stringFromCollection(List<T> collection) {
    return jsonEncode(collection.map((e) => toJson(e)).toList());
  }
}

class PackageInfosPeekBulkListStorage
    extends IsarBulkListStorage<PackageInfosPeek> {
  PackageInfosPeekBulkListStorage(super.bulkListStorage, super.isar,
      {required super.listName});

  @override
  Map<String, dynamic> toJson(PackageInfosPeek value) {
    PackageInfosPeek info = value;
    return {
      PackageAttribute.id.name: info.id?.value.toString() ?? '',
      PackageAttribute.name.name: info.name?.value,
      PackageAttribute.version.name: info.version?.value.stringValue,
      PackageAttribute.availableVersion.name:
          info.availableVersion?.value.stringValue,
      PackageAttribute.source.name: info.source.value.key,
      PackageAttribute.match.name: info.match?.value,
    };
  }

  @override
  PackageInfosPeek fromJson(Map<String, dynamic> json) {
    Map<String, String> tempMap =
        json.map((key, value) => MapEntry(key, value.toString()));
    return PackageInfosPeek.fromDBMap(tempMap)..setImplicitInfos();
  }
}

abstract class IsarBulkMapStorage<V> extends IsarBulkStorageI<Map<String, V>, V>
    implements BulkMapStorage<String, V> {
  IsarBulkMapStorage(super._bulkListStorage, super._isar,
      {required super.listName});

  @override
  Map<String, V> collectionFromString(String? jsonList) {
    if (jsonList == null) {
      return {};
    }
    Map<String, dynamic> jsonListDecoded = jsonDecode(jsonList);
    return jsonListDecoded.map((key, value) => MapEntry(key, fromJson(value)));
  }

  @override
  String stringFromCollection(Map<String, V> collection) {
    return jsonEncode(
        collection.map((key, value) => MapEntry(key, toJson(value))));
  }
}

class PackageScreenshotsBulkMapStorage
    extends IsarBulkMapStorage<PackageScreenshots> {
  PackageScreenshotsBulkMapStorage(super.bulkListStorage, super.isar,
      {required super.listName});

  @override
  PackageScreenshots fromJson(Map<String, dynamic> json) {
    return PackageScreenshots.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(PackageScreenshots value) {
    return value.toJson();
  }
}
