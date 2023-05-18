import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/extensions/widget_list_extension.dart';
import 'package:winget_gui/output_handling/plain_text/plain_text_scanner.dart';
import 'package:winget_gui/output_handling/responsibility.dart';
import 'package:winget_gui/output_handling/scanner.dart';
import 'package:winget_gui/output_handling/table/table_scanner.dart';

import 'output_part.dart';

class OutputHandler {
  List<String> output;
  List<String> command;
  late List<Scanner> outputScanners;
  late final List<Responsibility> responsibilityList;

  OutputHandler(this.output, this.command) {
    responsibilityList = [for (String line in output) Responsibility(line)];

    outputScanners = [
      TableScanner(responsibilityList),
      PlainTextScanner(responsibilityList)
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

        list.add(part.representation());
      }
      prevPart = part;
    }
    return list.withSpaceBetween(height: 20);
  }
}
