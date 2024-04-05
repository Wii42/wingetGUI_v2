import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/output_handler.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';

import 'output_page.dart';
import 'package_action_process.dart';

class PackageActionPage extends OutputPage {
  const PackageActionPage(
      {super.key, required PackageActionProcess process, super.title})
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
