import 'dart:async';
import 'dart:collection';

import '../main.dart';
import '../output_handling/one_line_info/one_line_info_parser.dart';
import '../output_handling/package_infos/info.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'db_table_creator.dart';

class DBTable {
  List<PackageInfosPeek> _infos;
  Map<String, List<PackageInfosPeek>>? _idMap;
  List<OneLineInfo> hints;

  final String content;
  final List<String> wingetCommand;
  final List<PackageInfosPeek> Function(List<PackageInfosPeek>)? creatorFilter;
  final StreamController<String> _streamController =
      StreamController<String>.broadcast();

  DBTable(this._infos,
      {this.hints = const [],
      required this.content,
      required this.wingetCommand,
      this.creatorFilter});

  Map<String, List<PackageInfosPeek>> get idMap {
    if (_idMap == null) {
      _generateIdMap();
    }
    return _idMap!;
  }

  void _generateIdMap() {
    _idMap = {};
    for (PackageInfosPeek info in _infos) {
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

  Stream<String> reloadDBTable(AppLocalizations wingetLocale) async* {
    DBTableCreator creator = DBTableCreator(
      content: content,
      command: wingetCommand,
      filter: creatorFilter,
    );
    yield* creator.init(wingetLocale);
    _infos = creator.extractInfos();
    hints = creator.extractHints();
    updateIDMap();
    wingetDB.notifyListeners();
  }

  Stream<String> get stream => _streamController.stream;

  void notifyListeners() {
    _streamController.add('');
    //print("notified listeners of $content");
  }

  void notifyLoading() {
    _streamController.add('loading');
    //print("loading $content");
  }

  UnmodifiableListView<PackageInfosPeek> get infos =>
      UnmodifiableListView(_infos);

  void addInfo(PackageInfosPeek info) {
    _infos.add(info);
    wingetDB.notifyListeners();
  }

  void removeInfo(PackageInfosPeek info) {
    _infos.remove(info);
    wingetDB.notifyListeners();
  }

  void removeInfoWhere(bool Function(PackageInfosPeek) test) {
    _infos.removeWhere(test);
    wingetDB.notifyListeners();
  }

  void removeAllInfos() {
    _infos.clear();
    wingetDB.notifyListeners();
  }

  Future<void> reloadFuture(AppLocalizations wingetLocale) {
    Completer completer = Completer<void>();
    reloadDBTable(wingetLocale).listen((event) {
      print(event);
    }, onDone: () {
      completer.complete();
    });
    return completer.future;
  }
}
