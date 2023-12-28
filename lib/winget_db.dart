import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_commands.dart';
import 'package:winget_gui/winget_process/winget_process.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'main.dart';
import 'output_handling/output_handler.dart';
import 'output_handling/parsed_output.dart';

Stream<String> wingetDB(BuildContext context) async* {
  yield "Big Bang";
  AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
  yield "reading output of winget upgrade...";
  List<String> rawUpdates = await getRawOutput(Winget.updates);
  yield "parsing updates...";
  List<ParsedOutput> parsedUpdates =
      await parsedOutputList(rawUpdates, Winget.updates.fullCommand, wingetLocale);

  yield "reading output of winget install...";
  List<String> rawInstalled = await getRawOutput(Winget.updates);
  yield "parsing installed...";
  List<ParsedOutput> parsedInstalled =
  await parsedOutputList(rawInstalled, Winget.installed.fullCommand, wingetLocale);

  isInitialized = true;
  return;
}

Future<List<String>> getRawOutput(Winget wingetCommand) async {
  WingetProcess winget = await WingetProcess.runWinget(wingetCommand);
  return await winget.outputStream.last;
}

Future<List<ParsedOutput>> parsedOutputList(List<String> raw,
    List<String> command, AppLocalizations wingetLocale) async {
  OutputHandler handler = OutputHandler(raw, command: command);
  handler.determineResponsibility(wingetLocale);
  List<ParsedOutput> output = await handler.getParsedOutputList(wingetLocale);
  return output;
}
