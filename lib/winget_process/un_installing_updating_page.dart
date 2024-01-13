import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/output_handling/plain_text/plain_text_parser.dart';
import 'package:winget_gui/winget_process/winget_process.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../output_handling/output_builder.dart';
import '../output_handling/output_handler.dart';
import '../output_handling/package_infos/package_infos_full.dart';
import '../output_handling/parsed_output.dart';
import '../output_handling/show/show_parser.dart';
import '../winget_commands.dart';
import 'output_page.dart';

class UnInstallingUpdatingPage extends OutputPage {
  const UnInstallingUpdatingPage(
      {super.key, required UnInstallingUpdatingProcess process, super.title})
      : super(process: process);

  @override
  Future<List<OutputBuilder>> outputRepresentationHook(OutputHandler handler,
      BuildContext context, bool processIsFinished) async {
    NavigatorState navigator = Navigator.of(context);
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    List<ParsedOutput> parsedOutput =
        await handler.getParsedOutputList(wingetLocale);
    List<OutputBuilder> outputList = handler.getBuilders(parsedOutput);
    if (processIsFinished) {
      onFinished(parsedOutput, wingetLocale, navigator, outputList);
    }
    return outputList;
  }

  void onFinished(
      List<ParsedOutput> parsedOutput,
      AppLocalizations wingetLocale,
      NavigatorState navigator,
      List<OutputBuilder> outputList) {
    Iterable<ParsedPlainText> plainText =
        parsedOutput.whereType<ParsedPlainText>();
    //print(plainText);
    Iterable<ParsedShow> show = parsedOutput.whereType<ParsedShow>();
    UnInstallingUpdatingProcess p = process as UnInstallingUpdatingProcess;
    if (plainText.isNotEmpty &&
        plainText.last.lastIsSuccessMessage &&
        show.isNotEmpty) {
      PackageInfosFull info = show.last.infos;
      if (p.type == UnInstallingUpdatingType.uninstall) {
        wingetDB.installed.removeInfoWhere(info.probablySamePackage);
        wingetDB.updates.removeInfoWhere(info.probablySamePackage);
        (wingetDB.installed.reloadFuture(wingetLocale)).then((_) {
          wingetDB.updates.reloadFuture(wingetLocale);
        });
      } else if (p.type == UnInstallingUpdatingType.install) {
        wingetDB.installed.addInfo(info.toPeek());
        wingetDB.installed.reloadFuture(wingetLocale);
      } else if (p.type == UnInstallingUpdatingType.update) {
        wingetDB.updates.removeInfoWhere(info.probablySamePackage);
        wingetDB.updates.reloadFuture(wingetLocale);
      }
      wingetDB.notifyListeners();
    }
    addBackButton(navigator, outputList);
  }

  void addBackButton(NavigatorState navigator, List<OutputBuilder> outputList) {
    if (navigator.canPop()) {
      outputList.add(
        QuickOutputBuilder(
          (context) {
            return Row(
              children: [
                Button(onPressed: navigator.maybePop, child: const Text('close'))
              ],
            );
          },
        ),
      );
    }
  }
}

class UnInstallingUpdatingProcess extends WingetProcess {
  final UnInstallingUpdatingType type;
  UnInstallingUpdatingProcess._(
      {required super.command,
      required super.process,
      super.name,
      required this.type});

  static Future<UnInstallingUpdatingProcess> run(UnInstallingUpdatingType type,
      {List<String> args = const []}) async {
    var command = [...type.winget.fullCommand, ...args];
    Process process = await Process.start('winget', command);
    return UnInstallingUpdatingProcess._(
        command: command, process: process, name: type.winget.name, type: type);
  }
}

enum UnInstallingUpdatingType {
  uninstall(Winget.uninstall),
  install(Winget.install),
  update(Winget.upgrade);

  final Winget winget;
  const UnInstallingUpdatingType(this.winget);
}
