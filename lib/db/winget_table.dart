import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/package_infos/info.dart';
import 'package:winget_gui/package_infos/package_attribute.dart';
import 'package:winget_gui/package_infos/package_id.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';

import 'db_message.dart';
import 'package_db.dart';
import 'package_tables.dart';
import 'winget_table_loader.dart';

typedef PackageFilter = List<PackageInfosPeek> Function(List<PackageInfosPeek>);

class WingetTable {
  late final Logger log;
  List<PackageInfosPeek> infos;
  Map<PackageId, List<PackageInfosPeek>>? _idMap;
  List<OneLineInfo> hints;
  PackageTables? parent;
  DBStatus status;
  WingetDBTable? internTable;

  final LocalizedString content;
  final List<String> wingetCommand;
  final PackageFilter? creatorFilter;
  final StreamController<DBMessage> _streamController =
      StreamController<DBMessage>.broadcast();

  WingetTable(
    this.infos, {
    this.hints = const [],
    required this.content,
    required this.wingetCommand,
    this.creatorFilter,
    this.parent,
    this.status = DBStatus.loading,
    this.internTable,
  }) {
    log = Logger(this);
  }

  Map<PackageId, List<PackageInfosPeek>> get idMap {
    if (_idMap == null) {
      _generateIdMap();
    }
    return _idMap!;
  }

  void _generateIdMap() {
    _idMap = {};
    for (PackageInfosPeek info in infos) {
      Info<PackageId>? id = info.id;
      if (id != null) {
        if (_idMap!.containsKey(id.value)) {
          _idMap![id.value]!.add(info);
        } else {
          _idMap![id.value] = [info];
        }
      }
    }
  }

  void updateIDMap() {
    if (_idMap != null) {
      _generateIdMap();
    }
  }

  Stream<LocalizedString> reloadDBTable(AppLocalizations wingetLocale) async* {
    WingetTableLoader creator = WingetTableLoader(
      content: content,
      command: wingetCommand,
      filter: creatorFilter,
    );
    yield* creator.init(wingetLocale);
    infos = creator.extractInfos();
    hints = creator.extractHints();
    updateIDMap();
    internTable?.setList(infos);
    parent?.notifyListeners();
  }

  Stream<DBMessage> get stream => _streamController.stream;

  void notifyListeners() {
    _streamController.add(DBMessage(DBStatus.ready));
  }

  void notifyLoading() {
    _streamController.add(DBMessage(DBStatus.loading));
  }

  void addInfo(PackageInfosPeek info) {
    infos.add(info);
    parent?.notifyListeners();
  }

  void removeInfo(PackageInfosPeek info) {
    infos.remove(info);
    parent?.notifyListeners();
  }

  void removeInfoWhere(bool Function(PackageInfosPeek) test) {
    infos.removeWhere(test);
    parent?.notifyListeners();
  }

  void removeAllInfos() {
    infos.clear();
    parent?.notifyListeners();
  }

  Future<void> reloadFuture(AppLocalizations wingetLocale) {
    Completer completer = Completer<void>();
    reloadDBTable(wingetLocale).listen((LocalizedString event) {
      log.info(event(wingetLocale));
      _streamController.add(DBMessage(DBStatus.loading, message: event));
    }, onDone: () {
      completer.complete();
      status = DBStatus.ready;
      _streamController.add(DBMessage(DBStatus.ready));
    });
    return completer.future;
  }

  void sendLoadingMessage() {
    _streamController.add(DBMessage(DBStatus.loading));
  }
}

class WingetDBTable
    extends DBTable<(String, VersionOrString, String), PackageInfosPeek>
    with PackageTableSetListMixin {
  @override
  final String tableName;
  @override
  final String idKey = PackageAttribute.id.name;
  WingetTable parent;

  WingetDBTable({
    required this.tableName,
    required PackageDB parentDB,
    required this.parent,
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
  ((String, VersionOrString, String), PackageInfosPeek) fromMap(
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
  Map<String, dynamic> toMap(
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
