import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/plain_text/plain_text_parser.dart';
import 'package:winget_gui/winget_process/winget_process.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../output_handling/output_handler.dart';
import '../output_handling/package_infos/package_infos_full.dart';
import '../output_handling/parsed_output.dart';
import '../output_handling/show/show_parser.dart';
import '../winget_db/winget_db.dart';
import 'output_page.dart';

class UnInstallingUpdatingPage extends OutputPage {
  const UnInstallingUpdatingPage(
      {super.key, required UnInstallingUpdatingProcess process, super.title})
      : super(process: process);

  @override
  Future<List<Widget>> outputRepresentationHook(OutputHandler handler,
      BuildContext context, bool processIsFinished) async {
    NavigatorState navigator = Navigator.of(context);
    AppLocalizations guiLocale = AppLocalizations.of(context)!;
    AppLocalizations wingetLocale = OutputHandler.getWingetLocale(context);
    List<ParsedOutput> parsedOutput =
        await handler.getParsedOutputList(wingetLocale);
    List<Widget> outputList = handler.getWidgets(parsedOutput);
    if (processIsFinished) {
      onFinished(parsedOutput, wingetLocale, navigator, outputList, guiLocale);
    }
    return outputList;
  }

  void onFinished(
      List<ParsedOutput> parsedOutput,
      AppLocalizations wingetLocale,
      NavigatorState navigator,
      List<Widget> outputList,
      AppLocalizations guiLocale) {
    Iterable<ParsedPlainText> plainText =
        parsedOutput.whereType<ParsedPlainText>();
    //print(plainText);
    Iterable<ParsedShow> show = parsedOutput.whereType<ParsedShow>();
    UnInstallingUpdatingProcess p = process as UnInstallingUpdatingProcess;
    if (plainText.isNotEmpty &&
        plainText.last.lastIsSuccessMessage &&
        show.isNotEmpty) {
      PackageInfosFull info = show.last.infos;
      WingetDB wingetDB = WingetDB.instance;
      if (p.type == UnInstallingUpdatingType.uninstall) {
        WingetDB.instance.installed.removeInfoWhere(info.probablySamePackage);
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
    addBackButton(navigator, outputList, guiLocale);
  }

  void addBackButton(NavigatorState navigator, List<Widget> outputList,
      AppLocalizations guiLocale) {
    if (navigator.canPop()) {
      outputList.add(
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Button(
                  onPressed: navigator.maybePop,
                  child: Row(
                    children: [
                      const Icon(FluentIcons.chrome_close),
                      Text(guiLocale.close),
                    ].withSpaceBetween(width: 10),
                  )),
            )
          ],
        ),
      );
    }
  }
}
