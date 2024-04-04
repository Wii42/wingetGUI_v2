import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:winget_gui/helpers/extensions/string_list_extension.dart';
import 'package:winget_gui/output_handling/parsed_output.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';

import '../global_app_data.dart';
import './list/list_scanner.dart';
import './loading_bar/loading_bar_scanner.dart';
import './one_line_info/one_line_info_scanner.dart';
import './output_scanner.dart';
import './plain_text/plain_text_scanner.dart';
import './responsibility.dart';
import './show/show_scanner.dart';
import 'output_parser.dart';

class OutputHandler {
  final List<String> output;
  final List<String> command;

  final String? title;
  late List<OutputScanner> outputScanners;
  late final List<Responsibility> responsibilityList;

  OutputHandler(this.output, {required this.command, this.title}) {
    output.trim();
    responsibilityList = [for (String line in output) Responsibility(line)];

    outputScanners = [
      TableScanner(responsibilityList, command: command),
      LoadingBarScanner(responsibilityList),
      ShowScanner(responsibilityList, command: command),
      ListScanner(responsibilityList),
      OneLineInfoScanner(responsibilityList),
      PlainTextScanner(responsibilityList),
    ];
  }

  void determineResponsibility(AppLocalizations wingetLocale) {
    for (OutputScanner scanner in outputScanners) {
      scanner.markResponsibleLines(wingetLocale);
    }
  }

  Set<OutputParser> get outputParsers {
    return responsibilityList.map<OutputParser>((Responsibility resp) {
      if (resp.respParser == null) {
        throw Exception("Not all lines are assigned to a part.\n"
            "Unassigned line: ${resp.line}");
      }
      return resp.respParser!;
    }).toSet();
  }

  Future<List<ParsedOutput>> getParsedOutputList(
      AppLocalizations wingetLocale) async {
    Iterable<Future<ParsedOutput>> parsedOutputFutures = outputParsers
        .map<Future<ParsedOutput>>((part) async => part.parse(wingetLocale));

    List<ParsedOutput> parsedOutput =
        await Future.wait<ParsedOutput>(parsedOutputFutures);

    return parsedOutput;
  }

  Future<List<Widget>> getRepresentation(BuildContext context) async {
    AppLocalizations wingetLocale = getWingetLocale(context);
    List<ParsedOutput> parsedOutput = await getParsedOutputList(wingetLocale);

    return getWidgets(parsedOutput);
  }

  List<Widget> getWidgets(List<ParsedOutput> parsedOutput) {
    Iterable<Widget?> builders =
        parsedOutput.map((e) => e.widgetRepresentation());

    List<Widget> finalBuilders = builders.nonNulls.toList();

    return finalBuilders;
  }

  static AppLocalizations getWingetLocale(BuildContext context) {
    AppLocalizations wingetLocale =
        AppLocales.of(context).getWingetAppLocalization() ??
            AppLocalizations.of(context)!;
    return wingetLocale;
  }
}
