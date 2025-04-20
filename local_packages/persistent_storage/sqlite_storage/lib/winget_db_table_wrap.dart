import 'package:persistent_storage_interface/interface.dart';
import 'package:winget_core/winget_core.dart';

import 'sqflite_db/winget_db_table.dart';

class WingetDBTableWrap implements BulkListStorage<PackageInfosPeek> {
  final WingetDBTable _table;

  WingetDBTableWrap(this._table);

  @override
  Future<void> deleteAll() {
    _table.deleteAll();
    return Future.value();
  }

  @override
  Future<List<PackageInfosPeek>> loadAll() async {
    Map<Object, PackageInfosPeek> entries = await _table.loadEntriesFromDB();
    return entries.values.toList();
  }

  @override
  Future<void> saveAll(List<PackageInfosPeek> list) {
    Map<(String, VersionOrString, String), PackageInfosPeek> map = {};
    for (PackageInfosPeek info in list) {
      map[(
        info.id?.value.toString() ?? '',
        info.version?.value ?? VersionOrString.stringVersion(''),
        info.name?.value ?? ''
      )] = info;
    }
    _table.setEntries(map);
    return Future.value();
  }
}
