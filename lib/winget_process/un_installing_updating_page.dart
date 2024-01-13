import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/winget_process/winget_process.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/output_builder.dart';
import '../output_handling/output_handler.dart';
import '../output_handling/parsed_output.dart';
import '../winget_commands.dart';
import 'output_page.dart';

class UnInstallingUpdatingPage extends OutputPage {
  const UnInstallingUpdatingPage(
      {super.key, required UnInstallingUpdatingProcess process, super.title})
      : super(process: process);

  @override
  Future<List<OutputBuilder>> outputRepresentationHook(
      OutputHandler handler, BuildContext context) async {
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    List<ParsedOutput> parsedOutput =
        await handler.getParsedOutputList(wingetLocale);
print(parsedOutput);
    return handler.getBuilders(parsedOutput);
  }
}

class UnInstallingUpdatingProcess extends WingetProcess {
  UnInstallingUpdatingProcess._(
      {required super.command, required super.process, super.name});

  static Future<UnInstallingUpdatingProcess> run(
      UnInstallingUpdatingType type, {List<String> args = const []}) async {
    var command = [...type.winget.fullCommand, ...args];
    Process process = await Process.start('winget', command);
    return UnInstallingUpdatingProcess._(
        command: command,
        process: process,
        name: type.winget.name);
  }
}

enum UnInstallingUpdatingType {
  uninstall(Winget.uninstall),
  install(Winget.install),
  update(Winget.upgrade);

  final Winget winget;
  const UnInstallingUpdatingType(this.winget);
}
