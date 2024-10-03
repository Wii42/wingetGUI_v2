import 'package:sqflite/sqflite.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/json_sharedprefs_sqlite_implementation/sqflite_db/package_db.dart';

class WingetDBTable
    extends DBTable<(String, VersionOrString, String), PackageInfosPeek>
    with PackageTableSetListMixin {
  @override
  final String tableName;
  @override
  final String idKey = PackageAttribute.id.name;

  WingetDBTable({
    required this.tableName,
    required PackageDB parentDB,
  }) : super(parentDB);

  @override
  initTable(Database db) {
    db.execute(
      '''CREATE TABLE $tableName(
          $idKey TEXT,
          ${PackageAttribute.name.name} TEXT,
          ${PackageAttribute.version.name} TEXT,
          ${PackageAttribute.availableVersion.name} TEXT,
          ${PackageAttribute.source.name} TEXT,
          ${PackageAttribute.match.name} TEXT,
          CONSTRAINT PK_Info PRIMARY KEY ($idKey,${PackageAttribute.version.name}, ${PackageAttribute.name.name})
          )''',
    );
  }

  @override
  ((String, VersionOrString, String), PackageInfosPeek) entryFromMap(
      Map<String, dynamic> map) {
    Map<String, String> tempMap =
        map.map((key, value) => MapEntry(key, value.toString()));
    PackageInfosPeek info = PackageInfosPeek.fromDBMap(tempMap);
    return (
      (info.id!.value.string, info.version!.value, info.name!.value),
      info..setImplicitInfos()
    );
  }

  @override
  Map<String, dynamic> entryToMap(
      ((String, VersionOrString, String), PackageInfosPeek) entry) {
    (String, VersionOrString, String) primaryKey = entry.$1;
    String id = primaryKey.$1;
    VersionOrString version = primaryKey.$2;
    PackageInfosPeek info = entry.$2;
    return {
      idKey: id,
      PackageAttribute.name.name: info.name?.value,
      PackageAttribute.version.name: version.stringValue,
      PackageAttribute.availableVersion.name:
          info.availableVersion?.value.stringValue,
      PackageAttribute.source.name: info.source.value.key,
      PackageAttribute.match.name: info.match?.value,
    };
  }
}
