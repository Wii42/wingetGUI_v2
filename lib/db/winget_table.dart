import 'dart:async';

import 'package:persistent_storage_interface/interface.dart';
import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/winget_client/winget_command.dart';

import '../winget_client/winget_client.dart';
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
  final WingetPackageListCommand? wingetCommand;
  final StreamController<DBMessage> _streamController =
      StreamController<DBMessage>.broadcast();

  WingetTable(
    this.infos, {
    this.hints = const [],
    required this.content,
    required this.wingetCommand,
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

  Stream<LocalizedString> reloadDBTable(WingetClient client) async* {
    if (wingetCommand == null) {
      log.warning("No winget command provided, cannot reload table.");
      return;
    }
    WingetTableLoader creator = WingetTableLoader(
      wingetCommand!,
    );
    yield* creator.init(client);
    await for (PackageListWithHints packageList in creator.packages!) {
      infos = packageList.packages;
      hints = packageList.hints;
      updateIDMap();
      parent?.notifyListeners();
    }
    persistentStorage?.saveAll(infos);
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

  Future<void> reloadFuture(WingetClient client) {
    Completer completer = Completer<void>();
    reloadDBTable(client).listen(
      (LocalizedString event) {
        _streamController.add(DBMessage(DBStatus.loading, message: event));
      },
      onDone: () {
        completer.complete();
        status = DBStatus.ready;
        _streamController.add(DBMessage(DBStatus.ready));
      },
    );
    return completer.future;
  }

  void sendLoadingMessage() {
    _streamController.add(DBMessage(DBStatus.loading));
  }
}
