import 'package:flutter/foundation.dart';
import 'package:winget_gui/winget_db/winget_db.dart';

import '../output_handling/one_line_info/one_line_info_parser.dart';
import '../output_handling/output_handler.dart';
import '../output_handling/package_infos/package_infos_peek.dart';
import '../output_handling/parsed_output.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/table/table_parser.dart';
import '../winget_commands.dart';
import '../winget_process/winget_process.dart';
import 'db_table.dart';

class DBTableCreator {
  List<String>? raw;
  List<ParsedOutput>? parsed;
  late List<String> wingetCommand;
  final List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter;
  final WingetDB? parentDB;

  String content;

  DBTableCreator({
    this.content = 'output',
    Winget? winget,
    List<String>? command,
    this.filter,
    this.parentDB,
  }) {
    assert(winget != null || command != null,
        'winget or command must be provided');

    if (winget != null) {
      wingetCommand = winget.fullCommand;
    } else {
      wingetCommand = command!;
    }
  }

  Stream<String> init(AppLocalizations wingetLocale) async* {
    yield "reading output of winget ${wingetCommand.join(' ')}...";
    raw = await getRawOutputC(wingetCommand);

    yield "parsing $content...";
    parsed = await parsedOutputList(raw!, wingetCommand, wingetLocale);
    return;
  }

  Future<List<String>> getRawOutput(Winget wingetCommand) async {
    WingetProcess winget = WingetProcess.fromWinget(wingetCommand);
    return await winget.outputStream.last;
  }

  Future<List<String>> getRawOutputC(List<String> command) async {
    WingetProcess winget = WingetProcess.fromCommand(command);
    List<String> output = await winget.outputStream.last;
    if (kDebugMode) {
      //print(output.join('\n'));
    }
    return output;
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
    return extractInfosStatic(parsed!, content, filter: filter);
  }

  List<OneLineInfo> extractHints() {
    if (parsed == null) {
      throw Exception("$content has not been parsed");
    }
    return extractHintsStatic(parsed!, content);
  }

  DBTable returnTable() {
    return DBTable(
      extractInfos(),
      hints: extractHints(),
      content: content,
      wingetCommand: wingetCommand,
      creatorFilter: filter,
      parentDB: parentDB,
    );
  }

  static List<PackageInfosPeek> extractInfosStatic(
      List<ParsedOutput> parsed, String content,
      {List<PackageInfosPeek> Function(List<PackageInfosPeek>)? filter}) {
    Iterable<ParsedAppTable> appTables = parsed.whereType<ParsedAppTable>();
    if (appTables.isEmpty) {
      throw Exception("No AppTables found in $content");
    }
    List<PackageInfosPeek> infos = [];
    for (ParsedAppTable table in appTables) {
      infos.addAll(table.packages);
    }
    if (filter != null) {
      infos = filter(infos);
    }
    return infos;
  }

  static List<OneLineInfo> extractHintsStatic(
      List<ParsedOutput> parsed, String content) {
    Iterable<ParsedOneLineInfos> appTables =
        parsed.whereType<ParsedOneLineInfos>();
    List<OneLineInfo> infos = [];
    for (ParsedOneLineInfos table in appTables) {
      infos.addAll(table.infos);
    }
    return infos;
  }
}
