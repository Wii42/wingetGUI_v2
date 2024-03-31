import 'dart:async';
import 'package:winget_gui/helpers/version_or_string.dart';
import 'package:winget_gui/output_handling/package_infos/package_attribute.dart';
import 'package:winget_gui/winget_db/db_message.dart';
import 'package:winget_gui/winget_db/winget_db.dart';

import '../helpers/log_stream.dart';
import '../output_handling/one_line_info/one_line_info_parser.dart';
import '../output_handling/package_infos/info.dart';
import '../output_handling/package_infos/package_id.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widget_assets/favicon_db.dart';
import 'db_table_creator.dart';

typedef PackageFilter = List<PackageInfosPeek> Function(List<PackageInfosPeek>);

class WingetDBTable extends DBTable<(String, VersionOrString), PackageInfosPeek>
    with PackageTableMixin {
  late final Logger log;
  List<PackageInfosPeek> infos;
  Map<PackageId, List<PackageInfosPeek>>? _idMap;
  List<OneLineInfo> hints;
  PackageTables? parent;
  DBStatus status;
  @override
  final String tableName;
  @override
  final String idKey = PackageAttribute.id.name;

  final LocalizedString content;
  final List<String> wingetCommand;
  final PackageFilter? creatorFilter;
  final StreamController<DBMessage> _streamController =
      StreamController<DBMessage>.broadcast();

  WingetDBTable(
    this.infos, {
    this.hints = const [],
    required this.content,
    required this.wingetCommand,
    this.creatorFilter,
    this.parent,
    this.status = DBStatus.loading,
    required this.tableName,
    required FaviconDB parentDB,
  }) : super(parentDB) {
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
    DBTableCreator creator = DBTableCreator(
      content: content,
      command: wingetCommand,
      filter: creatorFilter,
    );
    yield* creator.init(wingetLocale);
    infos = creator.extractInfos();
    hints = creator.extractHints();
    updateIDMap();
    setList(infos);
    parent?.notifyListeners();
  }

  Stream<DBMessage> get stream => _streamController.stream;

  void notifyListeners() {
    _streamController.add(DBMessage(DBStatus.ready));
  }

  void notifyLoading() {
    _streamController.add(DBMessage(DBStatus.loading));
  }

  //UnmodifiableListView<PackageInfosPeek> get infos =>
  //    UnmodifiableListView(infos);

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
