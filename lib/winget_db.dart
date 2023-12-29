import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/table/table_parser.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

import 'main.dart';
import 'output_handling/output_handler.dart';
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
    print(updates.infos);

    DBTableCreator installedCreator =
        DBTableCreator(wingetLocale, content: 'installed');
    yield* installedCreator.init(Winget.installed);
    installed = installedCreator.returnTable();
    print(installed.infos);

    DBTableCreator availableCreator =
        DBTableCreator(wingetLocale, content: 'available');
    yield* availableCreator.init(Winget.availablePackages);
    available = availableCreator.returnTable();
    print(available.infos);

    isInitialized = true;
    return;
  }
}

class DBTable {
  List<PackageInfosPeek> infos;

  DBTable(this.infos);
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

  DBTable returnTable() {
    return DBTable(extractInfos());
  }
}
