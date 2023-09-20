import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:winget_gui/helpers/extensions/stream_modifier.dart';
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
      scanner.markResponsibleLines(context);
    }
  }

  Stream<List<OutputBuilder>> getRepresentation(BuildContext context) {
    Set<OutputParser> parsers =
        responsibilityList.map<OutputParser>((Responsibility resp) {
      if (resp.respPart == null) {
        throw Exception("Not all lines are assigned to a part.\n"
            "Unassigned line: ${resp.line}");
      }
      return resp.respPart!;
    }).toSet();

    AppLocalizations wingetLocale =
        AppLocale.of(context).getWingetAppLocalization() ??
            AppLocalizations.of(context)!;

    List<FlexibleOutputBuilder?> builders =
        parsers.map((e) => e.parse(wingetLocale)).toList();
    List<FlexibleOutputBuilder> nonNullBuilders =
        builders.where((element) => element != null).map((e) => e!).toList();

    Stream<List<List<OutputBuilder>>> stream =
        combineLatest(nonNullBuilders.map((e) {
      if (e.isA) {
        return e.a!.rememberingStream();
      } else {
        return Stream.value([e.b!]);
      }
    }));

    Stream<List<OutputBuilder>> flatStream = stream.map<List<OutputBuilder>>(
        (List<List<OutputBuilder>> builderList) =>
            [for (List<OutputBuilder> list in builderList) ...list]);

    //List<OutputBuilder> builders =
    //    await Future.wait<OutputBuilder>(builders.map<Future<OutputBuilder>>((FutureOr<OutputBuilder> builder) => (builder is OutputBuilder ? )));

    return flatStream;
  }

  Stream<List<T>> combineLatest<T>(Iterable<Stream<T>> streams) {
    final Stream<T> first = streams.first;
    final List<Stream<T>> others = [...streams.skip(1)];
    return first.combineLatestAll(others);
  }
}
