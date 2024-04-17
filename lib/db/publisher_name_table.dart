import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package_db.dart';

class PublisherNameTable extends DBTable<String, String> {
  @override
  final String tableName;
  @override
  final String idKey;
  final publisherNameKey = 'publisherName';

  PublisherNameTable(
      {required this.tableName,
        required this.idKey,
        required PackageDB parentDB})
      : super(parentDB);

  @override
  void initTable(Database db) {
    db.execute(
      '''CREATE TABLE $tableName(
          $idKey TEXT PRIMARY KEY,
          $publisherNameKey TEXT
          )''',
    );
  }

  @override
  (String, String) entryFromMap(Map<String, dynamic> map) {
    return (map[idKey], map[publisherNameKey]);
  }

  @override
  Map<String, dynamic> entryToMap((String, String) entry) {
    return {
      idKey: entry.$1,
      publisherNameKey: entry.$2,
    };
  }

  @override
  String toJson() {
    return jsonEncode(
        entries.map((key, value) => MapEntry(key, {'publisher_name': value.toString()})));
  }
}