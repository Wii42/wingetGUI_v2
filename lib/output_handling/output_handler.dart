import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_list_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';

import './list/list_scanner.dart';
import './loading_bar/loading_bar_scanner.dart';
import './one_line_info/one_line_info_scanner.dart';
import './output_builder.dart';
import './plain_text/plain_text_scanner.dart';
import './responsibility.dart';
import './output_scanner.dart';
import './show/show_scanner.dart';

import '../widget_assets/app_locale.dart';
import 'output_parser.dart';

class OutputHandler {
  final List<String> output;
  final List<String> command;
  final List<String>? prevCommand;

  final String? title;
  late List<OutputScanner> outputScanners;
  late final List<Responsibility> responsibilityList;

  OutputHandler(this.output,
      {required this.command, this.prevCommand, this.title}) {
    output.trim();
    responsibilityList = [for (String line in output) Responsibility(line)];

    outputScanners = [
      TableScanner(responsibilityList, command: command),
      LoadingBarScanner(responsibilityList),
      ShowScanner(responsibilityList,
          command: command, prevCommand: prevCommand),
      ListScanner(responsibilityList),
      OneLineInfoScanner(responsibilityList),
      PlainTextScanner(responsibilityList),
    ];
  }

  determineResponsibility(BuildContext context) {
    for (OutputScanner scanner in outputScanners) {
      scanner.markResponsibleLines(getWingetLocale(context));
    }
  }

  Future<List<OutputBuilder>> getRepresentation(BuildContext context) async {
    Set<OutputParser> parts =
        responsibilityList.map<OutputParser>((Responsibility resp) {
      if (resp.respPart == null) {
        throw Exception("Not all lines are assigned to a part.\n"
            "Unassigned line: ${resp.line}");
      }
      return resp.respPart!;
    }).toSet();

    AppLocalizations wingetLocale = getWingetLocale(context);

    List<Future<OutputBuilder?>> builderFutures = parts
        .map<Future<OutputBuilder?>>((part) async => part.parse(wingetLocale))
        .toList();

    List<OutputBuilder?> builders =
        await Future.wait<OutputBuilder?>(builderFutures);

    List<OutputBuilder> finalBuilders = builders
        .where((builder) => builder != null)
        .map<OutputBuilder>((OutputBuilder? builder) => builder!)
        .toList();

    return finalBuilders;
  }

  AppLocalizations getWingetLocale(BuildContext context) {
    AppLocalizations wingetLocale =
        AppLocale.of(context).getWingetAppLocalization() ??
            AppLocalizations.of(context)!;
    return wingetLocale;
  }
}
