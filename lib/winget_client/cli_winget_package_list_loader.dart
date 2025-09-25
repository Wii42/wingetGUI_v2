import 'package:winget_core/winget_core.dart';
import 'package:winget_gui/helpers/log_stream.dart';
import 'package:winget_gui/l10n/generated/app_localizations.dart';
import 'package:winget_gui/output_handling/one_line_info_parser.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';
import 'package:winget_gui/output_handling/table_parser.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';

class CliWingetPackageListLoader {
  late final Logger log;
  static final Logger staticLog = Logger(
    null,
    sourceType: CliWingetPackageListLoader,
  );
  List<String>? raw;
  List<ParsedOutput>? parsed;
  late List<String> wingetCommand;

  CliWingetPackageListLoader({Winget? winget, List<String>? command, WingetProcess? process}) {
    log = Logger(this);
    assert(
      winget != null || command != null || process != null,
      'winget or command or process must be provided',
    );

    if (winget != null) {
      wingetCommand = winget.fullCommand;
    } else if (process != null) {
      wingetCommand = process.command;
    } else {
      wingetCommand = command!;
    }
  }

  static String defaultContent(AppLocalizations locale) => locale.output;

  Future<void> runWingetProcess(AppLocalizations wingetLocale) async {
    raw = await getRawOutputC(wingetCommand);

    parsed = await parsedOutputList(raw!, wingetCommand, wingetLocale);
    return;
  }

  Future<List<String>> getRawOutput(Winget wingetCommand) async {
    WingetProcess p  = WingetProcess.fromWinget(wingetCommand);
    return await p.outputStream.last;
  }

  Future<List<String>> getRawOutputFromProcess(WingetProcess p) async {
    return await p.outputStream.last;
  }

  Future<List<String>> getRawOutputC(List<String> command) async {
    WingetProcess winget = WingetProcess.fromCommand(command);
    List<String> output = await winget.outputStream.last;
    log.info("raw output of ${command.join(' ')}", message: output.join('\n'));
    return output;
  }

  Future<List<ParsedOutput>> parsedOutputList(
    List<String> raw,
    List<String> command,
    AppLocalizations wingetLocale,
  ) async {
    OutputHandler handler = OutputHandler(raw, command: command);
    handler.determineResponsibility(wingetLocale);
    List<ParsedOutput> output = await handler.getParsedOutputList(wingetLocale);
    return output;
  }

  List<PackageInfosPeek> extractInfos() {
    if (parsed == null) {
      throw Exception("Output of $wingetCommand has not been parsed");
    }
    return extractInfosStatic(parsed!, telemetryName: wingetCommand.join(' '));
  }

  List<OneLineInfo> extractHints() {
    if (parsed == null) {
      throw Exception("Output of $wingetCommand has not been parsed");
    }
    return extractHintsStatic(parsed!);
  }

  static List<PackageInfosPeek> extractInfosStatic(
    List<ParsedOutput> parsed, {
    String? telemetryName,
  }) {
    Iterable<ParsedAppTable> appTables = parsed.whereType<ParsedAppTable>();
    if (appTables.isEmpty) {
      staticLog.error("No AppTables found in $telemetryName, $parsed");
      return [];
    }
    List<PackageInfosPeek> infos = [];
    for (ParsedAppTable table in appTables) {
      infos.addAll(table.packages);
    }
    return infos;
  }

  static List<OneLineInfo> extractHintsStatic(List<ParsedOutput> parsed) {
    Iterable<ParsedOneLineInfos> appTables =
        parsed.whereType<ParsedOneLineInfos>();
    List<OneLineInfo> infos = [];
    for (ParsedOneLineInfos table in appTables) {
      infos.addAll(table.infos);
    }
    return infos;
  }
}
