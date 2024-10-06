import 'dart:convert';

import 'package:isar_key_value/isar_key_value.dart';
import 'package:winget_gui/helpers/package_screenshots.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';

import '../persistent_storage.dart';

abstract class IsarBulkListStorage<T> implements BulkListStorage<T> {
  final IsarKeyValue _bulkListStorage;
  final String listName;

  IsarBulkListStorage(this._bulkListStorage, {required this.listName});
  @override
  Future<void> deleteAll() async {
    await _bulkListStorage.remove(listName);
    return;
  }

  @override
  Future<List<T>> loadAll() async {
    String? jsonList = await _bulkListStorage.get<String>(listName);
    if (jsonList == null) {
      return [];
    }
    return (jsonDecode(jsonList) as List).map((e) => fromJson(e)).toList();
  }

  @override
  Future<void> saveAll(List<T> list) {
    String jsonList = jsonEncode(list.map((e) => toJson(e)).toList());
    return _bulkListStorage.set<String>(listName, jsonList);
  }

  Map<String, dynamic> toJson(T value);

  T fromJson(Map<String, dynamic> json);
}

class PackageInfosPeekBulkListStorage
    extends IsarBulkListStorage<PackageInfosPeek> {
  PackageInfosPeekBulkListStorage(super.bulkListStorage,
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

class PackageScreenshotsBulkMapStorage
    extends BulkMapStorage<String, PackageScreenshots> {
  final IsarKeyValue _bulkMapStorage;
  final String mapName;
  PackageScreenshotsBulkMapStorage(this._bulkMapStorage,
      {required this.mapName});

  @override
  Future<void> deleteAll() {
    return _bulkMapStorage.remove(mapName);
  }

  @override
  Future<Map<String, PackageScreenshots>> loadAll() async{
    String? jsonMap = await _bulkMapStorage.get<String>(mapName);
    if (jsonMap == null) {
      return {};
    }
    return (jsonDecode(jsonMap) as Map<String, dynamic>).map((key, value) =>
        MapEntry(key, PackageScreenshots.fromJson(value)));
  }

  @override
  Future<void> saveAll(Map<String, PackageScreenshots> map) {
    String jsonMap = jsonEncode(map.map((key, value) =>
        MapEntry(key, value.toJson())));
    return _bulkMapStorage.set<String>(mapName, jsonMap);
  }
}