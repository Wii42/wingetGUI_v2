import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/helpers/extensions/string_list_extension.dart';
import 'package:winget_gui/helpers/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/list/list_scanner.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_scanner.dart';
import 'package:winget_gui/output_handling/plain_text/plain_text_scanner.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/scanner.dart';
import 'package:winget_gui/output_handling/show/show_scanner.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';

import 'output_part.dart';

class OutputHandler {
  final List<String> output;
  final List<String> command;
  final List<String>? prevCommand;

  final String? title;
  late List<Scanner> outputScanners;
  late final List<Responsibility> responsibilityList;

  OutputHandler(this.output, {required this.command, this.prevCommand, this.title}) {
    output.trim();
    responsibilityList = [for (String line in output) Responsibility(line)];

    outputScanners = [
      TableScanner(responsibilityList),
      LoadingBarScanner(responsibilityList),
      ShowScanner(responsibilityList, command: command, prevCommand: prevCommand),
      ListScanner(responsibilityList),
      PlainTextScanner(responsibilityList),
    ];
  }

  determineResponsibility() {
    for (Scanner scanner in outputScanners) {
      scanner.markResponsibleLines();
    }
  }

  List<Widget> displayOutput() {
    List<Widget> list = [];
    OutputPart? prevPart;

    for (Responsibility resp in responsibilityList) {
      OutputPart? part = resp.respPart;
      if (part != prevPart) {
        if (part == null) {
          throw Exception("Not all lines are assigned to a part");
        }
        Widget? rep = part.representation();
        if (rep != null) {
          list.add(rep);
        }
      }
      prevPart = part;
    }
    return list.withSpaceBetween(height: 20);
  }
}
