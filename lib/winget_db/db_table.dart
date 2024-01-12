import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:winget_gui/winget_db/winget_db.dart';

import '../output_handling/one_line_info/one_line_info_parser.dart';
import '../output_handling/package_infos/info.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'db_table_creator.dart';

class DBTable {
  List<PackageInfosPeek> _infos;
  Map<String, List<PackageInfosPeek>>? _idMap;
  List<OneLineInfo> hints;

  final StreamController<int> _streamController = StreamController<
      int>.broadcast();

  final String content;
  final List<String> wingetCommand;
  AppLocalizations wingetLocale;
  final List<PackageInfosPeek> Function(List<PackageInfosPeek>)? creatorFilter;
  WingetDB wingetDB;

  DBTable(this._infos,
      {this.hints = const [],
        required this.content,
        required this.wingetCommand,
        required this.wingetLocale,
        this.creatorFilter,
        required this.wingetDB});

  Map<String, List<PackageInfosPeek>> get idMap {
    if (_idMap == null) {
      _generateIdMap();
    }
    return _idMap!;
  }

  void _generateIdMap() {
    _idMap = {};
    for (PackageInfosPeek info in infos) {
      Info<String>? id = info.id;
      if (id != null) {
        if (_idMap!.containsKey(id.value)) {
          _idMap![id.value]!.add(info);
        } else {
          _idMap![id.value] = [info];
        }
      }
    }
  }

  updateIDMap() {
    if (_idMap != null) {
      _generateIdMap();
    }
  }

  Stream<String> reloadDBTable() async* {
    DBTableCreator creator = DBTableCreator(
      wingetLocale,
      content: content,
      command: wingetCommand,
      filter: creatorFilter,
      wingetDB: wingetDB,
    );
    yield* creator.init();
    try {
      _infos = creator.extractInfos();
      hints = creator.extractHints();

      updateIDMap();
      wingetDB.notify();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  UnmodifiableListView<PackageInfosPeek> get infos =>
      UnmodifiableListView(_infos);

  bool removeInfo(PackageInfosPeek info) {
    bool inList = _infos.remove(info);
    updateIDMap();
    notify();
    wingetDB.notify();
    return inList;
  }

  void addInfo(PackageInfosPeek info) {
    _infos.add(info);
    updateIDMap();
    notify();
    wingetDB.notify();
  }

  void removeAllInfos() {
    _infos.clear();
    updateIDMap();
    notify();
    wingetDB.notify();
  }

  Stream<int> get stream => _streamController.stream;

  void notify() {
    _streamController.add(0);
  }
}
