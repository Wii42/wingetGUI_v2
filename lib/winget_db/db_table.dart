import '../output_handling/one_line_info/one_line_info_parser.dart';
import '../output_handling/package_infos/info.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'db_table_creator.dart';

class DBTable {
  List<PackageInfosPeek> infos;
  Map<String, List<PackageInfosPeek>>? _idMap;
  List<OneLineInfo> hints;

  final String content;
  final List<String> wingetCommand;
  AppLocalizations wingetLocale;
  final List<PackageInfosPeek> Function(List<PackageInfosPeek>)? creatorFilter;

  DBTable(this.infos,
      {this.hints = const [],
        required this.content,
        required this.wingetCommand,
        required this.wingetLocale,
        this.creatorFilter});

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
    );
    yield* creator.init();
    infos = creator.extractInfos();
    hints = creator.extractHints();
  }
}