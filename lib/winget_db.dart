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

class WingetDB {
  late DBTable updates, installed, available;

  Stream<String> init(BuildContext context) async* {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    WidgetsFlutterBinding.ensureInitialized();
    DBTableCreator updatesCreator =
        DBTableCreator(wingetLocale, content: 'updates');
    yield* updatesCreator.init(Winget.updates);
    updates = updatesCreator.returnTable();
    if (kDebugMode) {
      //print(updates.infos);
    }

    DBTableCreator installedCreator =
        DBTableCreator(wingetLocale, content: 'installed');
    yield* installedCreator.init(Winget.installed);
    installed = installedCreator.returnTable();
    if (kDebugMode) {
      //print(installed.infos);
    }

    DBTableCreator availableCreator =
        DBTableCreator(wingetLocale, content: 'available');
    yield* availableCreator.init(Winget.availablePackages);
    available = availableCreator.returnTable();
    if (kDebugMode) {
      //print(available.infos);
    }

    Map<String, List<PackageInfosPeek>> map = {};
    for (PackageInfosPeek package in available.infos) {
      String publisherId = package.probablyPublisherID()!;
      if (map.containsKey(publisherId)) {
        map[publisherId]!.add(package);
      } else {
        map[publisherId] = [package];
      }
    }
    //map.forEach((key, value) {print('$key: ${value.length}');});

    map.entries
        .sorted((a, b) => b.value.length.compareTo(a.value.length))
        .forEach((element) {
      print('${element.key}: ${element.value.length}');
    });

    List<PackageInfosPeek> toRemoveFromUpdates = [];
    for (PackageInfosPeek package in updates.infos) {
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
    toRemoveFromUpdates.forEach(updates.infos.remove);

    updates.updateIDMap();

    isInitialized = true;
    return;
  }
}

class DBTable {
  List<PackageInfosPeek> infos;
  Map<String, List<PackageInfosPeek>>? _idMap;
  List<OneLineInfo> hints;

  DBTable(this.infos, {this.hints = const []});

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
}

class DBTableCreator {
  List<String>? raw;
  List<ParsedOutput>? parsed;
  AppLocalizations wingetLocale;

  String content;

  DBTableCreator(this.wingetLocale, {this.content = 'output'});

  Stream<String> init(Winget wingetCommand) async* {
    yield "reading output of winget ${wingetCommand.baseCommand}...";
    raw = await getRawOutput(wingetCommand);

    yield "parsing $content...";
    parsed =
        await parsedOutputList(raw!, wingetCommand.fullCommand, wingetLocale);
    return;
  }

  Stream<String> initCommand(List<String> command) async* {
    yield "reading output of winget ${command.join(' ')}...";
    raw = await getRawOutputC(command);

    yield "parsing $content...";
    parsed = await parsedOutputList(raw!, command, wingetLocale);
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
    return DBTable(extractInfos(), hints: extractHints());
  }
}
