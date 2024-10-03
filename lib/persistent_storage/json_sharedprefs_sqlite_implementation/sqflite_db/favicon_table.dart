import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package_db.dart';

class FaviconTable extends DBTable<String, Uri> {
  @override
  final String tableName = 'favicon';
  @override
  final String idKey = 'packageId';
  final urlKey = 'url';

  FaviconTable(super.parentDB);

  @override
  void initTable(Database db) {
    db.execute(
      '''CREATE TABLE $tableName(
          $idKey TEXT PRIMARY KEY,
          $urlKey TEXT
          )''',
    );
  }

  @override
  (String, Uri) entryFromMap(Map<String, dynamic> map) {
    return (map[idKey], Uri.parse(map[urlKey]));
  }

  @override
  Map<String, dynamic> entryToMap((String, Uri) entry) {
    return {
      idKey: entry.$1,
      urlKey: entry.$2.toString(),
    };
  }

  @override
  String toJson() {
    return jsonEncode(
        entries.map((key, value) => MapEntry(key, {'icon': value.toString()})));
  }
}
