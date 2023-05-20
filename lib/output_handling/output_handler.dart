import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/extensions/string_list_extension.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/loading_bar/loading_bar_scanner.dart';
import 'package:winget_gui/output_handling/plain_text/plain_text_scanner.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/scanner.dart';
import 'package:winget_gui/output_handling/show/show_scanner.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';

import 'output_part.dart';

class OutputHandler {
  List<String> output;
  List<String> command;
  late List<Scanner> outputScanners;
  late final List<Responsibility> responsibilityList;

  OutputHandler(this.output, this.command) {
    output.trim();
    responsibilityList = [for (String line in output) Responsibility(line)];

    outputScanners = [
      TableScanner(responsibilityList),
      LoadingBarScanner(responsibilityList),
      ShowScanner(responsibilityList, command),
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
