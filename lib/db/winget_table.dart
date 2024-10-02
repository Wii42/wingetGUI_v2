import 'dart:async';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/package_infos/info.dart';
import 'package:winget_gui/package_infos/package_id.dart';
import 'package:winget_gui/package_infos/package_infos_peek.dart';
import 'package:winget_gui/persistent_storage/persistent_storage_interface.dart';

import 'db_message.dart';
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
  BulkListStorage<PackageInfosPeek>? persistentStorage;

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
    this.persistentStorage,
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
    persistentStorage?.saveAll(infos);
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
