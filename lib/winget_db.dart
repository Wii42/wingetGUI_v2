import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/one_line_info/one_line_info_parser.dart';
import 'package:winget_gui/output_handling/table/table_parser.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import 'main.dart';
import 'output_handling/output_handler.dart';
import 'output_handling/package_infos/info.dart';
import 'output_handling/package_infos/package_infos_peek.dart';
import 'output_handling/parsed_output.dart';

class WingetDB extends ChangeNotifier {
  late DBTable updates, installed, available;

  Stream<String> init(BuildContext context) async* {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    WidgetsFlutterBinding.ensureInitialized();

    DBTableCreator installedCreator = DBTableCreator(wingetLocale,
        content: 'installed', winget: Winget.installed);
    yield* installedCreator.init();
    installed = installedCreator.returnTable();

    DBTableCreator updatesCreator = DBTableCreator(wingetLocale,
        content: 'updates', winget: Winget.updates, filter: _filterUpdates);
    yield* updatesCreator.init();
    updates = updatesCreator.returnTable();

    DBTableCreator availableCreator = DBTableCreator(wingetLocale,
        content: 'available', winget: Winget.availablePackages);
    yield* availableCreator.init();
    available = availableCreator.returnTable();

    if (kDebugMode) {
      printPublishersPackageNrs();
    }
    isInitialized = true;
    return;
  }

  void printPublishersPackageNrs() {
    Map<String, List<PackageInfosPeek>> map = {};
    for (PackageInfosPeek package in available.infos) {
      String publisherId = package.probablyPublisherID()!;
      if (map.containsKey(publisherId)) {
        map[publisherId]!.add(package);
      } else {
        map[publisherId] = [package];
      }
    }

    map.entries
        .sorted((a, b) => b.value.length.compareTo(a.value.length))
        .forEach(
      (element) {
        print('${element.key}: ${element.value.length}');
      },
    );
  }

  List<PackageInfosPeek> _filterUpdates(infos) {
    List<PackageInfosPeek> toRemoveFromUpdates = [];
    for (PackageInfosPeek package in infos) {
      String id = package.id!.value;
      if (installed.idMap.containsKey(id)) {
        List<PackageInfosPeek> installedPackages = installed.idMap[id]!;
        List<String?> installedVersions =
            installedPackages.map((e) => e.version?.value).toList();
        if (installedVersions.contains(package.availableVersion?.value) ||
            installedVersions
                .contains("> ${package.availableVersion?.value}")) {
          toRemoveFromUpdates.add(package);
        }
      }
    }
    toRemoveFromUpdates.forEach(infos.remove);
    return infos;
  }
}

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

class DBTableCreator {
  List<String>? raw;
  List<ParsedOutput>? parsed;
  AppLocalizations wingetLocale;
  late List<String> wingetCommand;
  final List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter;

  String content;

  DBTableCreator(this.wingetLocale,
      {this.content = 'output',
      Winget? winget,
      List<String>? command,
      this.filter}) {
    assert(winget != null || command != null,
        'winget or command must be provided');

    if (winget != null) {
      wingetCommand = winget.fullCommand;
    } else {
      wingetCommand = command!;
    }
  }

  Stream<String> init() async* {
    yield "reading output of winget ${wingetCommand.join(' ')}...";
    raw = await getRawOutputC(wingetCommand);

    yield "parsing $content...";
    parsed = await parsedOutputList(raw!, wingetCommand, wingetLocale);
    return;
  }

  Future<List<String>> getRawOutput(Winget wingetCommand) async {
    WingetProcess winget = await WingetProcess.runWinget(wingetCommand);
    return await winget.outputStream.last;
  }

  Future<List<String>> getRawOutputC(List<String> command) async {
    WingetProcess winget = await WingetProcess.runCommand(command);
    return await winget.outputStream.last;
  }

  Future<List<ParsedOutput>> parsedOutputList(List<String> raw,
      List<String> command, AppLocalizations wingetLocale) async {
    OutputHandler handler = OutputHandler(raw, command: command);
    handler.determineResponsibility(wingetLocale);
    List<ParsedOutput> output = await handler.getParsedOutputList(wingetLocale);
    return output;
  }

  List<PackageInfosPeek> extractInfos() {
    if (parsed == null) {
      throw Exception("$content has not been parsed");
    }
    Iterable<ParsedAppTable> appTables = parsed!.whereType<ParsedAppTable>();
    if (appTables.isEmpty) {
      throw Exception("No AppTables found in $content");
    }
    List<PackageInfosPeek> infos = [];
    for (ParsedAppTable table in appTables) {
      infos.addAll(table.packages);
    }
    if (filter != null) {
      infos = filter!(infos);
    }
    return infos;
  }

  List<OneLineInfo> extractHints() {
    if (parsed == null) {
      throw Exception("$content has not been parsed");
    }
    Iterable<ParsedOneLineInfos> appTables =
        parsed!.whereType<ParsedOneLineInfos>();
    List<OneLineInfo> infos = [];
    for (ParsedOneLineInfos table in appTables) {
      infos.addAll(table.infos);
    }

    return infos;
  }

  DBTable returnTable() {
    return DBTable(extractInfos(),
        hints: extractHints(),
        content: content,
        wingetCommand: wingetCommand,
        creatorFilter: filter,
        wingetLocale: wingetLocale);
  }
}
