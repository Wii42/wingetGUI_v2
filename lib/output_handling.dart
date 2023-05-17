import 'package:fluent_ui/fluent_ui.dart';
import 'package:winget_gui/table/table_scanner.dart';

class OutputHandler {
  List<String> output;
  List<String> command;
  late List<Scanner> outputScanners;
  late final List<Responsibility> responsibilityList;

  OutputHandler(this.output, this.command) {
    responsibilityList = [for (String line in output) Responsibility(line)];
    outputScanners = [
      TableScanner(responsibilityList),
      RestScanner(responsibilityList)
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
        if (part != null) {
          list.add(part.representation());
        }
      }
      prevPart = part;
    }
    return list;
  }
}

class Responsibility {
  final String line;
  OutputPart? respPart;
  Responsibility(this.line, {this.respPart});
}

abstract class Scanner {
  List<Responsibility> respList;

  Scanner(this.respList);
  void markResponsibleLines();
}

abstract class OutputPart {
  List<String> lines;

  OutputPart(this.lines);

  Widget representation();
}

class RestScanner extends Scanner {

  RestScanner(super.respList);
  @override
  void markResponsibleLines() {
    for (Responsibility resp in respList) {
      if (resp.respPart == null) {
        RestPart rest = RestPart([resp.line]);
        resp.respPart = rest;
      }
    }
  }
}

class RestPart extends OutputPart {
  RestPart(super.lines);

  @override
  Widget representation() {
    return Column(children: [for (String line in lines) Text(line)]);
  }
}
